import Foundation
import Observation
import SwiftUI

// MARK: - Idiomas

/// Preferencia local de la pantalla de Ajustes. No cambia el idioma real de la app.
enum IdiomaAjuste: String, CaseIterable, Identifiable, Hashable {
    case sistema
    case espanol
    case english

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .sistema: "Sistema"
        case .espanol: "Español"
        case .english: "English"
        }
    }

    var detalle: String? {
        switch self {
        case .sistema: "Usa el idioma del iPhone"
        case .espanol, .english: nil
        }
    }
}

// MARK: - Texto

enum TamanoScramble: Int, CaseIterable, Identifiable, Hashable {
    case pequeno
    case mediano
    case grande

    var id: Int { rawValue }

    var nombre: String {
        switch self {
        case .pequeno: "Pequeño"
        case .mediano: "Mediano"
        case .grande: "Grande"
        }
    }

    var tamanoFuente: CGFloat {
        switch self {
        case .pequeno: 15
        case .mediano: 19
        case .grande: 24
        }
    }
}

// MARK: - Temporizador

enum ColorListoAjuste: String, CaseIterable, Identifiable, Hashable {
    case verde
    case azul
    case amarillo
    case naranja
    case morado

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .verde: "Verde"
        case .azul: "Azul"
        case .amarillo: "Amarillo"
        case .naranja: "Naranja"
        case .morado: "Morado"
        }
    }

    var color: Color {
        switch self {
        case .verde: .green
        case .azul: .blue
        case .amarillo: .yellow
        case .naranja: .orange
        case .morado: .purple
        }
    }
}

enum PrecisionAjuste: String, CaseIterable, Identifiable, Hashable {
    case centesimas
    case milesimas

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .centesimas: "0.00"
        case .milesimas: "0.000"
        }
    }

    var ejemplo: String {
        switch self {
        case .centesimas: "12.34"
        case .milesimas: "12.345"
        }
    }
}

// MARK: - Estado local

/// Estado exclusivamente local y en memoria de la pantalla de Ajustes.
/// No se conecta al RubikViewModel ni escribe en disco, UserDefaults o iCloud.
@Observable
final class AjustesEstado {

    // Apariencia
    var idioma: IdiomaAjuste = .sistema

    // Texto
    var tamanoScramble: TamanoScramble = .mediano

    // Temporizador
    var tamanoTimer: Double = 70
    var inspeccion15s = true
    var mantenerParaIniciar = true
    var tiempoEspera: Double = 0.5
    var colorListo: ColorListoAjuste = .verde
    var precision: PrecisionAjuste = .centesimas
    var vibracion = true
    var pantallaSiempreEncendida = true

    // Datos
    var sincronizarICloud = false

    /// Restablece únicamente el estado de esta pantalla.
    func restablecer() {
        idioma = .sistema
        tamanoScramble = .mediano
        tamanoTimer = 70
        inspeccion15s = true
        mantenerParaIniciar = true
        tiempoEspera = 0.5
        colorListo = .verde
        precision = .centesimas
        vibracion = true
        pantallaSiempreEncendida = true
        sincronizarICloud = false
    }
}

// MARK: - Información de la app

enum AjustesInformacionApp {
    /// Lee la versión desde el Bundle. En previews puede no existir y se muestra un guion.
    static var version: String {
        let info = Bundle.main.infoDictionary
        let corta = info?["CFBundleShortVersionString"] as? String
        let compilacion = info?["CFBundleVersion"] as? String

        switch (corta, compilacion) {
        case let (corta?, compilacion?):
            return "\(corta) (\(compilacion))"
        case let (corta?, nil):
            return corta
        default:
            return "—"
        }
    }
}

// MARK: - Avisos

struct AjustesAviso: Identifiable {
    let id = UUID()
    let titulo: String
    let mensaje: String
}
