import Foundation
import WebKit

enum ScrambleEngineError: LocalizedError {
    case recursosNoEncontrados
    case motorNoDisponible
    case respuestaInesperada
    case generacion(String)
    case tiempoAgotado

    var errorDescription: String? {
        switch self {
        case .recursosNoEncontrados:
            return "No se encontró el bundle ScrambleEngine en la app."
        case .motorNoDisponible:
            return "El motor de scrambles no está disponible."
        case .respuestaInesperada:
            return "El motor devolvió una respuesta inesperada."
        case .generacion(let detalle):
            return "El motor no pudo generar el scramble: \(detalle)"
        case .tiempoAgotado:
            return "El motor tardó demasiado en responder."
        }
    }
}

/// Ejecuta cubing.js dentro de un `WKWebView` oculto y expone la generación de
/// scrambles como una función `async` nativa.
///
/// El motor se carga una sola vez y se reutiliza: crear un `WKWebView` por scramble
/// sería lentísimo. Los Web Workers de cubing.js se quedan vivos entre llamadas, así
/// que a partir del primer scramble las siguientes son casi instantáneas.
///
/// iOS puede matar el proceso `WebContent` si necesita memoria. Cuando eso pasa el
/// puente JS deja de responder, así que ante el primer error del puente se tira todo
/// y se reconstruye en la siguiente llamada. Si tras varios intentos sigue fallando se
/// deja de intentar y la app se queda con los generadores Swift.
@MainActor
final class ScrambleEngine {

    static let shared = ScrambleEngine()

    /// Reconstrucciones permitidas antes de darse por vencido.
    private let maxReconstrucciones = 3

    private var server: ScrambleHTTPServer?
    private var webView: WKWebView?
    private var preparacion: Task<Void, Error>?
    private var listo = false
    private var reconstrucciones = 0
    private var abandonado = false

    private init() {}

    /// Arranca el motor sin bloquear. Los errores se ignoran: si algo falla, la app
    /// sigue funcionando con los generadores Swift.
    func warmUp() {
        Task { [weak self] in
            guard let self else { return }
            _ = try? await self.prepare()
        }
    }

    /// Genera un scramble para un evento WCA (`"333"`, `"222"`, `"sq1"`, …).
    func scramble(eventID: String) async throws -> String {
        try await prepare()

        guard let webView else {
            throw ScrambleEngineError.motorNoDisponible
        }

        let resultado: Any?
        do {
            resultado = try await webView.callAsyncJavaScript(
                "return await window.__generateScramble(id);",
                arguments: ["id": eventID],
                in: nil,
                contentWorld: .page
            )
        } catch {
            // El puente ha fallado: lo más probable es que el proceso WebContent haya
            // muerto. Se descarta para reconstruirlo en la siguiente llamada.
            reiniciar()
            throw ScrambleEngineError.generacion(error.localizedDescription)
        }

        guard let texto = resultado as? String else {
            throw ScrambleEngineError.respuestaInesperada
        }

        let prefijoError = "__ERROR__:"
        if texto.hasPrefix(prefijoError) {
            throw ScrambleEngineError.generacion(String(texto.dropFirst(prefijoError.count)))
        }

        return texto
    }

    /// Igual que `scramble(eventID:)` pero con límite de tiempo, para que una
    /// generación atascada no deje la cola de esa categoría bloqueada para siempre.
    func scramble(eventID: String, timeout: TimeInterval) async throws -> String {
        let caja = ResultadoBox()

        return try await withCheckedThrowingContinuation { continuation in
            caja.guardar(continuation)

            Task { [weak self] in
                guard let self else {
                    caja.resumir(.failure(ScrambleEngineError.motorNoDisponible))
                    return
                }

                do {
                    caja.resumir(.success(try await self.scramble(eventID: eventID)))
                } catch {
                    caja.resumir(.failure(error))
                }
            }

            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                caja.resumir(.failure(ScrambleEngineError.tiempoAgotado))
            }
        }
    }

    // MARK: - Arranque

    private func prepare() async throws {
        if listo {
            return
        }

        if abandonado {
            throw ScrambleEngineError.motorNoDisponible
        }

        if let preparacion {
            try await preparacion.value
            return
        }

        let tarea = Task { [weak self] in
            guard let self else { throw ScrambleEngineError.motorNoDisponible }
            try await self.arrancar()
        }
        preparacion = tarea

        do {
            try await tarea.value
        } catch {
            reiniciar()
            throw error
        }
    }

    private func arrancar() async throws {
        if webView != nil {
            try await esperarListo()
            return
        }

        guard
            let raiz = Bundle.main.url(forResource: "ScrambleEngine", withExtension: nil),
            FileManager.default.fileExists(atPath: raiz.appendingPathComponent("index.html").path)
        else {
            throw ScrambleEngineError.recursosNoEncontrados
        }

        let servidor = ScrambleHTTPServer(root: raiz)
        let puerto = try await servidor.start()
        server = servidor

        guard let url = URL(string: "http://127.0.0.1:\(puerto)/index.html") else {
            throw ScrambleEngineError.recursosNoEncontrados
        }

        let configuracion = WKWebViewConfiguration()
        configuracion.websiteDataStore = .nonPersistent()
        configuracion.suppressesIncrementalRendering = true

        let vista = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 1, height: 1),
            configuration: configuracion
        )
        #if DEBUG
        vista.isInspectable = true
        #endif
        webView = vista

        vista.load(URLRequest(url: url))

        try await esperarListo()

        // Primer scramble de calentamiento: inicializa los Web Workers y carga las
        // definiciones del puzzle. El resultado se descarta.
        _ = try? await scramble(eventID: "333")
    }

    /// Espera a que el bundle JS haya terminado de evaluarse.
    private func esperarListo() async throws {
        guard let webView else {
            throw ScrambleEngineError.motorNoDisponible
        }

        let limite = Date().addingTimeInterval(20)

        while Date() < limite {
            let valor = try? await webView.callAsyncJavaScript(
                "return window.__scrambleEngineReady === true;",
                arguments: [:],
                in: nil,
                contentWorld: .page
            )

            if (valor as? Bool) == true {
                listo = true
                return
            }

            try? await Task.sleep(nanoseconds: 100_000_000)
        }

        throw ScrambleEngineError.tiempoAgotado
    }

    /// Tira el motor actual para poder reconstruirlo desde cero.
    private func reiniciar() {
        preparacion?.cancel()
        preparacion = nil
        listo = false
        webView?.stopLoading()
        webView = nil
        server?.cancel()
        server = nil

        reconstrucciones += 1
        if reconstrucciones > maxReconstrucciones {
            abandonado = true
        }

        #if DEBUG
        NSLog("[Scramble] motor reiniciado (intento \(reconstrucciones))")
        #endif
    }
}

/// Contenedor que garantiza que una `CheckedContinuation` se reanude una sola vez,
/// por muy rápido que lleguen la respuesta del motor y el tiempo límite a la vez.
private final class ResultadoBox: @unchecked Sendable {

    private let lock = NSLock()
    private var continuation: CheckedContinuation<String, Error>?

    func guardar(_ continuation: CheckedContinuation<String, Error>) {
        lock.withLock {
            self.continuation = continuation
        }
    }

    func resumir(_ resultado: Result<String, Error>) {
        let continuation = lock.withLock {
            let actual = self.continuation
            self.continuation = nil
            return actual
        }

        continuation?.resume(with: resultado)
    }
}
