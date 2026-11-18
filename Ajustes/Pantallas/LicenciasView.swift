import SwiftUI

struct LicenciasView: View {
    var body: some View {
        List {
            Section {
                ContentUnavailableView {
                    Label("Licencias de terceros", systemImage: "doc.text")
                } description: {
                    Text("El listado de dependencias y sus licencias se incorporará en una próxima versión.")
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Licencias de terceros")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LicenciasView()
    }
}
