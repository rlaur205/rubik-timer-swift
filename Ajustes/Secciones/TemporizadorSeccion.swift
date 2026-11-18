import SwiftUI

struct TemporizadorSeccion: View {
    @Bindable var estado: AjustesEstado

    var body: some View {
        Section {
            filaTamano

            AjustesToggleFila(
                sistema: "clock",
                color: .orange,
                titulo: "Inspección de 15 s",
                subtitulo: "Cuenta atrás antes de empezar",
                estaActivo: $estado.inspeccion15s
            )

            AjustesToggleFila(
                sistema: "hand.tap.fill",
                color: .green,
                titulo: "Mantener para iniciar",
                estaActivo: $estado.mantenerParaIniciar
            )

            filaEspera
            filaColorListo
            filaPrecision

            AjustesToggleFila(
                sistema: "iphone.radiowaves.left.and.right",
                color: .pink,
                titulo: "Vibración",
                estaActivo: $estado.vibracion
            )

            AjustesToggleFila(
                sistema: "sun.max.fill",
                color: .yellow,
                titulo: "Pantalla siempre encendida",
                estaActivo: $estado.pantallaSiempreEncendida
            )
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
                Text("\(Int(estado.tamanoTimer)) pt")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(value: $estado.tamanoTimer, in: 40...100, step: 1)
                .tint(EstiloVisual.acento)
                .accessibilityLabel("Tamaño del timer")
                .accessibilityValue("\(Int(estado.tamanoTimer)) puntos")

            AjustesVistaPreviaTimer(tamano: estado.tamanoTimer, precision: estado.precision)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Tiempo de espera

    private var filaEspera: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("Tiempo de espera")
                Spacer(minLength: 8)
                Text(textoTiempoEspera)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(value: $estado.tiempoEspera, in: 0.1...1, step: 0.1)
                .tint(EstiloVisual.acento)
                .disabled(!estado.mantenerParaIniciar)
                .accessibilityLabel("Tiempo de espera")
                .accessibilityValue(textoTiempoEspera)
        }
        .opacity(estado.mantenerParaIniciar ? 1 : 0.45)
        .padding(.vertical, 4)
    }

    private var textoTiempoEspera: String {
        estado.tiempoEspera.formatted(.number.precision(.fractionLength(1))) + " s"
    }

    // MARK: - Color al estar listo

    private var filaColorListo: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                AjustesIcono(sistema: "record.circle", color: .red)
                Text("Color al estar listo")
                Spacer(minLength: 8)
                Circle()
                    .fill(estado.colorListo.color)
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
                        seleccionado: estado.colorListo == opcion
                    ) {
                        estado.colorListo = opcion
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
            HStack(spacing: 12) {
                AjustesIcono(sistema: "number.square.fill", color: .gray)
                Text("Precisión")
            }

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
            TemporizadorSeccion(estado: AjustesEstado())
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
