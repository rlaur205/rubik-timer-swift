import SwiftUI

struct DatosSeccion: View {
    let abrirImportador: () -> Void
    @Environment(\.temaApp) private var temaApp
    @State private var aviso: AjustesAviso?

    var body: some View {
        Section {
            Button {
                aviso = AjustesAviso(
                    titulo: "Función disponible próximamente",
                    mensaje: "Exportar tiempos estará disponible en una próxima versión. Por ahora no se genera ningún archivo ni se modifican tus datos."
                )
            } label: {
                HStack(spacing: 12) {
                    Text("Exportar tiempos")
                        .foregroundStyle(temaApp.texto)
                    Spacer(minLength: 8)
                    Text("JSON")
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(temaApp.texto.opacity(0.4))
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Muestra un aviso de función disponible próximamente")
            .filaTema(temaApp)

            Button(action: abrirImportador) {
                HStack(spacing: 12) {
                    Text("Importar tiempos")
                        .foregroundStyle(temaApp.texto)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(temaApp.texto.opacity(0.4))
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .filaTema(temaApp)
        } header: {
            Text("DATOS")
        }
        .mostrarAviso($aviso)
    }
}

#Preview {
    NavigationStack {
        List {
            DatosSeccion(abrirImportador: {})
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
