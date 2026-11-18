import SwiftUI

// MARK: - Tema de la app

enum TemaApp: String, CaseIterable, Identifiable, Hashable {
    case claro
    case oscuro
    case azulNoche
    case bosque
    case atardecer
    case cosmico
    case oceano
    case arena

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .claro: "Claro"
        case .oscuro: "Oscuro"
        case .azulNoche: "Azul noche"
        case .bosque: "Bosque"
        case .atardecer: "Atardecer"
        case .cosmico: "Cósmico"
        case .oceano: "Océano"
        case .arena: "Arena"
        }
    }

    var fondo: Color {
        switch self {
        case .claro: Color(hex: 0xF2F2F7)
        case .oscuro: Color(hex: 0x000000)
        case .azulNoche: Color(hex: 0x0B1730)
        case .bosque: Color(hex: 0x0F1F17)
        case .atardecer: Color(hex: 0x2A1620)
        case .cosmico: Color(hex: 0x0A0618)
        case .oceano: Color(hex: 0x06202B)
        case .arena: Color(hex: 0xF6EFE3)
        }
    }

    var superficie: Color {
        switch self {
        case .claro: Color(hex: 0xFFFFFF)
        case .oscuro: Color(hex: 0x1C1C1E)
        case .azulNoche: Color(hex: 0x13254A)
        case .bosque: Color(hex: 0x183327)
        case .atardecer: Color(hex: 0x40222F)
        case .cosmico: Color(hex: 0x1A0F33)
        case .oceano: Color(hex: 0x0C3445)
        case .arena: Color(hex: 0xFFFBF3)
        }
    }

    var linea: Color {
        switch self {
        case .claro: Color(hex: 0xD1D1D6)
        case .oscuro: Color(hex: 0x3A3A3C)
        case .azulNoche: Color(hex: 0x2B4A85)
        case .bosque: Color(hex: 0x2F6B4A)
        case .atardecer: Color(hex: 0xC2634A)
        case .cosmico: Color(hex: 0x5B2FB8)
        case .oceano: Color(hex: 0x1E6A80)
        case .arena: Color(hex: 0xDCCBB0)
        }
    }

    var acento: Color {
        switch self {
        case .claro, .oscuro: Color(hex: 0x32ADE6)
        case .azulNoche: Color(hex: 0x5AA9FF)
        case .bosque: Color(hex: 0x5FD38D)
        case .atardecer: Color(hex: 0xFF8A5C)
        case .cosmico: Color(hex: 0xC77DFF)
        case .oceano: Color(hex: 0x2DD4BF)
        case .arena: Color(hex: 0xC2703A)
        }
    }

    var texto: Color {
        switch self {
        case .claro: Color(hex: 0x000000)
        case .oscuro: Color(hex: 0xFFFFFF)
        case .azulNoche: Color(hex: 0xE8EEFF)
        case .bosque: Color(hex: 0xE6F4EA)
        case .atardecer: Color(hex: 0xFFE9E0)
        case .cosmico: Color(hex: 0xF1E9FF)
        case .oceano: Color(hex: 0xE0F7FA)
        case .arena: Color(hex: 0x2B2118)
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .claro, .arena: .light
        default: .dark
        }
    }
}

// MARK: - Entorno

private struct TemaAppKey: EnvironmentKey {
    static let defaultValue: TemaApp = .claro
}

extension EnvironmentValues {
    var temaApp: TemaApp {
        get { self[TemaAppKey.self] }
        set { self[TemaAppKey.self] = newValue }
    }
}

// MARK: - Estilo de fila

extension View {
    func filaTema(_ tema: TemaApp) -> some View {
        listRowBackground(tema.superficie)
            .listRowSeparatorTint(tema.linea)
    }
}

// MARK: - Color desde HEX

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
