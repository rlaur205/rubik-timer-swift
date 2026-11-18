import SwiftUI

struct MetricaConDetalle: View {
    let titulo: String
    let tiempo: String
    let disponible: Bool
    var hintDisponible: String = "Muestra los tiempos de esta métrica"
    let accion: () -> Void
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Button(action: accion) {
            HStack(alignment: .center, spacing: 8) {
                MetricaView(titulo: titulo, valor: tiempo)
                if disponible {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                }
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!disponible)
        .accessibilityHint(disponible ? hintDisponible : "Aún no hay suficientes tiempos")
    }
}

struct DetalleTiemposSheet: View {
    let titulo: String
    let tiempos: [Tiempo]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(tiempos.indices, id: \.self) { index in
                        let reversedIndex = tiempos.count - index - 1
                        LabeledContent {
                            Text(tiempos[reversedIndex].texto(largo: true))
                                .font(.title3.weight(.semibold).monospacedDigit())
                                .foregroundStyle(temaApp.texto)
                        } label: {
                            Text("\(index + 1)").foregroundStyle(temaApp.texto.opacity(0.65))
                        }
                        .listRowBackground(temaApp.superficie)
                        .listRowSeparatorTint(temaApp.linea)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .accessibilityIdentifier("detalle-tiempos-estadisticas")
            .id(temaApp)
            .scrollContentBackground(.hidden)
            .background(temaApp.fondo)
            .foregroundStyle(temaApp.texto)
            .navigationTitle(titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(temaApp.fondo)
    }
}
