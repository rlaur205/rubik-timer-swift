import SwiftUI

struct TiemposPBView: View {
    let actual: [Tiempo]
    let categoria: String
    @State private var recordSeleccionado: TipoPromedioEstadistico?

    private var pbMo3: ResultadoPB { PBmo3(tiempos: actual) }

    var body: some View {
        LazyVGrid(columns: EstiloVisual.columnas, alignment: .leading, spacing: 22) {
            MetricaConDetalle(
                titulo: "Mo3",
                tiempo: EstiloVisual.promedio(pbMo3.resultado),
                disponible: !pbMo3.tiempos.isEmpty,
                hintDisponible: "Muestra los tiempos de este récord"
            ) {
                recordSeleccionado = .mo3
            }
            ForEach([5, 12, 25, 50, 100, 200, 500, 1000], id: \.self) { cantidad in
                let pb = PBavg(tiempos: actual, cantidad: cantidad)
                MetricaConDetalle(
                    titulo: "Ao\(cantidad)",
                    tiempo: EstiloVisual.promedio(pb.resultado),
                    disponible: !pb.tiempos.isEmpty,
                    hintDisponible: "Muestra los tiempos de este récord"
                ) {
                    recordSeleccionado = .ao(cantidad)
                }
            }
            MetricaView(titulo: "Desviación", valor: desviacion(tiempos: actual))
        }
        .padding(.vertical, 8)
        .sheet(item: $recordSeleccionado) { record in
            DetalleTiemposSheet(
                promedio: record,
                categoria: categoria,
                tiempos: detalleRecord(record)
            )
        }
    }

    private func detalleRecord(_ record: TipoPromedioEstadistico) -> [Tiempo] {
        switch record {
        case .mo3:
            return PBmo3(tiempos: actual).tiempos
        case .ao(let cantidad):
            return PBavg(tiempos: actual, cantidad: cantidad).tiempos
        }
    }
}
