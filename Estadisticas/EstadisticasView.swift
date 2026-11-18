import SwiftUI
import Charts

struct Item: Identifiable {
    var id = UUID()
    var value: Double
    var fecha: String
}

struct EstadisticasView: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.temaApp) private var temaApp
    var actual: [Double] { obtenerTiempos(sesion: vm.sesionActual) }

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
                            .listRowBackground(temaApp.superficie)
                            .listRowSeparatorTint(temaApp.linea)
                    } header: {
                        Text("Resumen").font(.headline.weight(.bold)).foregroundStyle(temaApp.acento)
                    }
                    Section {
                        TiemposActualesView(actual: actual)
                            .listRowBackground(temaApp.superficie)
                            .listRowSeparatorTint(temaApp.linea)
                    } header: {
                        Text("Promedios actuales").font(.headline.weight(.bold)).foregroundStyle(EstiloVisual.mejor)
                    }
                    Section {
                        TiemposPBView(actual: actual, sesionActual: vm.sesionActual)
                            .listRowBackground(temaApp.superficie)
                            .listRowSeparatorTint(temaApp.linea)
                    } header: {
                        Label("Récords personales", systemImage: "trophy").font(.headline.weight(.bold)).foregroundStyle(.purple)
                    }
                    Section("Progreso") {
                        Chart(grafica(valores: actual)) { item in
                            LineMark(x: .value("Resolución", Int(item.fecha) ?? 0), y: .value("Segundos", item.value))
                                .foregroundStyle(temaApp.acento)
                            PointMark(x: .value("Resolución", Int(item.fecha) ?? 0), y: .value("Segundos", item.value))
                                .foregroundStyle(temaApp.acento)
                                .symbolSize(12)
                        }
                        .chartXAxis { AxisMarks(values: .automatic(desiredCount: 5)) }
                        .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) }
                        .chartXAxisLabel("Resolución")
                        .chartYAxisLabel("Segundos")
                        .frame(height: 200)
                        .padding(.vertical, 12)
                        .accessibilityLabel("Progreso de los tiempos de la sesión")
                        .listRowBackground(temaApp.superficie)
                        .listRowSeparatorTint(temaApp.linea)
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
