import CryptoKit
import Foundation

struct ImportacionCSTimer: Sendable {
    struct Sesion: Identifiable, Sendable {
        let id: UUID
        let nombre: String
        let categoria: String
        let tiempos: [Registro]
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

enum ImportadorCSTimer {
    enum ErrorLectura: LocalizedError {
        case formato
        case sesion(Int)

        var errorDescription: String? {
            switch self {
            case .formato: "El archivo no tiene el formato de un respaldo de csTimer."
            case .sesion(let numero): "Hay datos de tiempo no válidos en la sesión \(numero) de csTimer."
            }
        }
    }

    static func leer(_ url: URL) throws -> ImportacionCSTimer {
        let acceso = url.startAccessingSecurityScopedResource()
        defer { if acceso { url.stopAccessingSecurityScopedResource() } }
        return try interpretar(Data(contentsOf: url))
    }

    static func interpretar(_ datos: Data) throws -> ImportacionCSTimer {
        guard let raiz = try? JSONSerialization.jsonObject(with: datos) as? [String: Any],
              let propiedades = raiz["properties"] as? [String: Any] else {
            throw ErrorLectura.formato
        }

        let metadatos: [String: Metadatos]
        switch propiedades["sessionData"] {
        case let texto as String:
            guard let valor = try? JSONDecoder().decode([String: Metadatos].self, from: Data(texto.utf8)) else {
                throw ErrorLectura.formato
            }
            metadatos = valor
        case nil:
            metadatos = [:]
        default:
            throw ErrorLectura.formato
        }

        let fuentes = raiz.keys.compactMap { clave -> (clave: String, numero: Int, orden: Int)? in
            guard clave.hasPrefix("session"), let numero = Int(clave.dropFirst(7)), numero > 0 else { return nil }
            return (clave, numero, metadatos[String(numero)]?.rank ?? numero)
        }.sorted {
            ($0.orden, $0.numero, $0.clave) < ($1.orden, $1.numero, $1.clave)
        }
        guard !fuentes.isEmpty else { throw ErrorLectura.formato }

        var sesiones: [ImportacionCSTimer.Sesion] = []
        var sesionesOmitidas = 0
        var tiemposOmitidos = 0
        let codificador = JSONEncoder()
        codificador.outputFormatting = .sortedKeys

        for fuente in fuentes {
            try Task.checkCancellation()
            guard let filas = raiz[fuente.clave] as? [[Any]] else {
                throw ErrorLectura.sesion(fuente.numero)
            }
            let metadato = metadatos[String(fuente.numero)]
            guard let categoria = categoria(para: metadato?.opt?.scrType ?? metadato?.scr ?? "333") else {
                sesionesOmitidas += 1
                tiemposOmitidos += filas.count
                continue
            }
            let nombre = metadato?.name?.valor ?? String(fuente.numero)
            let tiempos = try filas.map { try registro($0, sesion: fuente.numero) }
            // El número de origen distingue dos sesiones iguales dentro de un mismo respaldo.
            var identidad = SHA256()
            identidad.update(data: try codificador.encode(["csTimer", String(fuente.numero), nombre, categoria]))
            identidad.update(data: try codificador.encode(tiempos))
            let bytes = Array(identidad.finalize())
            let id = UUID(uuid: (
                bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5],
                (bytes[6] & 0x0f) | 0x80, bytes[7], (bytes[8] & 0x3f) | 0x80,
                bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
            ))
            sesiones.append(.init(id: id, nombre: nombre, categoria: categoria, tiempos: tiempos))
        }

        return ImportacionCSTimer(sesiones: sesiones, sesionesOmitidas: sesionesOmitidas, tiemposOmitidos: tiemposOmitidos)
    }

    private static func registro(_ fila: [Any], sesion: Int) throws -> ImportacionCSTimer.Registro {
        guard fila.count >= 4,
              let valores = fila[0] as? [Int], valores.count >= 2,
              (0..<Int.max / 2).contains(valores[1]),
              let scramble = fila[1] as? String,
              let segundosUnix = fila[3] as? Int, segundosUnix >= 0,
              segundosUnix <= 253_402_300_799 else {
            throw ErrorLectura.sesion(sesion)
        }
        let penalizacion: PenalizacionTiempo
        switch valores[0] {
        case 0: penalizacion = .ninguna
        case 2000: penalizacion = .masDos
        case -1: penalizacion = .dnf
        default: throw ErrorLectura.sesion(sesion)
        }
        return .init(
            milisegundos: valores[1],
            fecha: Date(timeIntervalSince1970: Double(segundosUnix)),
            scramble: scramble,
            penalizacion: penalizacion
        )
    }

    private static func categoria(para tipo: String) -> String? {
        switch tipo {
        case "222so", "222o": "2x2"
        case "333": "3x3"
        case "333oh": "3x3 OH"
        case "333ni": "3x3 BLD"
        case "444wca", "444", "444m": "4x4"
        case "444bld": "4x4 BLD"
        case "555wca", "555": "5x5"
        case "555bld": "5x5 BLD"
        case "666wca", "666": "6x6"
        case "777wca", "777": "7x7"
        case "pyrso", "pyro": "Pyraminx"
        case "mgmp", "mgmc": "Megaminx"
        case "skbso", "skbo": "Skewb"
        case "sqrs", "sq1h", "sq1t": "Square 1"
        case "ftoso", "fto": "FTO"
        default: nil
        }
    }

    private struct Metadatos: Decodable {
        struct Opciones: Decodable { let scrType: String? }

        let name: Nombre?
        let rank: Int?
        let opt: Opciones?
        let scr: String?
    }

    private struct Nombre: Decodable {
        let valor: String

        init(from decoder: Decoder) throws {
            let contenedor = try decoder.singleValueContainer()
            if let numero = try? contenedor.decode(Int.self) {
                valor = String(numero)
            } else {
                valor = try contenedor.decode(String.self)
            }
        }
    }
}
