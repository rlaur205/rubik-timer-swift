import SwiftUI

private enum TipoPromedioActual: Identifiable, Equatable {
    case mo3
    case ao(Int)

    var id: String {
        switch self {
        case .mo3:
            return "mo3"
        case .ao(let cantidad):
            return "ao\(cantidad)"
        }
    }

    var tituloHoja: String {
        switch self {
        case .mo3:
            return "Tiempos de Mo3"
        case .ao(let cantidad):
            return "Tiempos de Ao\(cantidad)"
        }
    }
}

struct TiemposActualesView: View {
    let actual: [Tiempo]
    @State private var promedioSeleccionado: TipoPromedioActual?

    var body: some View {
        LazyVGrid(columns: EstiloVisual.columnas, alignment: .leading, spacing: 22) {
            MetricaView(
                titulo: "Último",
                valor: actual.last?.texto(largo: false) ?? "—"
            )
            MetricaConDetalle(
                titulo: "Mo3",
                tiempo: EstiloVisual.promedio(mo3(tiempos: actual)),
                disponible: actual.count >= 3,
                hintDisponible: "Muestra los tiempos de este promedio"
            ) {
                promedioSeleccionado = .mo3
            }
            ForEach([5, 12, 25, 50, 100, 200, 500, 1000], id: \.self) { cantidad in
                MetricaConDetalle(
                    titulo: "Ao\(cantidad)",
                    tiempo: EstiloVisual.promedio(avg(tiempos: actual, cantidad: cantidad)),
                    disponible: actual.count >= cantidad,
                    hintDisponible: "Muestra los tiempos de este promedio"
                ) {
                    promedioSeleccionado = .ao(cantidad)
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(item: $promedioSeleccionado) { promedio in
            DetalleTiemposSheet(
                titulo: promedio.tituloHoja,
                tiempos: detallePromedio(promedio)
            )
        }
    }

    private func detallePromedio(_ promedio: TipoPromedioActual) -> [Tiempo] {
        switch promedio {
        case .mo3:
            return actual.count >= 3 ? Array(actual.suffix(3)) : []
        case .ao(let cantidad):
            return actual.count >= cantidad ? Array(actual.suffix(cantidad)) : []
        }
    }
}
