import SwiftUI

struct TiemposBasicosView: View {
    let actual: [Double]

    var body: some View {
        LazyVGrid(columns: EstiloVisual.columnas, alignment: .leading, spacing: 22) {
            MetricaView(titulo: "Solves", valor: "\(actual.count)")
            MetricaView(titulo: "Media", valor: EstiloVisual.tiempo(media(tiempos: actual, cantidad: actual.count), disponible: !actual.isEmpty))
            MetricaView(titulo: "Mejor tiempo", valor: EstiloVisual.tiempo(actual.min() ?? 0, disponible: !actual.isEmpty), color: EstiloVisual.mejor)
            MetricaView(titulo: "Peor tiempo", valor: EstiloVisual.tiempo(actual.max() ?? 0, disponible: !actual.isEmpty), color: EstiloVisual.peligro)
        }
        .padding(.vertical, 8)
    }
}
