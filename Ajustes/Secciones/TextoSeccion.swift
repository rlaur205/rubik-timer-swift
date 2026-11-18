import SwiftUI

struct TextoSeccion: View {
    @Binding var mostrarScramble: Bool
    @Binding var tamanoScramble: TamanoScramble
    @Binding var fuenteScramble: FuenteScrambleAjuste
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Section {
            AjustesToggleFila(titulo: "Mostrar scramble", estaActivo: $mostrarScramble)
                .filaTema(temaApp)

            FuenteSelectorFila(
                titulo: "Fuente del scramble",
                ejemplo: "R U2 F′",
                pesoPredeterminado: .medium,
                identificador: "fuente-scramble",
                seleccion: $fuenteScramble
            )
            .filaTema(temaApp)

            VStack(alignment: .leading, spacing: 10) {
                Text("Tamaño del scramble")

                Slider(value: indiceTamano, in: 0...2, step: 1)
                    .tint(temaApp.acento)
                    .accessibilityLabel("Tamaño del scramble")
                    .accessibilityValue(tamanoScramble.nombre)

                HStack {
                    ForEach(TamanoScramble.allCases) { tamano in
                        Text(tamano.nombre)
                            .font(.caption)
                            .fontWeight(tamano == tamanoScramble ? .semibold : .regular)
                            .foregroundStyle(tamano == tamanoScramble ? temaApp.acento : temaApp.texto.opacity(0.65))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .accessibilityHidden(true)

                AjustesVistaPreviaScramble(tamano: tamanoScramble, fuente: fuenteScramble)
            }
            .padding(.vertical, 4)
            .filaTema(temaApp)
        } header: {
            Text("TEXTO")
        }
    }

    /// Traduce el slider continuo a los tres tamaños disponibles.
    private var indiceTamano: Binding<Double> {
        Binding(
            get: {
                Double(TamanoScramble.allCases.firstIndex(of: tamanoScramble) ?? 1)
            },
            set: { nuevoValor in
                let indice = Int(nuevoValor.rounded())
                let limitado = min(max(indice, 0), TamanoScramble.allCases.count - 1)
                tamanoScramble = TamanoScramble.allCases[limitado]
            }
        )
    }
}

#Preview {
    NavigationStack {
        List {
            TextoSeccion(
                mostrarScramble: .constant(AjustesInicioCronometro.mostrarScramblePredeterminado),
                tamanoScramble: .constant(AjustesInicioCronometro.tamanoScramblePredeterminado),
                fuenteScramble: .constant(AjustesInicioCronometro.fuenteScramblePredeterminada)
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
