import SwiftUI

/// Pantalla de Ajustes con estado local en memoria.
/// No usa RubikViewModel, persistencia propia, iCloud ni idle timer.
struct AjustesView: View {
    @State private var estado = AjustesEstado()
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        NavigationStack {
            List {
                AparienciaSeccion(estado: estado)
                TextoSeccion(estado: estado)
                TemporizadorSeccion(estado: estado)
                DatosSeccion(estado: estado)
                AcercaDeSeccion(version: AjustesInformacionApp.version) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        estado.restablecer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            // Renueva las filas nativas para actualizar también los separadores.
            .id(temaApp)
            .scrollContentBackground(.hidden)
            .background(temaApp.fondo)
            .foregroundStyle(temaApp.texto)
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
            .tint(temaApp.acento)
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
        }
    }
}

#Preview("Ajustes") {
    AjustesView()
}
