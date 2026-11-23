import SwiftUI

private extension PestanaTimeCuber {
    var titulo: String {
        switch self {
        case .cronometro: "Cronómetro"
        case .tiempos: "Tiempos"
        case .estadisticas: "Estadísticas"
        case .sesiones: "Sesiones"
        case .ajustes: "Ajustes"
        }
    }

    var icono: String {
        switch self {
        case .cronometro: "stopwatch"
        case .tiempos: "list.bullet.rectangle"
        case .estadisticas: "chart.bar.xaxis"
        case .sesiones: "square.stack"
        case .ajustes: "slider.horizontal.3"
        }
    }
}

struct RetroContenedor: View {
    @ObservedObject var vm: RubikViewModel
    @Binding var pestana: PestanaTimeCuber
    @State private var estadoAjustes = AjustesEstado()
    @Environment(\.colorScheme) private var esquema
    @Environment(\.accessibilityReduceMotion) private var reducirMovimiento

    private var paleta: PaletaRetro { PaletaRetro(oscura: esquema == .dark) }
    private let separacionPestanas: CGFloat = 2

    var body: some View {
        GeometryReader { espacio in
            let zonaInferior = espacio.safeAreaInsets.bottom
            VStack(spacing: 0) {
                ZStack {
                    pantalla
                        .id(pestana)
                        .transition(.opacity.combined(with: .offset(y: 9)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !vm.timerState.intentoActivo {
                    barra
                }
            }
            .padding(.bottom, zonaInferiorRetro(zonaInferior))
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .ignoresSafeArea(.container, edges: vm.timerState.estaCorriendo ? .all : [])
        .background(paleta.fondo.ignoresSafeArea())
        .foregroundStyle(paleta.texto)
        .tint(paleta.oscura ? paleta.lima : paleta.tinta)
        .environment(\.retro, paleta)
    }

    private func zonaInferiorRetro(_ segura: CGFloat) -> CGFloat {
        if vm.timerState.estaCorriendo { return 0 }
        return vm.timerState.intentoActivo ? segura : max(8, segura - 14)
    }

    @ViewBuilder private var pantalla: some View {
        switch pestana {
        case .cronometro: RetroCronometro(vm: vm)
        case .tiempos: RetroTiempos(vm: vm)
        case .estadisticas: RetroEstadisticas(vm: vm)
        case .sesiones: RetroSesiones(vm: vm)
        case .ajustes: RetroAjustes(estado: estadoAjustes, vm: vm)
        }
    }

    private var barra: some View {
        HStack(spacing: separacionPestanas) {
            ForEach(PestanaTimeCuber.allCases, id: \.self) { opcion in
                let elegida = pestana == opcion
                Button {
                    withAnimation(reducirMovimiento ? nil : .spring(response: 0.40, dampingFraction: 0.78)) {
                        pestana = opcion
                    }
                } label: {
                    Image(systemName: opcion.icono)
                        .font(.system(size: 21, weight: .bold))
                        .scaleEffect(elegida && !reducirMovimiento ? 1.15 : 1)
                        .offset(y: elegida && !reducirMovimiento ? -1 : 0)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundStyle(elegida ? paleta.tinta : paleta.texto)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(opcion.titulo)
                .accessibilityAddTraits(elegida ? .isSelected : [])
                .accessibilityIdentifier("retro-tab-\(opcion)")
            }
        }
        .background {
            GeometryReader { espacio in
                let pestanas = PestanaTimeCuber.allCases
                let ancho = (espacio.size.width - separacionPestanas * CGFloat(pestanas.count - 1)) / CGFloat(pestanas.count)
                let indice = CGFloat(pestanas.firstIndex(of: pestana) ?? 0)
                Capsule()
                    .fill(paleta.lima)
                    .frame(width: max(0, ancho), height: espacio.size.height)
                    .offset(x: indice * (ancho + separacionPestanas))
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .padding(4)
        .cajaRetro(radio: 28)
        .padding(.horizontal, 16)
        .padding(.top, 7)
    }
}
