import SwiftUI

struct TemporizadorSeccion: View {
    @Bindable var estado: AjustesEstado
    @Binding var tamanoTimer: Double
    @Binding var fuenteTimer: FuenteTimerAjuste
    @Binding var mantenerParaIniciar: Bool
    @Binding var tiempoEspera: Double
    @Binding var colorListo: ColorListoAjuste
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Section {
            filaTamano
                .filaTema(temaApp)

            filaFuenteTimer
                .filaTema(temaApp)

            AjustesToggleFila(
                titulo: "Inspección de 15 s",
                estaActivo: $estado.inspeccion15s
            )
            .filaTema(temaApp)

            AjustesToggleFila(
                titulo: "Mantener para iniciar",
                estaActivo: $mantenerParaIniciar
            )
            .filaTema(temaApp)

            filaEspera
                .filaTema(temaApp)
            filaColorListo
                .filaTema(temaApp)
            filaPrecision
                .filaTema(temaApp)

            AjustesToggleFila(
                titulo: "Vibración",
                estaActivo: $estado.vibracion
            )
            .filaTema(temaApp)
        } header: {
            Text("TEMPORIZADOR")
        }
    }

    // MARK: - Tamaño y vista previa

    private var filaTamano: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("Tamaño del timer")
                Spacer(minLength: 8)
                Text("\(Int(tamanoTimer)) pt")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(temaApp.texto.opacity(0.65))
            }

            Slider(value: $tamanoTimer, in: AjustesInicioCronometro.rangoTamanoTimer, step: 1)
                .tint(temaApp.acento)
                .accessibilityLabel("Tamaño del timer")
                .accessibilityValue("\(Int(tamanoTimer)) puntos")

            AjustesVistaPreviaTimer(tamano: tamanoTimer, precision: estado.precision, fuente: fuenteTimer)
        }
        .padding(.vertical, 4)
    }

    private var filaFuenteTimer: some View {
        FuenteSelectorFila(
            titulo: "Fuente del timer",
            ejemplo: estado.precision.ejemplo,
            pesoPredeterminado: .semibold,
            identificador: "fuente-timer",
            seleccion: $fuenteTimer
        )
    }

    // MARK: - Tiempo de espera

    private var filaEspera: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("Tiempo de espera")
                Spacer(minLength: 8)
                Text(textoTiempoEspera)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(temaApp.texto.opacity(0.65))
            }

            Slider(value: $tiempoEspera, in: AjustesInicioCronometro.rangoEspera, step: 0.1)
                .tint(temaApp.acento)
                .disabled(!mantenerParaIniciar)
                .accessibilityLabel("Tiempo de espera")
                .accessibilityValue(textoTiempoEspera)
        }
        .opacity(mantenerParaIniciar ? 1 : 0.45)
        .padding(.vertical, 4)
    }

    private var textoTiempoEspera: String {
        tiempoEspera.formatted(.number.precision(.fractionLength(1))) + " s"
    }

    // MARK: - Color al estar listo

    private var filaColorListo: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("Color al estar listo")
                Spacer(minLength: 8)
                Circle()
                    .fill(colorListo.color)
                    .frame(width: 22, height: 22)
                    .overlay {
                        Circle().strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    }
                    .accessibilityHidden(true)
            }

            HStack(spacing: 0) {
                ForEach(ColorListoAjuste.allCases) { opcion in
                    AjustesCirculoColor(
                        opcion: opcion,
                        seleccionado: colorListo == opcion
                    ) {
                        colorListo = opcion
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Precisión

    private var filaPrecision: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Precisión")

            Picker("Precisión", selection: $estado.precision) {
                ForEach(PrecisionAjuste.allCases) { precision in
                    Text(precision.titulo).tag(precision)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Precisión del temporizador")
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        List {
            TemporizadorSeccion(
                estado: AjustesEstado(),
                tamanoTimer: .constant(AjustesInicioCronometro.tamanoTimerPredeterminado),
                fuenteTimer: .constant(AjustesInicioCronometro.fuenteTimerPredeterminada),
                mantenerParaIniciar: .constant(AjustesInicioCronometro.mantenerPredeterminado),
                tiempoEspera: .constant(AjustesInicioCronometro.esperaPredeterminada),
                colorListo: .constant(AjustesInicioCronometro.colorPredeterminado)
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
