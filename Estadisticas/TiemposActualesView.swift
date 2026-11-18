import SwiftUI

struct TiemposActualesView: View {
    let actual: [Double]

    var body: some View {
        LazyVGrid(columns: EstiloVisual.columnas, alignment: .leading, spacing: 22) {
            MetricaView(titulo: "Último", valor: EstiloVisual.tiempo(actual.last ?? 0, disponible: !actual.isEmpty))
            MetricaView(titulo: "Mo3", valor: EstiloVisual.tiempo(media(tiempos: actual, cantidad: 3), disponible: actual.count >= 3))
            ForEach([5, 12, 25, 50, 100, 200, 500, 1000], id: \.self) { cantidad in
                MetricaView(titulo: "Ao\(cantidad)", valor: EstiloVisual.tiempo(avg(tiempos: actual, cantidad: cantidad), disponible: actual.count >= cantidad))
            }
        }
        .padding(.vertical, 8)
    }
}
