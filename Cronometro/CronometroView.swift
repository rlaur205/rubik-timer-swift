import SwiftUI

struct CronometroView: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var mostrarDiagrama = false
    @State private var mostrarPromedios = false

    private var tamanoScramble: CGFloat {
        switch vm.sesionActual.categoria {
        case "Megaminx": return 15
        case "7x7": return 16
        case "6x6": return 17
        case let categoria where categoria.hasPrefix("5x5"): return 18
        case let categoria where categoria.hasPrefix("4x4"): return 20
        default: return 24
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if dynamicTypeSize.isAccessibilitySize && !vm.timerState.estaCorriendo {
                    ScrollView { contenido }
                } else {
                    contenido
                }
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle(vm.sesionActual.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Eliminar último tiempo", systemImage: "trash", role: .destructive) {
                        vm.borrarUltimoTiempo()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Ver diagrama", systemImage: "cube.transparent") {
                        if !vm.scrambleActual.isEmpty { mostrarDiagrama = true }
                    }
                    .popover(isPresented: $mostrarDiagrama, arrowEdge: .top) {
                        VStack(spacing: 16) {
                            Text("Diagrama").font(.headline)
                            ImagenScrambleView(scramble: vm.scrambleActual, categoria: vm.sesionActual.categoria)
                                .frame(width: 260, height: 180)
                        }
                        .padding(24)
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }
            .toolbar(vm.timerState.estaCorriendo ? .hidden : .visible, for: .navigationBar, .tabBar)
        }
    }

    private var mezclaLarga: Bool {
        ["6x6", "7x7", "Megaminx"].contains(vm.sesionActual.categoria)
            || vm.sesionActual.categoria.hasPrefix("5x5")
    }

    private var mezcla: some View {
        VStack(spacing: 12) {
            if vm.scrambleActual.isEmpty {
                ProgressView("Preparando mezcla…").font(.subheadline)
            } else {
                Text(vm.scrambleActual)
                    .font(.system(size: tamanoScramble, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
        }
    }

    private var contenido: some View {
        VStack(spacing: 0) {
            if !vm.timerState.estaCorriendo {
                Group {
                    if mostrarPromedios && mezclaLarga {
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
            }

            TimerAreaView(
                stateTimer: $vm.timerState,
                registrarNuevoTiempo: { vm.registrarNuevoTiempo() },
                formatoTiempo: formatoTiempo
            )
            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 240 : 140)
            .layoutPriority(1)

            if !vm.timerState.estaCorriendo {
                EstadisticasCronometroView(vm: vm, mostrarPromedios: $mostrarPromedios)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
    }

}

#Preview { ContentView() }
