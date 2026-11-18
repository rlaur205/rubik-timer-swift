import Foundation
import Observation
import SwiftUI
import UIKit

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

    /// Escala el tamaño elegido según la longitud habitual del scramble de cada
    /// categoría. Se toman como referencia los tamaños que ya usaba el cronómetro
    /// cuando «Grande» era fijo (3x3/Megaminx = 24/15), de modo que «Grande»
    /// reproduce el encaje anterior y los otros tamaños se reducen en la misma
    /// proporción. El mínimo de 11 pt evita que las categorías largas queden
    /// ilegibles con «Pequeño».
    func tamanoFuenteAjustado(para categoria: String) -> CGFloat {
        let factor = Self.factorCategoria(categoria)
        return max(tamanoFuente * factor, Self.tamanoMinimo)
    }

    private static let tamanoMinimo: CGFloat = 11

    private static func factorCategoria(_ categoria: String) -> CGFloat {
        switch categoria {
        case "Megaminx": return 15.0 / 24.0
        case "7x7": return 16.0 / 24.0
        case "6x6": return 17.0 / 24.0
        case let categoria where categoria.hasPrefix("5x5"): return 18.0 / 24.0
        case let categoria where categoria.hasPrefix("4x4"): return 20.0 / 24.0
        default: return 1
        }
    }
}

// MARK: - Fuentes

enum EspecificacionFuente: Hashable {
    case sistema(design: Font.Design, peso: Font.Weight)
    case postScript(nombre: String, designFallback: Font.Design, pesoFallback: Font.Weight)

    var nombrePostScript: String? {
        if case let .postScript(nombre, _, _) = self { return nombre }
        return nil
    }

    var postScriptDisponible: Bool {
        guard let nombrePostScript else { return true }
        return Self.nombrePostScriptDisponible(nombrePostScript) != nil
    }

    func font(tamano: CGFloat, pesoOverride: Font.Weight? = nil) -> Font {
        switch self {
        case let .sistema(design, peso):
            return .system(size: tamano, weight: pesoOverride ?? peso, design: design)
        case let .postScript(nombre, designFallback, pesoFallback):
            if let nombreResuelto = Self.nombrePostScriptDisponible(nombre) {
                return .custom(nombreResuelto, fixedSize: tamano)
            }
            return .system(size: tamano, weight: pesoFallback, design: designFallback)
        }
    }

    func fontLista(tamano: CGFloat = 17, pesoOverride: Font.Weight? = nil) -> Font {
        switch self {
        case let .sistema(design, peso):
            return .system(size: tamano, weight: pesoOverride ?? peso, design: design)
        case let .postScript(nombre, designFallback, pesoFallback):
            if let nombreResuelto = Self.nombrePostScriptDisponible(nombre) {
                return .custom(nombreResuelto, size: tamano)
            }
            return .system(size: tamano, weight: pesoFallback, design: designFallback)
        }
    }

    static func nombrePostScriptDisponible(_ nombre: String) -> String? {
        UIFont(name: nombre, size: 17) != nil ? nombre : nil
    }
}

protocol FuenteAjuste: RawRepresentable, CaseIterable, Identifiable, Hashable
where RawValue == String, AllCases: RandomAccessCollection {
    var nombre: String { get }
    var esPredeterminado: Bool { get }
    var especificacion: EspecificacionFuente { get }
}

extension FuenteAjuste {
    var id: String { rawValue }

    func font(tamano: CGFloat, pesoPredeterminado: Font.Weight? = nil) -> Font {
        especificacion.font(
            tamano: tamano,
            pesoOverride: esPredeterminado ? pesoPredeterminado : nil
        )
    }

    func fontLista(tamano: CGFloat = 17, pesoPredeterminado: Font.Weight? = nil) -> Font {
        especificacion.fontLista(
            tamano: tamano,
            pesoOverride: esPredeterminado ? pesoPredeterminado : nil
        )
    }
}

