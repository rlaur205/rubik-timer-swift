import SwiftUI

struct TiempoDetalleView: View {
    @State var tiempo: Tiempo
    let categoria: String
    let aplicarPenalizacion: (PenalizacionTiempo) -> Void
    let eliminar: () -> Void

    @Environment(\.dismiss) private var cerrar
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        NavigationStack {
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
                                .font(.system(.body, design: .monospaced))
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        ImagenScrambleView(scramble: tiempo.scramble, categoria: categoria)
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel("Diagrama del scramble")
                    }

                    HStack(spacing: 12) {
                        Button(role: .destructive, action: eliminar) {
                            ViewThatFits(in: .horizontal) {
                                Label("Eliminar tiempo", systemImage: "trash")
                                    .fixedSize()
                                Label("Eliminar tiempo", systemImage: "trash")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .foregroundStyle(EstiloVisual.peligro)
                        Spacer(minLength: 0)
                        selectorPenalizacion
                    }
                }
                .frame(maxWidth: 480, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .background(temaApp.fondo)
            .foregroundStyle(temaApp.texto)
            .navigationTitle("Detalle del tiempo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { cerrar() }
                }
            }
            .toolbarBackground(temaApp.fondo, for: .navigationBar)
            .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
        }
    }

    private var selectorPenalizacion: some View {
        Picker("Penalización", selection: Binding(
            get: { tiempo.penalizacion },
            set: { penalizacion in
                aplicarPenalizacion(penalizacion)
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
        .frame(width: 144)
    }
}
