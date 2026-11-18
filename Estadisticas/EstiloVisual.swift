import SwiftUI

/// Presentación compartida; los cálculos y los datos permanecen en sus modelos originales.
enum EstiloVisual {
    static let acento = Color.accentColor
    static let mejor = Color("BestTimeColor")
    static let peligro = Color("DestructiveColor")
    static let preparado = Color("ReadyColor")
    static let fondo = Color(uiColor: .systemGroupedBackground)
    static let superficie = Color(uiColor: .secondarySystemGroupedBackground)
    static let columnas = [GridItem(.adaptive(minimum: 125), spacing: 20)]

    static func tiempo(_ valor: Double, disponible: Bool = true) -> String {
        disponible ? String(formatoTiempo(valor).dropLast()) : "—"
    }
}

struct MetricaView: View {
    let titulo: String
    let valor: String
    var color: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.subheadline.weight(.semibold)).foregroundStyle(.primary.opacity(0.75))
            Text(valor)
                .font(.system(.title, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

extension View {
    @ViewBuilder
    func accionPrincipal() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}
