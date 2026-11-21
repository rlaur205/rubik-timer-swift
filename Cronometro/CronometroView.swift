import SwiftUI

struct CronometroView: View {
    @ObservedObject var vm: RubikViewModel
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.temaApp) private var temaApp
    @State private var mostrarDiagrama = false
    @State private var mostrarPromedios = false
    @State private var confirmarBorrado = false

    private var tamanoScrambleAjustado: CGFloat {
        tamanoScramble.tamanoFuenteAjustado(para: vm.sesionActual.categoria)
    }

    var body: some View {
        NavigationStack {
            Group {
                if dynamicTypeSize.isAccessibilitySize && !vm.timerState.intentoActivo {
                    ScrollView { contenido }
                } else {
                    contenido
                }
            }
            .background(temaApp.fondo)
            .foregroundStyle(temaApp.texto)
            .navigationTitle(vm.sesionActual.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Eliminar último tiempo", systemImage: "trash", role: .destructive) {
                        confirmarBorrado = true
                    }
                    .disabled(vm.sesionActual.tiempos.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(mostrarScramble ? "Ver diagrama" : "Ver scramble y diagrama", systemImage: "cube.transparent") {
                        mostrarDiagrama = true
                    }
                    .disabled(!vm.scrambleListo)
                    .popover(isPresented: $mostrarDiagrama, arrowEdge: .top) {
                        VStack(spacing: 16) {
                            if !mostrarScramble {
                                mezcla
                            }
                            ImagenScrambleView(scramble: vm.scrambleActual, categoria: vm.sesionActual.categoria)
                                .frame(width: 260, height: 180)
                        }
                        .frame(
                            minWidth: 0,
                            idealWidth: mostrarScramble ? 260 : 330,
                            maxWidth: mostrarScramble ? 260 : 330
                        )
                        .padding(mostrarScramble ? 24 : 16)
                        .background(temaApp.fondo)
                        .presentationBackground(temaApp.fondo)
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }
            .toolbar(vm.timerState.intentoActivo ? .hidden : .visible, for: .navigationBar, .tabBar)
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
            .alert("¿Eliminar último tiempo?", isPresented: $confirmarBorrado, presenting: vm.sesionActual.tiempos.last) { tiempo in
                Button("Eliminar", role: .destructive) { vm.borrarUltimoTiempo(id: tiempo.id) }
                Button("Cancelar", role: .cancel) {}
            } message: { tiempo in
                Text("Se eliminará el tiempo \(tiempo.texto(largo: true)) de esta sesión.")
            }
        }
    }

    private var mezclaLarga: Bool {
        ["6x6", "7x7", "Megaminx"].contains(vm.sesionActual.categoria)
            || vm.sesionActual.categoria.hasPrefix("5x5")
    }

    private var mezcla: some View {
        textoSuperior(vm.scrambleActual)
            .textSelection(.enabled)
            .accessibilityIdentifier("scramble-texto")
    }

    private func textoSuperior(_ texto: String) -> some View {
        Text(texto)
            .font(fuenteScramble.font(tamano: tamanoScrambleAjustado, pesoPredeterminado: .bold))
            .monospacedDigit()
            .foregroundStyle(temaApp.texto)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var contenido: some View {
        VStack(spacing: 0) {
            if !vm.timerState.intentoActivo {
                contenidoSuperior
            }

            TimerAreaView(
                vm: vm,
                mantenerParaIniciar: mantenerParaIniciar,
                tiempoEspera: AjustesInicioCronometro.esperaValida(tiempoEspera),
                colorListo: colorListo.color,
                tamanoTimer: AjustesInicioCronometro.tamanoTimerValido(tamanoTimer),
                fuenteTimer: fuenteTimer
            )
            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 240 : 140)
            .layoutPriority(1)

            if !vm.timerState.intentoActivo {
                VStack(spacing: 18) {
                    if mostrarScramble && !vm.sesionActual.tiempos.isEmpty {
                        TiemposRecientesCronometro(tiempos: vm.sesionActual.tiempos)
                    }
                    EstadisticasCronometroView(vm: vm, mostrarPromedios: $mostrarPromedios)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    @ViewBuilder
    private var contenidoSuperior: some View {
        if mostrarScramble {
            Group {
                if !vm.scrambleListo {
                    avisoScramble
                } else if mostrarPromedios && mezclaLarga {
                    ScrollView {
                        mezcla
                    }
                    .frame(height: 180)
                    .scrollBounceBehavior(.basedOnSize)
                } else {
                    mezcla
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        } else if !vm.sesionActual.tiempos.isEmpty || !vm.scrambleListo {
            VStack(spacing: 10) {
                if !vm.sesionActual.tiempos.isEmpty {
                    TiemposRecientesCronometro(tiempos: vm.sesionActual.tiempos, agrupados: true)
                }
                if !vm.scrambleListo { avisoScramble }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var avisoScramble: some View {
        if vm.estadoScramble == .error {
            VStack(spacing: 6) {
                Text("No se pudo generar el scramble.").font(.subheadline)
                Button("Reintentar", action: vm.reintentarScramble)
                    .buttonStyle(.bordered)
            }
        } else {
            ProgressView("Preparando mezcla…").font(.subheadline)
        }
    }

}

#Preview { ContentView() }
