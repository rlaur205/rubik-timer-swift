import SwiftUI

struct TimerAreaView: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.temaApp) private var temaApp

    let mantenerParaIniciar: Bool
    let tiempoEspera: TimeInterval
    let colorListo: Color
    let tamanoTimer: Double
    var fuenteTimer: FuenteTimerAjuste = .predeterminado

    var body: some View {
        SuperficieCronometro(
            vm: vm,
            mantenerParaIniciar: mantenerParaIniciar,
            tiempoEspera: tiempoEspera
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
    @ObservedObject var vm: RubikViewModel
    @GestureState private var estaPreparado = false
    @GestureState private var contactoActivo = false
    @State private var inicioContacto: ContinuousClock.Instant?
    @State private var inspeccionContacto: ContinuousClock.Instant?
    @State private var contactoPreparado = false
    @State private var tareaPreparacion: Task<Void, Never>?
    @AppStorage(AjustesInicioCronometro.claveInspeccion)
    private var inspeccionActivada = AjustesInicioCronometro.inspeccionPredeterminada
    @AppStorage(AjustesInicioCronometro.claveOcultarTiempo)
    private var ocultarTiempo = AjustesInicioCronometro.ocultarTiempoPredeterminado

    let mantenerParaIniciar: Bool
    let tiempoEspera: TimeInterval
    @ViewBuilder var contenido: (String, Bool) -> Contenido

    var body: some View {
        Group {
            if vm.timerState.estaCorriendo {
                area.onTapGesture(perform: vm.detenerResolucion)
            } else if vm.timerState.enInspeccion || inspeccionActivada {
                area.gesture(gestoInspeccion)
            } else if !vm.scrambleListo {
                area
            } else if mantenerParaIniciar {
                area.gesture(gestoMantener)
            } else {
                area.onTapGesture { vm.iniciarResolucion(desdeInspeccion: false) }
            }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .onChange(of: contactoActivo) { _, activo in
            if !activo { limpiarContacto() }
        }
        .onDisappear { limpiarContacto() }
    }

    private var area: some View {
        ZStack {
            Rectangle().fill(Color.clear).frame(maxHeight: .infinity)
            TimelineView(.animation) { _ in
                contenido(textoCronometro, (estaPreparado || contactoPreparado) && !vm.timerState.estaCorriendo)
            }
        }
        .contentShape(Rectangle())
    }

    private var textoCronometro: String {
        switch vm.timerState.fase {
        case .reposo:
            return vm.resultadoCronometro?.texto(largo: false) ?? textoTiempo(vm.timerState.tiempoTranscurrido)
        case .inspeccion(let inicio):
            let transcurrido = inicio.duration(to: ContinuousClock().now)
            if transcurrido >= TimerState.inspeccionSinPenalizacion { return "15 +2" }
            return String(transcurrido.components.seconds)
        case .resolucion(let inicio, _):
            return ocultarTiempo ? "..." : textoTiempo(Date().timeIntervalSince(inicio))
        }
    }

    private func textoTiempo(_ duracion: TimeInterval) -> String {
        String(formatoTiempo(duracion).dropLast())
    }

    private var gestoInspeccion: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($contactoActivo) { _, activo, _ in activo = true }
            .onChanged { _ in
                guard inicioContacto == nil else { return }
                inicioContacto = ContinuousClock().now
                if vm.timerState.enInspeccion && !mantenerParaIniciar {
                    vm.iniciarResolucion(desdeInspeccion: true)
                    return
                }
                if !vm.timerState.enInspeccion { vm.iniciarInspeccion() }
                guard case .inspeccion(let inicio) = vm.timerState.fase else { return }
                inspeccionContacto = inicio
                guard mantenerParaIniciar else { return }
                tareaPreparacion = Task { @MainActor in
                    do {
                        try await Task.sleep(for: .seconds(tiempoEspera))
                    } catch {
                        return
                    }
                    guard case .inspeccion(let actual) = vm.timerState.fase, actual == inicio else { return }
                    contactoPreparado = true
                }
            }
            .onEnded { _ in
                let inicio = inicioContacto
                let inspeccion = inspeccionContacto
                limpiarContacto()
                guard mantenerParaIniciar, let inicio, let inspeccion,
                      case .inspeccion(let actual) = vm.timerState.fase, actual == inspeccion,
                      inicio.duration(to: ContinuousClock().now) >= .seconds(tiempoEspera) else { return }
                vm.iniciarResolucion(desdeInspeccion: true)
            }
    }

    private func limpiarContacto() {
        tareaPreparacion?.cancel()
        tareaPreparacion = nil
        inicioContacto = nil
        inspeccionContacto = nil
        contactoPreparado = false
    }

    private var gestoMantener: some Gesture {
        LongPressGesture(minimumDuration: tiempoEspera)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .updating($estaPreparado) { fase, preparado, _ in
                if case .second(true, _) = fase { preparado = true }
            }
            .onEnded { fase in
                guard case .second(true, _) = fase else { return }
                vm.iniciarResolucion(desdeInspeccion: false)
            }
    }
}

#Preview {
    ContentView()
}
