import CryptoKit
import Foundation

enum FuenteImportacion: String, Sendable {
    case csTimer
    case twistyTimer = "Twisty Timer"

    func leer(_ url: URL) throws -> ImportacionTiempos {
        let acceso = url.startAccessingSecurityScopedResource()
        defer { if acceso { url.stopAccessingSecurityScopedResource() } }
        let datos = try Data(contentsOf: url)
        switch self {
        case .csTimer:
            return try ImportadorCSTimer.interpretar(datos)
        case .twistyTimer:
            return try ImportadorTwistyTimer.interpretar(datos, nombreArchivo: url.deletingPathExtension().lastPathComponent)
        }
    }
}

struct ImportacionTiempos: Sendable {
    struct Sesion: Identifiable, Sendable {
        let id: UUID
        let nombre: String
        let categoria: String
        let tiempos: [Registro]

        init(fuente: FuenteImportacion, indice: Int, nombre: String, categoria: String, tiempos: [Registro]) throws {
            let codificador = JSONEncoder()
            codificador.outputFormatting = .sortedKeys
            // El índice distingue dos sesiones iguales dentro de un mismo respaldo.
            var identidad = SHA256()
            identidad.update(data: try codificador.encode([fuente.rawValue, String(indice), nombre, categoria]))
            identidad.update(data: try codificador.encode(tiempos))
            let bytes = Array(identidad.finalize())
            id = UUID(uuid: (
                bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5],
                (bytes[6] & 0x0f) | 0x80, bytes[7], (bytes[8] & 0x3f) | 0x80,
                bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
            ))
            self.nombre = nombre
            self.categoria = categoria
            self.tiempos = tiempos
        }
    }

    struct Registro: Encodable, Sendable {
        let milisegundos: Int
        let fecha: Date
        let scramble: String
        let penalizacion: PenalizacionTiempo
    }

    let sesiones: [Sesion]
    let sesionesOmitidas: Int
    let tiemposOmitidos: Int
}
