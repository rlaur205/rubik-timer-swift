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

enum TipoPromedioEstadistico: Identifiable, Equatable {
    case mo3
    case ao(Int)

    var id: String { titulo }

    var titulo: String {
        switch self {
        case .mo3: "Mo3"
        case .ao(let cantidad): "Ao\(cantidad)"
        }
    }
}

struct DetalleTiemposSheet: View {
    let promedio: TipoPromedioEstadistico
    let categoria: String
    let tiempos: [Tiempo]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.temaApp) private var temaApp
    @State private var seleccionado: Tiempo?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(tiempos.reversed()) { tiempo in
                        TiempoRowView(tiempo: tiempo) { seleccionado = tiempo }
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
            .navigationTitle(promedio.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
            .toolbar {
                if case .ao = promedio {
                    ToolbarItem(placement: .principal) {
                        encabezadoAo
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(temaApp.fondo)
        .sheet(item: $seleccionado) { tiempo in
            TiempoDetalleView(tiempo: tiempo, categoria: tiempo.categoria ?? categoria)
        }
    }

    private var encabezadoAo: some View {
        let extremos = extremosAo(tiempos: tiempos)

        return HStack(spacing: 6) {
            Text(promedio.titulo)
                .font(.headline)
                .foregroundStyle(temaApp.texto)
                .accessibilityAddTraits(.isHeader)
            insignia("Peor tiempo", tiempo: extremos.peor, color: EstiloVisual.peligro)
            insignia("Mejor tiempo", tiempo: extremos.mejor, color: EstiloVisual.mejor)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.65)
    }

    private func insignia(_ titulo: String, tiempo: Tiempo?, color: Color) -> some View {
        Text(tiempo?.texto(largo: false) ?? "—")
            .font(.caption.weight(.semibold).monospacedDigit())
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
            .accessibilityLabel("\(titulo), \(tiempo?.texto(largo: true) ?? "sin tiempo válido")")
    }
}