enum FuenteTimerAjuste: String, FuenteAjuste {
    case predeterminado
    case sanFrancisco
    case sfLigera
    case sfRedondeadaMedia
    case sfMono
    case newYork
    case dinAlternate
    case dinCondensed
    case avenirNext
    case avenirNextMedia
    case avenirCondensed
    case futura
    case helveticaNeue
    case helveticaFina
    case menlo

    var esPredeterminado: Bool { self == .predeterminado }

    var nombre: String {
        switch self {
        case .predeterminado: "Predeterminado"
        case .sanFrancisco: "San Francisco"
        case .sfLigera: "SF Ligera"
        case .sfRedondeadaMedia: "SF Redondeada fina"
        case .sfMono: "SF Mono"
        case .newYork: "New York"
        case .dinAlternate: "DIN Alternate"
        case .dinCondensed: "DIN Condensed"
        case .avenirNext: "Avenir Next"
        case .avenirNextMedia: "Avenir Next Media"
        case .avenirCondensed: "Avenir Condensada"
        case .futura: "Futura"
        case .helveticaNeue: "Helvetica Neue"
        case .helveticaFina: "Helvetica Fina"
        case .menlo: "Menlo"
        }
    }

    var especificacion: EspecificacionFuente {
        switch self {
        case .predeterminado:
            .sistema(design: .rounded, peso: .bold)
        case .sanFrancisco:
            .sistema(design: .default, peso: .bold)
        case .sfLigera:
            .sistema(design: .default, peso: .light)
        case .sfRedondeadaMedia:
            .sistema(design: .rounded, peso: .medium)
        case .sfMono:
            .sistema(design: .monospaced, peso: .bold)
        case .newYork:
            .sistema(design: .serif, peso: .bold)
        case .dinAlternate:
            .postScript(nombre: "DINAlternate-Bold", designFallback: .default, pesoFallback: .bold)
        case .dinCondensed:
            .postScript(nombre: "DINCondensed-Bold", designFallback: .default, pesoFallback: .bold)
        case .avenirNext:
            .postScript(nombre: "AvenirNext-Bold", designFallback: .default, pesoFallback: .bold)
        case .avenirNextMedia:
            .postScript(nombre: "AvenirNext-DemiBold", designFallback: .default, pesoFallback: .semibold)
        case .avenirCondensed:
            .postScript(nombre: "AvenirNextCondensed-Bold", designFallback: .default, pesoFallback: .bold)
        case .futura:
            .postScript(nombre: "Futura-Medium", designFallback: .default, pesoFallback: .medium)
        case .helveticaNeue:
            .postScript(nombre: "HelveticaNeue-Bold", designFallback: .default, pesoFallback: .bold)
        case .helveticaFina:
            .postScript(nombre: "HelveticaNeue-Light", designFallback: .default, pesoFallback: .light)
        case .menlo:
            .postScript(nombre: "Menlo-Bold", designFallback: .monospaced, pesoFallback: .bold)
        }
    }
}

enum FuenteScrambleAjuste: String, FuenteAjuste {
    case predeterminado
    case sfMonoRegular
    case sfMonoMedia
    case sfMonoSeminegrita
    case menlo
    case menloNegrita
    case courierNew
    case courierNewNegrita
    case typewriter
    case typewriterCompacta
    case sanFrancisco
    case sfRedondeada
    case avenirNext
    case avenirCompacta
    case helveticaNeue

    var esPredeterminado: Bool { self == .predeterminado }

    var nombre: String {
        switch self {
        case .predeterminado: "Predeterminado"
        case .sfMonoRegular: "SF Mono Regular"
        case .sfMonoMedia: "SF Mono Media"
        case .sfMonoSeminegrita: "SF Mono Seminegrita"
        case .menlo: "Menlo"
        case .menloNegrita: "Menlo Negrita"
        case .courierNew: "Courier New"
        case .courierNewNegrita: "Courier New Negrita"
        case .typewriter: "Typewriter"
        case .typewriterCompacta: "Typewriter Compacta"
        case .sanFrancisco: "San Francisco"
        case .sfRedondeada: "SF Redondeada"
        case .avenirNext: "Avenir Next"
        case .avenirCompacta: "Avenir Compacta"
        case .helveticaNeue: "Helvetica Neue"
        }
    }

