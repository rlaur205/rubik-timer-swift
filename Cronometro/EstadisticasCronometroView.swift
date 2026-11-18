import SwiftUI

struct EstadisticasCronometroView: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.temaApp) private var temaApp
    @Binding var mostrarPromedios: Bool
    private var tiempos: [Tiempo] { vm.sesionActual.tiempos }

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
                .background(FondoBloqueEstadistico(estilo: temaApp.estilo(.resumen), radio: 20))
                .contentShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .accessibilityValue(mostrarPromedios ? "Expandido" : "Contraído")
            .accessibilityHint(mostrarPromedios ? "Toca para ocultar los promedios" : "Toca para mostrar Mo3, Ao5, Ao12 y Ao50")
        }
    }

    private var ultimosTiempos: some View {
        let ultimos = Array(tiempos.suffix(5))
        let validos = ultimos.compactMap(\.segundosValidos)
        let mejorValido = validos.min()
        let peorValido = validos.max()

        return HStack(spacing: 8) {
            ForEach(ultimos.reversed()) { tiempo in
                Text(tiempo.texto(largo: false))
                    .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                    .foregroundStyle(
                        colorUltimoTiempo(
                            tiempo,
                            mejorValido: mejorValido,
                            peorValido: peorValido
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func colorUltimoTiempo(
        _ tiempo: Tiempo,
        mejorValido: Double?,
        peorValido: Double?
    ) -> Color {
        guard let segundos = tiempo.segundosValidos else {
            return EstiloVisual.peligro
        }
        if segundos == peorValido {
            return EstiloVisual.peligro
        }
        if segundos == mejorValido {
            return EstiloVisual.mejor
        }
        return temaApp.texto
    }

    private var metricas: [(String, String)] {
        [
            ("Solves", "\(tiempos.count)"),
            ("Media", EstiloVisual.promedio(mediaTotal(tiempos: tiempos))),
            ("Mejor", mejorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—"),
            ("Peor", peorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—"),
            ("Mo3", EstiloVisual.promedio(mo3(tiempos: tiempos))),
            ("Ao5", EstiloVisual.promedio(avg(tiempos: tiempos, cantidad: 5))),
            ("Ao12", EstiloVisual.promedio(avg(tiempos: tiempos, cantidad: 12))),
            ("Ao50", EstiloVisual.promedio(avg(tiempos: tiempos, cantidad: 50)))
        ]
    }

    private func resumen(_ titulo: String, valor: String) -> some View {
        VStack(spacing: 5) {
            Text(titulo)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(temaApp.texto.opacity(0.65))
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
