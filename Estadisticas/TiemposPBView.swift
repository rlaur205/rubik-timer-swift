import SwiftUI

struct TiemposPBView: View {
    let actual: [Double]
    let sesionActual: Sesion
    @State private var mostrarTiempos: [Double] = []
    @State private var arriba = false

    var body: some View {
        LazyVGrid(columns: EstiloVisual.columnas, alignment: .leading, spacing: 22) {
            TiemposPBStyle(
                titulo: "Mo3",
                tiempo: EstiloVisual.tiempo(media(tiempos: PBmo3(lista: actual), cantidad: 3), disponible: actual.count >= 3),
                listaParaMostrar: PBmo3(lista: actual),
                mostrarTiempos: $mostrarTiempos,
                arriba: $arriba
            )
            ForEach([5, 12, 25, 50, 100, 200, 500, 1000], id: \.self) { cantidad in
                let tiempos = PBavg(tiempos: actual, x: cantidad)
                TiemposPBStyle(
                    titulo: "Ao\(cantidad)",
                    tiempo: EstiloVisual.tiempo(avg(tiempos: tiempos, cantidad: cantidad), disponible: actual.count >= cantidad),
                    listaParaMostrar: tiempos,
                    mostrarTiempos: $mostrarTiempos,
                    arriba: $arriba
                )
            }
            MetricaView(titulo: "Desviación", valor: actual.count >= 2 ? desviacion(valores: actual) : "—")
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $arriba) {
            NavigationStack {
                List {
                    Section {
                        ForEach(mostrarTiempos.indices, id: \.self) { index in
                            let reversedIndex = mostrarTiempos.count - index - 1
                            LabeledContent {
                                Text(formatoTiempo(mostrarTiempos[reversedIndex]))
                                    .font(.title3.weight(.semibold).monospacedDigit())
                                    .foregroundStyle(.primary)
                            } label: {
                                Text("\(index + 1)").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Tiempos del récord")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") { arriba = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}
