import SwiftUI

/// Presentación compartida; los cálculos y los datos permanecen en sus modelos originales.
enum EstiloVisual {
    static let mejor = Color("BestTimeColor")
    static let peligro = Color("DestructiveColor")
    static let columnas = [GridItem(.adaptive(minimum: 125), spacing: 20)]

    static func promedio(_ resultado: ResultadoPromedio) -> String {
        switch resultado {
        case .insuficiente:
            return "—"
        case .valor(let valor):
            return String(formatoTiempo(valor).dropLast())
        case .dnf:
            return "DNF"
        }
    }
}

struct MetricaView: View {
    let titulo: String
    let valor: String
    var color: Color?

    @Environment(\.temaApp) private var temaApp

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.subheadline.weight(.semibold)).foregroundStyle(temaApp.texto.opacity(0.65))
            Text(valor)
                .font(.system(.title, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(color ?? temaApp.texto)
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
