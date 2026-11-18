import SwiftUI

/// Pantalla de Ajustes con estado local en memoria.
/// No usa RubikViewModel, persistencia, iCloud, tema global ni idle timer.
struct AjustesView: View {
    @State private var estado = AjustesEstado()

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
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
            .tint(EstiloVisual.acento)
        }
    }
}

#Preview("Ajustes") {
    AjustesView()
}
