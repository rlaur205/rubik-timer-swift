import SwiftUI

struct DatosSeccion: View {
    @Bindable var estado: AjustesEstado
    @State private var aviso: AjustesAviso?

    var body: some View {
        Section {
            AjustesToggleFila(
                sistema: "icloud.fill",
                color: .blue,
                titulo: "Sincronizar con iCloud",
                subtitulo: "Guarda tus sesiones en tu cuenta",
                estaActivo: activarICloud
            )

            Button {
                aviso = AjustesAviso(
                    titulo: "Función disponible próximamente",
                    mensaje: "Exportar tiempos estará disponible en una próxima versión. Por ahora no se genera ningún archivo ni se modifican tus datos."
                )
            } label: {
                HStack(spacing: 12) {
                    AjustesIcono(sistema: "square.and.arrow.up", color: .green)
                    Text("Exportar tiempos")
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    Text("JSON")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Muestra un aviso de función disponible próximamente")

            Button {
                aviso = AjustesAviso(
                    titulo: "Función disponible próximamente",
                    mensaje: "Importar tiempos estará disponible en una próxima versión. Por ahora no se lee ningún archivo ni se modifican tus datos."
                )
            } label: {
                HStack(spacing: 12) {
                    AjustesIcono(sistema: "square.and.arrow.down", color: .blue)
                    Text("Importar tiempos")
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Muestra un aviso de función disponible próximamente")
        } header: {
            Text("DATOS")
        } footer: {
            Text("Al importar se combinan los tiempos sin borrar los actuales.")
        }
        .mostrarAviso($aviso)
    }

    /// El interruptor es solo visual: no hay cuenta, archivo ni sincronización real.
    private var activarICloud: Binding<Bool> {
        Binding(
            get: { estado.sincronizarICloud },
            set: { nuevoValor in
                estado.sincronizarICloud = nuevoValor
                if nuevoValor {
                    aviso = AjustesAviso(
                        titulo: "Función disponible próximamente",
                        mensaje: "La sincronización con iCloud estará disponible en una próxima versión. Este interruptor no guarda ni sincroniza ningún dato."
                    )
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        List {
            DatosSeccion(estado: AjustesEstado())
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
