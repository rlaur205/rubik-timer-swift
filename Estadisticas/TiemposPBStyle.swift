import SwiftUI

struct TiemposPBStyle: View {
    let titulo: String
    let tiempo: String
    let listaParaMostrar: [Double]
    @Binding var mostrarTiempos: [Double]
    @Binding var arriba: Bool
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Button {
            mostrarTiempos = listaParaMostrar
            arriba = true
        } label: {
            HStack(alignment: .center, spacing: 8) {
                MetricaView(titulo: titulo, valor: tiempo)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(temaApp.texto.opacity(0.65))
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Muestra los tiempos de este récord")
    }
}
