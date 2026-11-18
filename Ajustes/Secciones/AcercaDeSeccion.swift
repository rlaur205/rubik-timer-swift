import SwiftUI

struct AcercaDeSeccion: View {
    let version: String
    let restablecer: () -> Void

    @Environment(\.temaApp) private var temaApp
    @State private var confirmarRestablecer = false

    var body: some View {
        Section {
            AjustesFilaValor(
                sistema: "info.circle.fill",
                color: .gray,
                titulo: "Versión",
                valor: version
            )
            .filaTema(temaApp)

            NavigationLink {
                LicenciasView()
            } label: {
                HStack(spacing: 12) {
                    AjustesIcono(sistema: "doc", color: .gray)
                    Text("Licencias de terceros")
                }
            }
            .filaTema(temaApp)

            Button {
                confirmarRestablecer = true
            } label: {
                HStack(spacing: 12) {
                    Text("Restablecer ajustes")
                        .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Pide confirmación antes de restablecer los ajustes de esta pantalla")
            .filaTema(temaApp)
        } header: {
            Text("ACERCA DE")
        }
        .confirmationDialog(
            "¿Restablecer los ajustes?",
            isPresented: $confirmarRestablecer,
            titleVisibility: .visible
        ) {
            Button("Restablecer ajustes", role: .destructive) {
                restablecer()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Se restaurarán los valores predeterminados de esta pantalla. No se modifican tus tiempos ni tus sesiones.")
        }
    }
}

#Preview {
    NavigationStack {
        List {
            AcercaDeSeccion(version: "1.0 (1)", restablecer: { })
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
