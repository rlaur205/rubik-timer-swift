import SwiftUI

enum AparienciaRetro {
    static let claveActivada = "modoRetro"
    static let claveOscura = "modoRetroOscuro"
}

struct PaletaRetro {
    let oscura: Bool

    var fondo: Color { oscura ? .black : Color(hex: 0xF6F0DD) }
    var papel: Color { oscura ? Color(hex: 0x191919) : Color(hex: 0xFFFBEE) }
    var texto: Color { oscura ? Color(hex: 0xF6F0DD) : tinta }
    var secundario: Color { oscura ? Color(hex: 0xC3C3C3) : Color(hex: 0x53574F) }
    var linea: Color { oscura ? Color(hex: 0xB7B7B7) : tinta }
    var sombra: Color { oscura ? Color(hex: 0x363636) : tinta }
    let tinta = Color(hex: 0x1D2520)
    let lima = Color(hex: 0xD9F369)
    let amarillo = Color(hex: 0xFFD269)
    let lavanda = Color(hex: 0xD9CEFF)
    let menta = Color(hex: 0xA8E7CB)
    let coral = Color(hex: 0xFF907F)
    let naranja = Color(hex: 0xF7A56D)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 255) / 255,
            green: Double((hex >> 8) & 255) / 255,
            blue: Double(hex & 255) / 255
        )
    }
}

private struct PaletaRetroKey: EnvironmentKey {
    static let defaultValue = PaletaRetro(oscura: false)
}

extension EnvironmentValues {
    var retro: PaletaRetro {
        get { self[PaletaRetroKey.self] }
        set { self[PaletaRetroKey.self] = newValue }
    }
}

extension View {
    func cajaRetro(_ relleno: Color? = nil, relieve: Bool = true, radio: CGFloat = 16) -> some View {
        modifier(CajaRetro(relleno: relleno, relieve: relieve, radio: radio))
    }
}

private struct CajaRetro: ViewModifier {
    @Environment(\.retro) private var paleta
    let relleno: Color?
    let relieve: Bool
    let radio: CGFloat

    func body(content: Content) -> some View {
        let forma = RoundedRectangle(cornerRadius: radio, style: .continuous)
        content
            .background(relleno ?? paleta.papel, in: forma)
            .background {
                if relieve {
                    forma.fill(paleta.sombra).offset(x: 3, y: 4)
                }
            }
            .overlay { forma.strokeBorder(paleta.linea, lineWidth: 1.6).allowsHitTesting(false) }
    }
}

struct BotonRetro: ButtonStyle {
    @Environment(\.retro) private var paleta
    @Environment(\.isEnabled) private var habilitado
    var relleno: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .monospaced, weight: .bold))
            .foregroundStyle(relleno == nil ? paleta.texto : paleta.tinta)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .cajaRetro(relleno, relieve: !configuration.isPressed, radio: 12)
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
            .opacity(habilitado ? 1 : 0.45)
    }
}

struct IconoBotonRetro: View {
    let titulo: String
    let icono: String
    var relleno: Color? = nil
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            Image(systemName: icono).frame(minWidth: 19)
        }
        .buttonStyle(BotonRetro(relleno: relleno))
        .accessibilityLabel(titulo)
    }
}

struct SelloRetro: View {
    @Environment(\.retro) private var paleta
    let texto: String
    var color: Color? = nil

    var body: some View {
        Text(texto)
            .font(.system(.caption2, design: .monospaced, weight: .heavy))
            .tracking(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .foregroundStyle(color == nil ? paleta.texto : paleta.tinta)
            .cajaRetro(color, relieve: false, radio: 7)
    }
}

struct EncabezadoRetro<Acciones: View>: View {
    let titulo: String
    var contexto: String? = nil
    @ViewBuilder var acciones: () -> Acciones

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                if let contexto {
                    Text(contexto)
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                }
                Text(titulo)
                    .font(.system(.largeTitle, design: .default, weight: .black))
                    .tracking(-1.5)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 0)
            acciones()
        }
    }
}

struct PantallaRetro<Contenido: View>: View {
    @Environment(\.retro) private var paleta
    @ViewBuilder var contenido: () -> Contenido

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 17, content: contenido)
                .padding(.horizontal, 17)
                .padding(.top, 12)
                .padding(.bottom, 15)
        }
        .background(paleta.fondo)
        .scrollDismissesKeyboard(.interactively)
    }
}

struct PanelRetro<Contenido: View>: View {
    @Environment(\.retro) private var paleta
    let titulo: String
    @ViewBuilder var contenido: () -> Contenido
    @Environment(\.dismiss) private var cerrar

    var body: some View {
        PantallaRetro {
            EncabezadoRetro(titulo: titulo) {
                IconoBotonRetro(titulo: "Cerrar", icono: "xmark", relleno: paleta.amarillo) { cerrar() }
            }
            contenido()
        }
        .padding(.top, 9)
        .foregroundStyle(paleta.texto)
        .background(paleta.fondo.ignoresSafeArea())
        .presentationBackground(paleta.fondo)
    }
}

struct SeccionRetro<Contenido: View>: View {
    let titulo: String
    let color: Color
    @ViewBuilder var contenido: () -> Contenido

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            SelloRetro(texto: titulo, color: color).accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 13, content: contenido)
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cajaRetro()
        }
    }
}

struct VacioRetro: View {
    let icono: String
    let titulo: String
    let mensaje: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icono).font(.title2.weight(.semibold)).accessibilityHidden(true)
            Text(titulo).font(.title3.weight(.black))
            Text(mensaje).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .cajaRetro()
    }
}

struct ConfirmacionRetro: View {
    @Environment(\.retro) private var paleta
    @Environment(\.dismiss) private var cerrar
    let titulo: String
    let mensaje: String
    let accionTitulo: String
    let accion: () -> Void

    var body: some View {
        PanelRetro(titulo: titulo) {
            Text(mensaje).font(.body)
            HStack {
                Button("Cancelar") { cerrar() }.buttonStyle(BotonRetro())
                Spacer()
                Button(accionTitulo, role: .destructive) {
                    accion()
                    cerrar()
                }
                .buttonStyle(BotonRetro(relleno: paleta.coral))
            }
        }
        .presentationDetents([.medium, .large])
    }
}
