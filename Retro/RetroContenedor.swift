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
    @Namespace private var indicador

    private var paleta: PaletaRetro { PaletaRetro(oscura: esquema == .dark) }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                pantalla
                    .id(pestana)
                    .transition(.opacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !vm.timerState.estaCorriendo {
                barra
            }
        }
        .background(paleta.fondo.ignoresSafeArea())
        .foregroundStyle(paleta.texto)
        .tint(paleta.oscura ? paleta.lima : paleta.tinta)
        .environment(\.retro, paleta)
    }

    @ViewBuilder private var pantalla: some View {
        switch pestana {
        case .cronometro: RetroCronometro(vm: vm)
        case .tiempos: RetroTiempos(vm: vm)
        case .estadisticas: RetroEstadisticas(vm: vm)
        case .sesiones: RetroSesiones(vm: vm)
        case .ajustes: RetroAjustes(estado: estadoAjustes)
        }
    }

    private var barra: some View {
        HStack(spacing: 2) {
            ForEach(PestanaTimeCuber.allCases, id: \.self) { opcion in
                let elegida = pestana == opcion
                Button {
                    withAnimation(reducirMovimiento ? nil : .snappy(duration: 0.32)) {
                        pestana = opcion
                    }
                } label: {
                    Image(systemName: opcion.icono)
                        .font(.system(size: 21, weight: .bold))
                        .scaleEffect(elegida ? 1.12 : 1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background {
                            if elegida {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(paleta.lima)
                                    .matchedGeometryEffect(id: "pestaña-activa", in: indicador)
                            }
                        }
                        .foregroundStyle(elegida ? paleta.tinta : paleta.texto)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(opcion.titulo)
                .accessibilityAddTraits(elegida ? .isSelected : [])
                .accessibilityIdentifier("retro-tab-\(opcion)")
            }
        }
        .padding(4)
        .cajaRetro()
        .padding(.horizontal, 16)
        .padding(.top, 7)
        .padding(.bottom, 8)
    }
}
