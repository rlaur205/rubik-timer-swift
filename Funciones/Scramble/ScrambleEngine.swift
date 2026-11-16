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
/// Los scrambles los genera **TNoodle**, el programa oficial de la WCA, compilado
/// como librería nativa para iOS (igual que CubeTime). Todo ocurre en el
/// dispositivo: no hace falta servidor ni conexión a internet.
///
/// Además mantiene el servidor HTTP local que sirve `viewer.html` y `viewer.js` al
/// `WKWebView` del diagrama 2D. Hace falta porque WebKit no puede cargar módulos ES
/// desde `file://`; solo sirve recursos del bundle y escucha en loopback.
@MainActor
final class ScrambleEngine {

    static let shared = ScrambleEngine()

    private var server: ScrambleHTTPServer?
    private var puerto: UInt16?
    private var preparacion: Task<UInt16, Error>?

    private init() {}

    // MARK: - Scrambles

    /// Calienta TNoodle con un scramble 2x2. No bloquea.
    func warmUp() {
        Task.detached(priority: .utility) {
            _ = try? TNoodleScrambler.shared.scramble(.twoByTwo)
        }
    }

    /// Genera un scramble en segundo plano (TNoodle tarda sobre todo en 3x3 y 4x4).
    func scramble(puzzle: TNoodlePuzzle) async throws -> String {
        do {
            return try await Task.detached(priority: .userInitiated) {
                try TNoodleScrambler.shared.scramble(puzzle)
            }.value
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
