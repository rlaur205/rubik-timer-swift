import SwiftUI

struct Item: Identifiable {
    let value: Double
    let indice: Int
    var id: Int { indice }
}

struct EstadisticasView: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.temaApp) private var temaApp
    var actual: [Tiempo] { vm.sesionActual.tiempos }

    private var estiloResumen: EstiloBloqueTema { temaApp.estilo(.resumen) }
    private var estiloPromedios: EstiloBloqueTema { temaApp.estilo(.promedios) }
    private var estiloRecords: EstiloBloqueTema { temaApp.estilo(.records) }
    private var estiloProgreso: EstiloBloqueTema { temaApp.estilo(.progreso) }

    var body: some View {
        NavigationStack {
            List {
                if actual.isEmpty {
                    ContentUnavailableView("Aún no hay estadísticas", systemImage: "chart.xyaxis.line", description: Text("Registra tu primer tiempo en el cronómetro para ver tu progreso."))
                        .foregroundStyle(temaApp.texto)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    Section {
                        TiemposBasicosView(actual: actual)
                            .listRowBackground(FondoBloqueEstadistico(estilo: estiloResumen))
                            .listRowSeparator(.hidden)
                    } header: {
                        EncabezadoBloqueEstadistico(titulo: "Resumen", sistema: "square.grid.2x2.fill", estilo: estiloResumen)
                    }
                    Section {
                        TiemposActualesView(actual: actual)
                            .listRowBackground(FondoBloqueEstadistico(estilo: estiloPromedios))
                            .listRowSeparator(.hidden)
                    } header: {
                        EncabezadoBloqueEstadistico(titulo: "Promedios actuales", sistema: "chart.line.uptrend.xyaxis", estilo: estiloPromedios)
                    }
                    Section {
                        TiemposPBView(actual: actual)
                            .listRowBackground(FondoBloqueEstadistico(estilo: estiloRecords))
                            .listRowSeparator(.hidden)
                    } header: {
                        EncabezadoBloqueEstadistico(titulo: "Récords personales", sistema: "trophy.fill", estilo: estiloRecords)
                    }
                    Section {
                        GraficoProgresoEstadistico(actual: actual, estilo: estiloProgreso)
                            .listRowBackground(FondoBloqueEstadistico(estilo: estiloProgreso))
                            .listRowSeparator(.hidden)
                    } header: {
                        EncabezadoBloqueEstadistico(titulo: "Progreso", sistema: "chart.xyaxis.line", estilo: estiloProgreso)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .id(temaApp)
            .scrollContentBackground(.hidden)
            .background(temaApp.fondo)
            .foregroundStyle(temaApp.texto)
            .navigationTitle("Estadísticas")
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
        }
    }
}

#Preview { ContentView() }
