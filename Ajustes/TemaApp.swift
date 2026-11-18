import SwiftUI
import UIKit

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
    case glaciar
    case lavanda
    case aurora
    case eclipse
    case sakura
    case menta
    case grafito
    case volcan

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .claro: "Claro"
        case .oscuro: "Oscuro"
        case .azulNoche: "Noche"
        case .bosque: "Bosque"
        case .atardecer: "Atardecer"
        case .cosmico: "Cósmico"
        case .oceano: "Océano"
        case .arena: "Arena"
        case .glaciar: "Glaciar"
        case .lavanda: "Lavanda"
        case .aurora: "Aurora"
        case .eclipse: "Eclipse"
        case .sakura: "Sakura"
        case .menta: "Menta"
        case .grafito: "Grafito"
        case .volcan: "Volcán"
        }
    }

    var fondo: Color {
        switch self {
        case .claro: Color(hex: 0xF2F2F7)
        case .oscuro: Color(hex: 0x000000)
        case .azulNoche: Color(hex: 0x02050E)
        case .bosque: Color(hex: 0x0F1F17)
        case .atardecer: Color(hex: 0x493518)
        case .cosmico: Color(hex: 0x0A0618)
        case .oceano: Color(hex: 0x06202B)
        case .arena: Color(hex: 0xF6EFE3)
        case .glaciar: Color(hex: 0xD2EAF8)
        case .lavanda: Color(hex: 0xEAE0F5)
        case .aurora: Color(hex: 0x211D38)
        case .eclipse: Color(hex: 0x221819)
        case .sakura: Color(hex: 0xFBF0F3)
        case .menta: Color(hex: 0xEEF7F3)
        case .grafito: Color(hex: 0x424247)
        case .volcan: Color(hex: 0x1A0B0B)
        }
    }

    var superficie: Color {
        switch self {
        case .claro: Color(hex: 0xFFFFFF)
        case .oscuro: Color(hex: 0x1C1C1E)
        case .azulNoche: Color(hex: 0x080F20)
        case .bosque: Color(hex: 0x183327)
        case .atardecer: Color(hex: 0x594321)
        case .cosmico: Color(hex: 0x1A0F33)
        case .oceano: Color(hex: 0x0C3445)
        case .arena: Color(hex: 0xFFFBF3)
        case .glaciar: Color(hex: 0xEDF8FF)
        case .lavanda: Color(hex: 0xF8F1FE)
        case .aurora: Color(hex: 0x312A49)
        case .eclipse: Color(hex: 0x352728)
        case .sakura: Color(hex: 0xFFFFFF)
        case .menta: Color(hex: 0xFFFFFF)
        case .grafito: Color(hex: 0x505057)
        case .volcan: Color(hex: 0x2E1414)
        }
    }

    var linea: Color {
        switch self {
        case .claro: Color(hex: 0xD1D1D6)
        case .oscuro: Color(hex: 0x3A3A3C)
        case .azulNoche: Color(hex: 0x20365B)
        case .bosque: Color(hex: 0x2F6B4A)
        case .atardecer: Color(hex: 0x8A6A32)
        case .cosmico: Color(hex: 0x5B2FB8)
        case .oceano: Color(hex: 0x1E6A80)
        case .arena: Color(hex: 0xDCCBB0)
        case .glaciar: Color(hex: 0x9DC8DF)
        case .lavanda: Color(hex: 0xCDB7DF)
        case .aurora: Color(hex: 0x56466F)
        case .eclipse: Color(hex: 0x684741)
        case .sakura: Color(hex: 0xF0CCD7)
        case .menta: Color(hex: 0xC8E3D6)
        case .grafito: Color(hex: 0x73737A)
        case .volcan: Color(hex: 0x7A2A1E)
        }
    }

    var acento: Color {
        switch self {
        case .claro, .oscuro: Color(hex: 0x32ADE6)
        case .azulNoche: Color(hex: 0x5AA9FF)
        case .bosque: Color(hex: 0x5FD38D)
        case .atardecer: Color(hex: 0xF5C66C)
        case .cosmico: Color(hex: 0xC77DFF)
        case .oceano: Color(hex: 0x2DD4BF)
        case .arena: Color(hex: 0xC2703A)
        case .glaciar: Color(hex: 0x23668C)
        case .lavanda: Color(hex: 0x77488F)
        case .aurora: Color(hex: 0xA9DFC3)
        case .eclipse: Color(hex: 0xEAAE83)
        case .sakura: Color(hex: 0xD6457A)
        case .menta: Color(hex: 0x1FA37A)
        case .grafito: Color(hex: 0xFFB020)
        case .volcan: Color(hex: 0xFF5A36)
        }
    }

    var texto: Color {
        switch self {
        case .claro: Color(hex: 0x000000)
        case .oscuro: Color(hex: 0xFFFFFF)
        case .azulNoche: Color(hex: 0xE8EEFF)
        case .bosque: Color(hex: 0xE6F4EA)
        case .atardecer: Color(hex: 0xFFF1D5)
        case .cosmico: Color(hex: 0xF1E9FF)
        case .oceano: Color(hex: 0xE0F7FA)
        case .arena: Color(hex: 0x2B2118)
        case .glaciar: Color(hex: 0x152F43)
        case .lavanda: Color(hex: 0x33243F)
        case .aurora: Color(hex: 0xF3EEFC)
        case .eclipse: Color(hex: 0xFCEDE3)
        case .sakura: Color(hex: 0x331620)
        case .menta: Color(hex: 0x12261E)
        case .grafito: Color(hex: 0xF2F2F4)
        case .volcan: Color(hex: 0xFFE8E2)
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .claro, .arena, .glaciar, .lavanda, .sakura, .menta: .light
        default: .dark
        }
    }

    /// Color de texto (.black o .white) con mayor contraste WCAG sobre `acento`.
    var textoSobreAcento: Color {
        acento.textoContraste
    }

    // MARK: - Bloques de estadísticas

    private var paletaBloques: [(superficie: UInt32, acento: UInt32)] {
        switch self {
        case .claro:
            [(0xEAF4FC, 0x2F6F9C), (0xEAF5F0, 0x2E7163), (0xF2EDF9, 0x78589D), (0xFCF3E7, 0x94642C)]
        case .oscuro:
            [(0x172B37, 0x78B8D5), (0x192E2B, 0x7CB6A5), (0x2A2236, 0xB39ACF), (0x332A20, 0xD2B080)]
        case .azulNoche:
            [(0x0B1732, 0x83B8F0), (0x17383F, 0x78BCB6), (0x302A49, 0xB7A1D8), (0x202E43, 0x9AAEC9)]
        case .bosque:
            [(0x193B2D, 0x7AC79D), (0x303B25, 0xA9BE79), (0x3B3322, 0xD3B67C), (0x1B3538, 0x80B6B8)]
        case .atardecer:
            [(0x5E4527, 0xF9D58A), (0x544138, 0xF4BAA5), (0x594C30, 0xF6DCA3), (0x45483A, 0xD2D7A3)]
        case .cosmico:
            [(0x281944, 0xC2A0E6), (0x1C2B43, 0x8FAED8), (0x3A2440, 0xD5A0C3), (0x19343E, 0x82BDC7)]
        case .oceano:
            [(0x103B4A, 0x81C3D5), (0x123D37, 0x84C6AF), (0x203451, 0x9BAFDC), (0x3A382B, 0xD1C18E)]
        case .arena:
            [(0xFCF0DF, 0x8C5C31), (0xECF0E0, 0x5D703D), (0xF4E6DF, 0x965E4E), (0xE6EEF0, 0x466B77)]
        case .glaciar:
            [(0xC9E3F5, 0x245B82), (0xD8EEE9, 0x32675A), (0xE4E7F8, 0x55528A), (0xD3E9F1, 0x276270)]
        case .lavanda:
            [(0xE5D5F1, 0x6E4183), (0xF0E0EB, 0x874765), (0xEAE2F5, 0x5E518E), (0xE5E9F5, 0x485D80)]
        case .aurora:
            [(0x332C50, 0xC7B5F6), (0x263C3D, 0x9AD8BE), (0x453146, 0xE1B0D7), (0x303A51, 0xA7C5F2)]
        case .eclipse:
            [(0x402E2B, 0xE9AF8D), (0x3A2839, 0xDCA7C9), (0x423627, 0xE0C488), (0x2B3539, 0x9BC2CA)]
        case .sakura:
            [(0xF8E1E9, 0x993052), (0xF5E7EF, 0x82456D), (0xF9EADD, 0x8A523F), (0xF0E7F5, 0x6E4B87)]
        case .menta:
            [(0xDCF2E8, 0x256B53), (0xE3F1F2, 0x276775), (0xEDF0E0, 0x58652F), (0xE6F0F7, 0x3C6180)]
        case .grafito:
            [(0x51483C, 0xF9D193), (0x454E58, 0xBBD5ED), (0x524A59, 0xDBC8EA), (0x45534E, 0xB8DECB)]
        case .volcan:
            [(0x431C18, 0xFFA086), (0x3B231C, 0xE9AE82), (0x40232E, 0xE9A1B6), (0x3B2B20, 0xF4C48B)]
        }
    }

    /// Superficie, acento y borde curados para cada rol de bloque de estadísticas.
    func estilo(_ rol: BloqueTema) -> EstiloBloqueTema {
        let paleta = paletaBloques[rol.rawValue]
        return EstiloBloqueTema(
            superficie: Color(hex: paleta.superficie),
            acento: Color(hex: paleta.acento)
        )
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

// MARK: - Color desde HEX y contraste

private extension Color {
    var textoContraste: Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return .white
        }
        func linealizar(_ componente: CGFloat) -> Double {
            let valor = min(max(Double(componente), 0), 1)
            return valor <= 0.04045 ? valor / 12.92 : pow((valor + 0.055) / 1.055, 2.4)
        }
        let luminancia = 0.2126 * linealizar(r) + 0.7152 * linealizar(g) + 0.0722 * linealizar(b)
        let contrasteBlanco = 1.05 / (luminancia + 0.05)
        let contrasteNegro = (luminancia + 0.05) / 0.05
        return contrasteNegro > contrasteBlanco ? .black : .white
    }

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
