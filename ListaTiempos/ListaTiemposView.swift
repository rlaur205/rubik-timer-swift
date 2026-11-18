import SwiftUI

struct ListaTiemposView: View {
    private struct DetalleSeleccionado: Identifiable {
        let tiempo: Tiempo
        let categoria: String

        var id: UUID { tiempo.id }
    }

    @ObservedObject var vm: RubikViewModel
    @Environment(\.temaApp) private var temaApp
    @State var manejo = false
    @State var seguridad = false
    @State private var detalleSeleccionado: DetalleSeleccionado?

    var body: some View {
        NavigationStack {
            List {
                if vm.tiemposRecorrer.isEmpty {
                    ContentUnavailableView("Aún no hay tiempos", systemImage: "stopwatch", description: Text("Tus tiempos aparecerán aquí después de tu primera resolución."))
                        .foregroundStyle(temaApp.texto)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    Section {
                        ForEach(vm.tiemposRecorrer, id: \.id) { tiempo in
                            TiempoRowView(tiempo: tiempo) {
                                detalleSeleccionado = DetalleSeleccionado(
                                    tiempo: tiempo,
                                    categoria: tiempo.categoria ?? vm.sesionActual.categoria
                                )
                            }
                                .listRowBackground(temaApp.superficie)
                                .listRowSeparatorTint(temaApp.linea)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .id(temaApp)
            .scrollContentBackground(.hidden)
            .background(temaApp.fondo)
            .foregroundStyle(temaApp.texto)
            .navigationTitle("Tiempos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ordenar", systemImage: "arrow.up.arrow.down") { manejo = true }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Eliminar tiempos", systemImage: "trash", role: .destructive) { seguridad = true }
                }
            }
            .confirmationDialog("Ordenar tiempos", isPresented: $manejo, titleVisibility: .visible) {
                botonOrdenamiento(orden: .fecha)
                botonOrdenamiento(orden: .ascendente)
                botonOrdenamiento(orden: .descendente)
                Button("Cancelar", role: .cancel) {}
            }
            .alert("Eliminar tiempos", isPresented: $seguridad) {
                Button("Eliminar", role: .destructive) { vm.eliminarTodosTiempos() }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Seguro que quieres eliminar TODOS tus tiempos?")
            }
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
            .sheet(item: $detalleSeleccionado) { detalle in
                TiempoDetalleView(
                    tiempo: detalle.tiempo,
                    categoria: detalle.categoria,
                    aplicarPenalizacion: { vm.establecerPenalizacion($0, tiempoID: detalle.id) }
                ) {
                    vm.eliminarTiempoSeleccionado(tiempo: detalle.tiempo)
                    detalleSeleccionado = nil
                }
            }
        }
    }

    func botonOrdenamiento(orden: Orden) -> some View {
        Button(orden.rawValue) { vm.cambiarOrden(orden) }
    }
}

#Preview { ContentView() }
