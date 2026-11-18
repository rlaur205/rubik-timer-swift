import SwiftUI

struct EstadisticasCronometroView: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.temaApp) private var temaApp
    @Binding var mostrarPromedios: Bool
    private var tiempos: [Double] { obtenerTiempos(sesion: vm.sesionActual) }

    var body: some View {
        VStack(spacing: 18) {
            if !tiempos.isEmpty {
                Group {
                    if dynamicTypeSize.isAccessibilitySize {
                        ScrollView(.horizontal, showsIndicators: false) { ultimosTiempos }
                    } else {
                        ultimosTiempos
                    }
                }
                .accessibilityLabel("Últimos tiempos")
            }
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    mostrarPromedios.toggle()
                }
            } label: {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: dynamicTypeSize.isAccessibilitySize ? 2 : 4), spacing: 18) {
                    ForEach(0..<(mostrarPromedios ? metricas.count : 4), id: \.self) { index in
                        resumen(metricas[index].0, valor: metricas[index].1)
                            .transition(.opacity)
                    }
                }
                .padding(16)
                .background(temaApp.superficie, in: RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(temaApp.linea, lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .accessibilityValue(mostrarPromedios ? "Expandido" : "Contraído")
            .accessibilityHint(mostrarPromedios ? "Toca para ocultar los promedios" : "Toca para mostrar Mo3, Ao5, Ao12 y Ao50")
        }
    }

    private var ultimosTiempos: some View {
        HStack(spacing: 8) {
            ForEach(0..<min(tiempos.count, 5), id: \.self) { index in
                let tiempo = tiempos[tiempos.count - index - 1]
                Text(EstiloVisual.tiempo(tiempo))
                    .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                    .foregroundStyle(tiempo == tiempos.suffix(5).max() ? EstiloVisual.peligro : tiempo == tiempos.suffix(5).min() ? EstiloVisual.mejor : temaApp.texto)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var metricas: [(String, String)] {
        [
            ("Solves", "\(tiempos.count)"),
            ("Media", EstiloVisual.tiempo(media(tiempos: tiempos, cantidad: tiempos.isEmpty ? 1 : tiempos.count), disponible: !tiempos.isEmpty)),
            ("Mejor", EstiloVisual.tiempo(obtenerMejorPeor(listaTiempos: tiempos, tipo: "mejor"), disponible: !tiempos.isEmpty)),
            ("Peor", EstiloVisual.tiempo(obtenerMejorPeor(listaTiempos: tiempos, tipo: "peor"), disponible: !tiempos.isEmpty)),
            ("Mo3", EstiloVisual.tiempo(media(tiempos: tiempos, cantidad: 3), disponible: tiempos.count >= 3)),
            ("Ao5", EstiloVisual.tiempo(avg(tiempos: tiempos, cantidad: 5), disponible: tiempos.count >= 5)),
            ("Ao12", EstiloVisual.tiempo(avg(tiempos: tiempos, cantidad: 12), disponible: tiempos.count >= 12)),
            ("Ao50", EstiloVisual.tiempo(avg(tiempos: tiempos, cantidad: 50), disponible: tiempos.count >= 50))
        ]
    }

    private func resumen(_ titulo: String, valor: String) -> some View {
        VStack(spacing: 5) {
            Text(titulo).font(.subheadline.weight(.semibold)).foregroundStyle(temaApp.texto.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            Text(valor)
                .foregroundStyle(titulo == "Mejor" ? EstiloVisual.mejor : titulo == "Peor" ? EstiloVisual.peligro : titulo.hasPrefix("Ao") ? temaApp.acento : temaApp.texto)
                .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
