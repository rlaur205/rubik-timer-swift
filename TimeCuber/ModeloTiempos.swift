import Foundation

class Sesion: Codable, Identifiable, Equatable {
    var id: UUID
    var tiempos: [Tiempo]
    var nombre: String
    var categoria: String
    
    init(tiempos: [Tiempo], nombre: String, categoria: String) {
        self.id = UUID()
        self.tiempos = tiempos
        self.nombre = nombre
        self.categoria = categoria
    }
    
    // Implementación de Equatable
    static func == (lhs: Sesion, rhs: Sesion) -> Bool {
        return lhs.id == rhs.id &&
               lhs.nombre == rhs.nombre &&
               lhs.categoria == rhs.categoria &&
               lhs.tiempos == rhs.tiempos
    }
}

enum PenalizacionTiempo: String, Codable, CaseIterable, Identifiable {
    case dnf
    case masDos
    case ninguna

    var id: Self { self }

    var titulo: String {
        switch self {
        case .dnf: "DNF"
        case .masDos: "+2"
        case .ninguna: "Sin penalización"
        }
    }
}

struct Tiempo: Codable, Identifiable, Equatable {
    var id: UUID
    var tiempo: Double
    var scramble: String
    var fecha: Date
    var categoria: String?
    private var penalizacionGuardada: PenalizacionTiempo?

    // Los tiempos guardados antes de esta función no tienen una penalización.
    var penalizacion: PenalizacionTiempo {
        get { penalizacionGuardada ?? .ninguna }
        set { penalizacionGuardada = newValue == .ninguna ? nil : newValue }
    }

    var segundosValidos: Double? {
        switch penalizacion {
        case .ninguna: tiempo
        case .masDos: tiempo + 2
        case .dnf: nil
        }
    }
    
    init(
        tiempo: Double,
        scramble: String,
        fecha: Date,
        categoria: String? = nil,
        penalizacion: PenalizacionTiempo = .ninguna
    ) {
        self.id = UUID()
        self.tiempo = tiempo
        self.scramble = scramble
        self.fecha = fecha
        self.categoria = categoria
        self.penalizacion = penalizacion
    }
    
    func texto(largo: Bool) -> String {
        let valor = String(formatoTiempo(segundosValidos ?? tiempo).dropLast())
        switch penalizacion {
        case .ninguna: return valor
        case .masDos: return valor + (largo ? "(+2)" : "+")
        case .dnf: return largo ? valor + "(DNF)" : "DNF"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, tiempo, scramble, fecha, categoria
        case penalizacionGuardada = "penalizacion"
    }
}

enum Orden: String, CaseIterable {
    case fecha = "Fecha"
    case ascendente = "Ascendente"
    case descendente = "Descendente"
}

struct TimerState {
    var estaCorriendo: Bool
    var tiempoInicio: Date?
    var tiempoTranscurrido:TimeInterval
    var visibilidadPromedios: Bool
}
