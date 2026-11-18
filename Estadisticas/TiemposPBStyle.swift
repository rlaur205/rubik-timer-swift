import SwiftUI

struct TiemposPBStyle: View {
    let titulo: String
    let tiempo: String
    let listaParaMostrar: [Double]
    @Binding var mostrarTiempos: [Double]
    @Binding var arriba: Bool

    var body: some View {
        Button {
            mostrarTiempos = listaParaMostrar
            arriba = true
        } label: {
            HStack(alignment: .center, spacing: 8) {
                MetricaView(titulo: titulo, valor: tiempo)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Muestra los tiempos de este récord")
    }
}
