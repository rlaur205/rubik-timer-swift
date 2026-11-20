import SwiftUI

struct TimerAreaView: View {
    @Binding var stateTimer: TimerState
    @Environment(\.temaApp) private var temaApp

    let puedeIniciar: Bool
    let mantenerParaIniciar: Bool
    let tiempoEspera: TimeInterval
    let colorListo: Color
    let tamanoTimer: Double
    var fuenteTimer: FuenteTimerAjuste = .predeterminado
    let resultadoEnReposo: Tiempo?
    let registrarNuevoTiempo: () -> Void
    let abrirPenalizacion: (() -> Void)?

    var body: some View {
        SuperficieCronometro(
            stateTimer: $stateTimer,
            puedeIniciar: puedeIniciar,
            mantenerParaIniciar: mantenerParaIniciar,
            tiempoEspera: tiempoEspera,
            resultadoEnReposo: resultadoEnReposo,
            registrarNuevoTiempo: registrarNuevoTiempo,
            abrirPenalizacion: abrirPenalizacion
        ) { texto, listo in
            Text(texto)
                .font(fuenteTimer.font(tamano: CGFloat(tamanoTimer), pesoPredeterminado: .bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .padding(.horizontal, 24)
                .foregroundStyle(listo ? colorListo : temaApp.texto)
                .accessibilityIdentifier("timer-digitos")
        }
    }
}

struct SuperficieCronometro<Contenido: View>: View {
    @Binding var stateTimer: TimerState
    @GestureState private var estaPreparado = false

    let puedeIniciar: Bool
    let mantenerParaIniciar: Bool
    let tiempoEspera: TimeInterval
    let resultadoEnReposo: Tiempo?
    let registrarNuevoTiempo: () -> Void
    let abrirPenalizacion: (() -> Void)?
    @ViewBuilder var contenido: (String, Bool) -> Contenido

    var body: some View {
        ZStack {
            if stateTimer.estaCorriendo || (puedeIniciar && !mantenerParaIniciar) {
                area.onTapGesture(perform: responderAlToque)
            } else if puedeIniciar {
                area.gesture(gestoMantener)
            } else {
                area
            }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .simultaneousGesture(
            DragGesture(minimumDistance: 25)
                .onEnded { arrastre in
                    guard !stateTimer.estaCorriendo, esDeslizamientoHaciaAbajo(arrastre.translation) else { return }
                    abrirPenalizacion?()
                }
        )
    }

    private var area: some View {
        ZStack {
            Rectangle().fill(Color.clear).frame(maxHeight: .infinity)
            TimelineView(.animation) { _ in
                let tiempo = stateTimer.estaCorriendo
                    ? Date().timeIntervalSince(stateTimer.tiempoInicio ?? Date())
                    : stateTimer.tiempoTranscurrido

                let resultado = stateTimer.estaCorriendo ? nil : resultadoEnReposo
                let texto = resultado?.texto(largo: false) ?? String(formatoTiempo(tiempo).dropLast())
                contenido(texto, estaPreparado && !stateTimer.estaCorriendo)
            }
        }
        .contentShape(Rectangle())
    }

    private var gestoMantener: some Gesture {
        LongPressGesture(minimumDuration: tiempoEspera)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .updating($estaPreparado) { fase, preparado, _ in
                // La segunda fase solo se alcanza tras completar la pulsación larga.
                if case .second(true, _) = fase {
                    preparado = true
                }
            }
            .onEnded { fase in
                if case .second(true, let arrastre) = fase {
                    if abrirPenalizacion != nil, let arrastre, esDeslizamientoHaciaAbajo(arrastre.translation) {
                        return
                    }
                    iniciar()
                }
            }
    }

    private func esDeslizamientoHaciaAbajo(_ desplazamiento: CGSize) -> Bool {
        desplazamiento.height >= 50 && desplazamiento.height > abs(desplazamiento.width)
    }

    private func responderAlToque() {
        if stateTimer.estaCorriendo {
            stateTimer.estaCorriendo = false
            registrarNuevoTiempo()
            stateTimer.visibilidadPromedios = true
        } else {
            iniciar()
        }
    }

    private func iniciar() {
        guard puedeIniciar else { return }
        stateTimer.estaCorriendo = true
        stateTimer.tiempoInicio = Date()
        stateTimer.tiempoTranscurrido = 0
        stateTimer.visibilidadPromedios = false
    }
}

#Preview {
    ContentView()
}
