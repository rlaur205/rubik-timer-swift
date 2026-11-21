import Foundation

enum ImportadorTwistyTimer {
    enum ErrorLectura: LocalizedError {
        case nombreArchivo
        case formato
        case fila(Int)

        var errorDescription: String? {
            switch self {
            case .nombreArchivo:
                "Conserva el nombre original del archivo Solves de Twisty Timer. Ahí vienen el puzzle y la sesión."
            case .formato:
                "Elige una exportación de una sesión de Twisty Timer con tiempos."
            case .fila(let numero):
                "El tiempo de la línea \(numero) del archivo de Twisty Timer no es válido."
            }
        }
    }

    static func interpretar(_ datos: Data, nombreArchivo: String) throws -> ImportacionTiempos {
        guard let texto = String(data: datos, encoding: .utf8) else { throw ErrorLectura.formato }
        let lineas = texto.split(whereSeparator: \.isNewline)
        guard let primera = lineas.first, primera.hasPrefix("\"") else { throw ErrorLectura.formato }

        // Archivos puede añadir « (1)» al descargar una segunda copia.
        let patronNombre = #/Solves_([^_]+)_(.*)_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}(?: \(\d+\))?/#
        guard let nombre = nombreArchivo.wholeMatch(of: patronNombre) else { throw ErrorLectura.nombreArchivo }
        guard let categoria = categoria(para: nombre.1) else {
            return .init(sesiones: [], sesionesOmitidas: 1, tiemposOmitidos: lineas.count)
        }

        let tiempos = try lineas.enumerated().map { indice, linea in
            try Task.checkCancellation()
            return try registro(linea, numero: indice + 1)
        }
        let sesion = try ImportacionTiempos.Sesion(
            fuente: .twistyTimer, indice: 1, nombre: nombre.2.isEmpty ? categoria : String(nombre.2),
            categoria: categoria, tiempos: tiempos
        )
        return .init(sesiones: [sesion], sesionesOmitidas: 0, tiemposOmitidos: 0)
    }

    private static func registro(_ linea: Substring, numero: Int) throws -> ImportacionTiempos.Registro {
        let patron = #/"([^"]*)";"((?:[^"]|"")*)";"([^"]*)"(?:;"(DNF)")?/#
        guard let campos = linea.wholeMatch(of: patron) else { throw ErrorLectura.fila(numero) }
        let fechaTexto = String(campos.3)
        guard let fecha = (try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(fechaTexto))
                ?? (try? Date.ISO8601FormatStyle().parse(fechaTexto)) else {
            throw ErrorLectura.fila(numero)
        }

        let dnf = campos.4 != nil
        let duracion: Int
        if dnf && (campos.1 == "--" || campos.1 == "DNF") {
            duracion = 0
        } else if let valor = milisegundos(campos.1) {
            duracion = valor
        } else {
            throw ErrorLectura.fila(numero)
        }

        return .init(
            milisegundos: duracion, fecha: fecha,
            scramble: campos.2.replacingOccurrences(of: "\"\"", with: "\""),
            penalizacion: dnf ? .dnf : .ninguna
        )
    }

    private static func milisegundos(_ texto: Substring) -> Int? {
        let patron = #/(?:(\d{1,6})h )?(?:(\d{1,2}):)?(\d{1,2})\.(\d{2})/#
        guard let partes = texto.wholeMatch(of: patron),
              let segundos = Int(partes.3), segundos < 60,
              let centesimas = Int(partes.4) else { return nil }
        let horas = partes.1.flatMap { Int($0) } ?? 0
        let minutos = partes.2.flatMap { Int($0) } ?? 0
        guard minutos < 60 else { return nil }
        return ((horas * 60 + minutos) * 60 + segundos) * 1000 + centesimas * 10
    }

    private static func categoria(para tipo: Substring) -> String? {
        switch tipo {
        case "222": "2x2"
        case "333": "3x3"
        case "444": "4x4"
        case "555": "5x5"
        case "666": "6x6"
        case "777": "7x7"
        case "pyra": "Pyraminx"
        case "mega": "Megaminx"
        case "skewb": "Skewb"
        case "sq1": "Square 1"
        case "fto": "FTO"
        default: nil
        }
    }
}