    var especificacion: EspecificacionFuente {
        switch self {
        case .predeterminado:
            .sistema(design: .monospaced, peso: .bold)
        case .sfMonoRegular:
            .sistema(design: .monospaced, peso: .regular)
        case .sfMonoMedia:
            .sistema(design: .monospaced, peso: .medium)
        case .sfMonoSeminegrita:
            .sistema(design: .monospaced, peso: .semibold)
        case .menlo:
            .postScript(nombre: "Menlo-Regular", designFallback: .monospaced, pesoFallback: .regular)
        case .menloNegrita:
            .postScript(nombre: "Menlo-Bold", designFallback: .monospaced, pesoFallback: .bold)
        case .courierNew:
            .postScript(nombre: "CourierNewPSMT", designFallback: .monospaced, pesoFallback: .regular)
        case .courierNewNegrita:
            .postScript(nombre: "CourierNewPS-BoldMT", designFallback: .monospaced, pesoFallback: .bold)
        case .typewriter:
            .postScript(nombre: "AmericanTypewriter-Semibold", designFallback: .monospaced, pesoFallback: .semibold)
        case .typewriterCompacta:
            .postScript(nombre: "AmericanTypewriter-CondensedBold", designFallback: .monospaced, pesoFallback: .bold)
        case .sanFrancisco:
            .sistema(design: .default, peso: .semibold)
        case .sfRedondeada:
            .sistema(design: .rounded, peso: .semibold)
        case .avenirNext:
            .postScript(nombre: "AvenirNext-DemiBold", designFallback: .default, pesoFallback: .semibold)
        case .avenirCompacta:
            .postScript(nombre: "AvenirNextCondensed-DemiBold", designFallback: .default, pesoFallback: .semibold)
        case .helveticaNeue:
            .postScript(nombre: "HelveticaNeue-Medium", designFallback: .default, pesoFallback: .medium)
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
        case .amarillo: Color("ReadyColor")
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

enum AjustesInicioCronometro {
    static let claveMantenerParaIniciar = "mantenerParaIniciar"
    static let claveTiempoEspera = "tiempoEspera"
    static let claveColorListo = "colorListo"
    static let claveTamanoScramble = "tamanoScramble"
    static let claveMostrarScramble = "mostrarScramble"
    static let claveTamanoTimer = "tamanoTimer"
    static let claveFuenteTimer = "fuenteTimer"
    static let claveFuenteScramble = "fuenteScramble"
    static let mantenerPredeterminado = true
    static let esperaPredeterminada = 0.5
    static let colorPredeterminado: ColorListoAjuste = .amarillo
    static let tamanoScramblePredeterminado: TamanoScramble = .mediano
    static let mostrarScramblePredeterminado = true
    static let tamanoTimerPredeterminado = 70.0
    static let fuenteTimerPredeterminada: FuenteTimerAjuste = .predeterminado
    static let fuenteScramblePredeterminada: FuenteScrambleAjuste = .predeterminado
    static let rangoEspera = 0.3...1.5
    static let rangoTamanoTimer = 40.0...100.0

    static func esperaValida(_ espera: Double) -> Double {
        min(max(espera, rangoEspera.lowerBound), rangoEspera.upperBound)
    }

    static func tamanoTimerValido(_ tamano: Double) -> Double {
        min(max(tamano.rounded(), rangoTamanoTimer.lowerBound), rangoTamanoTimer.upperBound)
    }
}

// MARK: - Estado local

/// Estado exclusivamente local y en memoria de la pantalla de Ajustes.
/// No se conecta al RubikViewModel ni escribe en disco, UserDefaults o iCloud.
@Observable
final class AjustesEstado {

    // Apariencia
    var idioma: IdiomaAjuste = .sistema

    // Temporizador
    var inspeccion15s = true
    var precision: PrecisionAjuste = .centesimas
    var vibracion = true

    // Datos
    var sincronizarICloud = false

    /// Restablece únicamente el estado de esta pantalla.
    func restablecer() {
        idioma = .sistema
        inspeccion15s = true
        precision = .centesimas
        vibracion = true
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
