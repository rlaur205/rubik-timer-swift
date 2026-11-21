import SwiftUI

enum VistaHistorialTiempo {
    static let claveCuadricula = "mostrarTiemposEnCuadricula"

    static func icono(muestraCuadricula: Bool) -> String {
        muestraCuadricula ? "list.bullet" : "square.grid.3x3"
    }

    static func accion(muestraCuadricula: Bool) -> String {
        muestraCuadricula ? "Mostrar lista" : "Mostrar cuadrícula"
    }
}

struct CuadriculaTiempos: View {
    let tiempos: [Tiempo]
    var estiloRetro = false
    let abrirDetalle: (Tiempo) -> Void

    @Environment(\.dynamicTypeSize) private var tipoDinamico
    @Environment(\.temaApp) private var tema
    @Environment(\.retro) private var paleta
    @ScaledMetric(relativeTo: .title3) private var anchoAccesible = 92.0

    private var columnas: [GridItem] {
        if tipoDinamico.isAccessibilitySize {
            return [GridItem(.adaptive(minimum: anchoAccesible), spacing: 10)]
        }
        return Array(repeating: GridItem(.flexible(minimum: 0), spacing: 10), count: 3)
    }

    var body: some View {
        LazyVGrid(columns: columnas, spacing: 10) {
            ForEach(tiempos) { tiempo in
                Button {
                    abrirDetalle(tiempo)
                } label: {
                    tarjeta(tiempo)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(tiempo.texto(largo: true)), \(formatoFecha(tiempo.fecha))")
            }
        }
    }

    private func tarjeta(_ tiempo: Tiempo) -> some View {
        let rellenoRetro = switch tiempo.penalizacion {
        case .ninguna: Color?.none
        case .masDos: paleta.amarillo
        case .dnf: paleta.coral
        }
        let texto = estiloRetro ? (rellenoRetro == nil ? paleta.texto : paleta.tinta) : tema.texto
        let fecha = estiloRetro ? (rellenoRetro == nil ? paleta.secundario : paleta.tinta) : tema.texto.opacity(0.75)

        return VStack(alignment: .leading, spacing: 4) {
            Text(tiempo.fecha.formatted(.dateTime.day(.twoDigits).month(.twoDigits).locale(Locale(identifier: "es_ES"))))
                .font(.system(.caption2, design: estiloRetro ? .monospaced : .default, weight: .medium))
                .foregroundStyle(fecha)
            Text(tiempo.texto(largo: false))
                .font(.system(.title3, design: estiloRetro ? .monospaced : .rounded, weight: estiloRetro ? .black : .bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(texto)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
        .modifier(FondoTarjetaTiempo(estiloRetro: estiloRetro, rellenoRetro: rellenoRetro))
        .contentShape(Rectangle())
    }
}

private struct FondoTarjetaTiempo: ViewModifier {
    let estiloRetro: Bool
    let rellenoRetro: Color?
    @Environment(\.temaApp) private var tema

    func body(content: Content) -> some View {
        if estiloRetro {
            content.cajaRetro(rellenoRetro, radio: 10, desplazamiento: 2)
        } else {
            let forma = RoundedRectangle(cornerRadius: 14)
            content
                .background(tema.superficie, in: forma)
                .overlay { forma.strokeBorder(tema.linea, lineWidth: 1).allowsHitTesting(false) }
        }
    }
}
