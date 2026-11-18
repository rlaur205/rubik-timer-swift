import SwiftUI

struct AjustesView: View {
    @State private var estado = AjustesEstado()
    @State private var mostrarSelectorTema = false
    @AppStorage(AjustesInicioCronometro.claveMantenerParaIniciar)
    private var mantenerParaIniciar = AjustesInicioCronometro.mantenerPredeterminado
    @AppStorage(AjustesInicioCronometro.claveTiempoEspera)
    private var tiempoEspera = AjustesInicioCronometro.esperaPredeterminada
    @AppStorage(AjustesInicioCronometro.claveColorListo)
    private var colorListo = AjustesInicioCronometro.colorPredeterminado
    @AppStorage(AjustesInicioCronometro.claveTamanoScramble)
    private var tamanoScramble = AjustesInicioCronometro.tamanoScramblePredeterminado
    @AppStorage(AjustesInicioCronometro.claveMostrarScramble)
    private var mostrarScramble = AjustesInicioCronometro.mostrarScramblePredeterminado
    @AppStorage(AjustesInicioCronometro.claveTamanoTimer)
    private var tamanoTimer = AjustesInicioCronometro.tamanoTimerPredeterminado
    @AppStorage(AjustesInicioCronometro.claveFuenteTimer)
    private var fuenteTimer = AjustesInicioCronometro.fuenteTimerPredeterminada
    @AppStorage(AjustesInicioCronometro.claveFuenteScramble)
    private var fuenteScramble = AjustesInicioCronometro.fuenteScramblePredeterminada
    @Environment(\.temaApp) private var temaApp

    private var esperaConfigurada: Binding<Double> {
        Binding(
            get: { AjustesInicioCronometro.esperaValida(tiempoEspera) },
            set: { tiempoEspera = $0 }
        )
    }

    private var tamanoTimerConfigurado: Binding<Double> {
        Binding(
            get: { AjustesInicioCronometro.tamanoTimerValido(tamanoTimer) },
            set: { tamanoTimer = AjustesInicioCronometro.tamanoTimerValido($0) }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                AparienciaSeccion(estado: estado) {
                    mostrarSelectorTema = true
                }
                TextoSeccion(
                    mostrarScramble: $mostrarScramble,
                    tamanoScramble: $tamanoScramble,
                    fuenteScramble: $fuenteScramble
                )
                TemporizadorSeccion(
                    estado: estado,
                    tamanoTimer: tamanoTimerConfigurado,
                    fuenteTimer: $fuenteTimer,
                    mantenerParaIniciar: $mantenerParaIniciar,
                    tiempoEspera: esperaConfigurada,
                    colorListo: $colorListo
                )
                DatosSeccion(estado: estado)
                AcercaDeSeccion(version: AjustesInformacionApp.version) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        estado.restablecer()
                        mantenerParaIniciar = AjustesInicioCronometro.mantenerPredeterminado
                        tiempoEspera = AjustesInicioCronometro.esperaPredeterminada
                        colorListo = AjustesInicioCronometro.colorPredeterminado
                        tamanoScramble = AjustesInicioCronometro.tamanoScramblePredeterminado
                        mostrarScramble = AjustesInicioCronometro.mostrarScramblePredeterminado
                        tamanoTimer = AjustesInicioCronometro.tamanoTimerPredeterminado
                        fuenteTimer = AjustesInicioCronometro.fuenteTimerPredeterminada
                        fuenteScramble = AjustesInicioCronometro.fuenteScramblePredeterminada
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
        .sheet(isPresented: $mostrarSelectorTema) {
            TemaSelectorView()
        }
    }
}

#Preview("Ajustes") {
    AjustesView()
}
