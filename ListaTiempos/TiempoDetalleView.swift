import SwiftUI

struct TiempoDetalleView: View {
    struct Edicion {
        let aplicarPenalizacion: (PenalizacionTiempo) -> Void
        let eliminar: () -> Void
    }

    @State var tiempo: Tiempo
    let categoria: String
    var edicion: Edicion? = nil

    @Environment(\.dismiss) private var cerrar
    @Environment(\.temaApp) private var temaApp
    @State private var alturaContenido: CGFloat = 0
    @ScaledMetric(relativeTo: .body) private var tamanoScramble = 20.4

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(tiempo.texto(largo: true))
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .monospacedDigit()
                    Text(formatoFecha(tiempo.fecha))
                        .font(.subheadline)
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                }

                if !tiempo.scramble.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scramble").font(.headline)
                        Text(tiempo.scramble)
                            .font(.system(size: tamanoScramble, design: .monospaced))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ImagenScrambleView(scramble: tiempo.scramble, categoria: categoria)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                }

                if let edicion {
                    HStack(spacing: 12) {
                        selectorPenalizacion(edicion.aplicarPenalizacion)
                        Spacer(minLength: 0)
                        Button(role: .destructive, action: edicion.eliminar) {
                            Label("Eliminar tiempo", systemImage: "trash")
                                .labelStyle(.iconOnly)
                                .font(.title3)
                                .frame(minWidth: 28, minHeight: 30)
                        }
                        .buttonStyle(.bordered)
                        .tint(EstiloVisual.peligro)
                    }
                }
            }
            .frame(maxWidth: 480, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { geometria in
                geometria.size.height.rounded(.up)
            } action: { altura in
                alturaContenido = altura
            }
        }
        .background(temaApp.fondo)
        .foregroundStyle(temaApp.texto)
        .presentationBackground(temaApp.fondo)
        .presentationDetents([alturaContenido > 0 ? .height(alturaContenido) : .medium])
        .presentationDragIndicator(.visible)
        .accessibilityAction(.escape) { cerrar() }
    }

    private func selectorPenalizacion(_ aplicar: @escaping (PenalizacionTiempo) -> Void) -> some View {
        Picker("Penalización", selection: Binding(
            get: { tiempo.penalizacion },
            set: { penalizacion in
                aplicar(penalizacion)
                tiempo.penalizacion = penalizacion
            }
        )) {
            Text(PenalizacionTiempo.dnf.titulo).tag(PenalizacionTiempo.dnf)
            Text(PenalizacionTiempo.masDos.titulo).tag(PenalizacionTiempo.masDos)
            Image(systemName: "checkmark")
                .accessibilityLabel(PenalizacionTiempo.ninguna.titulo)
                .tag(PenalizacionTiempo.ninguna)
        }
        .pickerStyle(.segmented)
        .disabled(tiempo.esDNFDeInspeccion)
        .frame(width: 144)
    }
}
