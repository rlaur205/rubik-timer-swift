import SwiftUI

struct LicenciasView: View {
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        List {
            Section {
                ContentUnavailableView {
                    Label("Licencias de terceros", systemImage: "doc.text")
                } description: {
                    Text("El listado de dependencias y sus licencias se incorporará en una próxima versión.")
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(temaApp.linea)
            }
        }
        .listStyle(.insetGrouped)
        .id(temaApp)
        .scrollContentBackground(.hidden)
        .background(temaApp.fondo)
        .foregroundStyle(temaApp.texto)
        .navigationTitle("Licencias de terceros")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(temaApp.fondo, for: .navigationBar)
        .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        LicenciasView()
    }
}
