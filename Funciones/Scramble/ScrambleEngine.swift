import Foundation

enum ScrambleEngineError: LocalizedError {
    case recursosNoEncontrados
    case motorNoDisponible
    case generacion(String)

    var errorDescription: String? {
        switch self {
        case .recursosNoEncontrados:
            return "No se encontró el bundle ScrambleEngine en la app."
        case .motorNoDisponible:
            return "El motor de scrambles no está disponible."
        case .generacion(let detalle):
            return "El motor no pudo generar el scramble: \(detalle)"
        }
    }
}

/// Motor de scrambles de la Opción B.
///
/// Los scrambles los genera un **servidor TNoodle**, el programa oficial de la WCA.
/// TNoodle solo existe para JVM (Kotlin), así que no puede ejecutarse dentro del
/// iPhone: la app se los pide por HTTP con `TNoodleClient`.
///
/// Además mantiene el servidor HTTP local que sirve `viewer.html` y `viewer.js` al
/// `WKWebView` del diagrama 2D. Hace falta porque WebKit no puede cargar módulos ES
/// desde `file://`; solo sirve recursos del bundle y escucha en loopback.
@MainActor
final class ScrambleEngine {

    static let shared = ScrambleEngine()

    private let cliente: TNoodleClient

    private var server: ScrambleHTTPServer?
    private var puerto: UInt16?
    private var preparacion: Task<UInt16, Error>?

    private init(cliente: TNoodleClient = TNoodleClient()) {
        self.cliente = cliente
    }

    // MARK: - Scrambles

    /// Comprueba que el servidor TNoodle responde. No bloquea.
    func warmUp() {
        Task { [weak self] in
            guard let self else { return }
            _ = try? await self.cliente.calentar()
        }
    }

    /// Pide un scramble para un evento TNoodle (`"333"`, `"222"`, `"minx"`, …).
    func scramble(eventID: String, timeout: TimeInterval) async throws -> String {
        do {
            return try await cliente.scramble(eventID: eventID, timeout: timeout)
        } catch {
            throw ScrambleEngineError.generacion(error.localizedDescription)
        }
    }

    // MARK: - Diagrama 2D

    /// URL del visor que dibuja el diagrama 2D del scramble. Arranca el servidor de
    /// recursos locales si todavía no estaba en marcha.
    func viewerURL() async throws -> URL {
        let puerto = try await servidorLocal()

        guard let url = URL(string: "http://127.0.0.1:\(puerto)/viewer.html") else {
            throw ScrambleEngineError.recursosNoEncontrados
        }

        return url
    }

    private func servidorLocal() async throws -> UInt16 {
        if let puerto {
            return puerto
        }

        if let preparacion {
            return try await preparacion.value
        }

        let tarea = Task<UInt16, Error> { [weak self] in
            guard let self else {
                throw ScrambleEngineError.motorNoDisponible
            }

            guard
                let raiz = Bundle.main.url(forResource: "ScrambleEngine", withExtension: nil),
                FileManager.default.fileExists(atPath: raiz.appendingPathComponent("viewer.html").path)
            else {
                throw ScrambleEngineError.recursosNoEncontrados
            }

            let servidor = ScrambleHTTPServer(root: raiz)
            let puertoAsignado = try await servidor.start()
            self.server = servidor
            self.puerto = puertoAsignado
            return puertoAsignado
        }
        preparacion = tarea

        do {
            let puerto = try await tarea.value
            preparacion = nil
            return puerto
        } catch {
            preparacion = nil
            server?.cancel()
            server = nil
            puerto = nil
            throw error
        }
    }
}
