import SwiftUI

struct TextoSeccion: View {
    @Bindable var estado: AjustesEstado

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    AjustesIcono(sistema: "textformat.size", color: .blue)
                    Text("Tamaño del scramble")
                    Spacer(minLength: 8)
                    Text(estado.tamanoScramble.nombre)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Slider(value: indiceTamano, in: 0...2, step: 1)
                    .tint(EstiloVisual.acento)
                    .accessibilityLabel("Tamaño del scramble")
                    .accessibilityValue(estado.tamanoScramble.nombre)

                HStack {
                    ForEach(TamanoScramble.allCases) { tamano in
                        Text(tamano.nombre)
                            .font(.caption2)
                            .fontWeight(tamano == estado.tamanoScramble ? .semibold : .regular)
                            .foregroundStyle(tamano == estado.tamanoScramble ? EstiloVisual.acento : Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .accessibilityHidden(true)

                AjustesVistaPreviaScramble(tamano: estado.tamanoScramble)
            }
            .padding(.vertical, 4)
        } header: {
            Text("TEXTO")
        }
    }

    /// Traduce el slider continuo a los tres tamaños disponibles.
    private var indiceTamano: Binding<Double> {
        Binding(
            get: {
                Double(TamanoScramble.allCases.firstIndex(of: estado.tamanoScramble) ?? 1)
            },
            set: { nuevoValor in
                let indice = Int(nuevoValor.rounded())
                let limitado = min(max(indice, 0), TamanoScramble.allCases.count - 1)
                estado.tamanoScramble = TamanoScramble.allCases[limitado]
            }
        )
    }
}

#Preview {
    NavigationStack {
        List {
            TextoSeccion(estado: AjustesEstado())
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
