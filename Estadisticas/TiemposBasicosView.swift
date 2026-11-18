import SwiftUI

struct TiemposBasicosView: View {
    let actual: [Tiempo]

    var body: some View {
        LazyVGrid(columns: EstiloVisual.columnas, alignment: .leading, spacing: 22) {
            MetricaView(titulo: "Solves", valor: "\(actual.count)")
            MetricaView(titulo: "Media", valor: EstiloVisual.promedio(mediaTotal(tiempos: actual)))
            MetricaView(titulo: "Mejor tiempo", valor: mejorTiempo(tiempos: actual)?.texto(largo: true) ?? "—", color: EstiloVisual.mejor)
            MetricaView(titulo: "Peor tiempo", valor: peorTiempo(tiempos: actual)?.texto(largo: true) ?? "—", color: EstiloVisual.peligro)
        }
        .padding(.vertical, 8)
    }
}
