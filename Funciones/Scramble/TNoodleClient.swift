import Foundation

/// Cliente HTTP de un servidor TNoodle (Opción B).
///
/// TNoodle es el programa oficial de scrambles de la WCA, pero solo existe para JVM:
/// no hay build para iOS ni para el navegador. Por eso la app le pide los scrambles a
/// un servidor TNoodle con su API pública:
///
///     GET /api/v0/scramble/<evento>?numScrambles=1  →  ["R U R' U' …"]
///
/// El servidor se configura en `urlBasePorDefecto` (o con la clave `tnoodleURL` de
/// `UserDefaults`, útil para apuntar a otro servidor sin recompilar).
struct TNoodleClient: Sendable {

    enum Error: LocalizedError {
        case servidorNoConfigurado
        case respuestaHTTP(Int)
        case respuestaInvalida
        case sinScramble

        var errorDescription: String? {
            switch self {
            case .servidorNoConfigurado:
                return "No hay un servidor TNoodle configurado."
            case .respuestaHTTP(let codigo):
                return "El servidor TNoodle respondió con HTTP \(codigo)."
            case .respuestaInvalida:
                return "El servidor TNoodle devolvió una respuesta inesperada."
            case .sinScramble:
                return "El servidor TNoodle no devolvió ningún scramble."
            }
        }
    }

    /// Servidor TNoodle al que se le piden los scrambles.
    ///
    /// Para usar otro servidor sin recompilar:
    /// `xcrun simctl spawn booted defaults write com.laurencio.pruebas tnoodleURL -string "https://…"`
    static let urlBasePorDefecto = URL(string: "http://127.0.0.1:2014")!

    let urlBase: URL
    private let sesion: URLSession

    init(urlBase: URL? = nil) {
        let preferida = UserDefaults.standard.string(forKey: "tnoodleURL").flatMap(URL.init(string:))
        self.urlBase = urlBase ?? preferida ?? Self.urlBasePorDefecto

        let configuracion = URLSessionConfiguration.ephemeral
        configuracion.waitsForConnectivity = false
        configuracion.timeoutIntervalForRequest = 10
        configuracion.timeoutIntervalForResource = 30
        self.sesion = URLSession(configuration: configuracion)
    }

    /// Genera un scramble para un evento TNoodle (`"333"`, `"222"`, `"minx"`, …).
    ///
    /// Los scrambles de TNoodle pueden traer saltos de línea (por ejemplo Megaminx);
    /// aquí se normalizan a una sola línea para que la vista no se rompa.
    func scramble(eventID: String, timeout: TimeInterval) async throws -> String {
        let url = urlBase
            .appendingPathComponent("api")
            .appendingPathComponent("v0")
            .appendingPathComponent("scramble")
            .appendingPathComponent(eventID)

        guard var componentes = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error.servidorNoConfigurado
        }
        componentes.queryItems = [URLQueryItem(name: "numScrambles", value: "1")]

        guard let urlFinal = componentes.url else {
            throw Error.servidorNoConfigurado
        }

        var peticion = URLRequest(url: urlFinal, timeoutInterval: timeout)
        peticion.setValue("application/json", forHTTPHeaderField: "Accept")

        let (datos, respuesta) = try await sesion.data(for: peticion)

        guard let http = respuesta as? HTTPURLResponse else {
            throw Error.respuestaInvalida
        }
        guard (200..<300).contains(http.statusCode) else {
            throw Error.respuestaHTTP(http.statusCode)
        }
        guard let scrambles = try? JSONDecoder().decode([String].self, from: datos),
              let primero = scrambles.first
        else {
            throw Error.respuestaInvalida
        }

        let limpio = primero
            .split(whereSeparator: { $0.isNewline })
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !limpio.isEmpty else {
            throw Error.sinScramble
        }

        return limpio
    }

    /// Comprueba que el servidor responde y que la API está disponible.
    func calentar() async throws {
        let url = urlBase
            .appendingPathComponent("api")
            .appendingPathComponent("v0")
            .appendingPathComponent("puzzles")

        var peticion = URLRequest(url: url, timeoutInterval: 10)
        peticion.setValue("application/json", forHTTPHeaderField: "Accept")

        let (_, respuesta) = try await sesion.data(for: peticion)

        guard let http = respuesta as? HTTPURLResponse,
              (200..<300).contains(http.statusCode)
        else {
            throw Error.respuestaInvalida
        }
    }
}
