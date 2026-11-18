import SwiftUI

struct TiempoRowView: View {
    let tiempo: Tiempo
    var onEliminar: () -> Void
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    valor
                    Spacer(minLength: 16)
                    fecha
                }
                VStack(alignment: .leading, spacing: 4) { valor; fecha }
            }
            Text(tiempo.scramble)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(temaApp.texto.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button("Eliminar tiempo", systemImage: "trash", role: .destructive, action: onEliminar)
        }
    }

    private var valor: some View {
        Text(formatoTiempo(tiempo.tiempo))
            .font(.system(.title2, design: .rounded, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(temaApp.texto)
    }

    private var fecha: some View {
        Text(formatoFecha(tiempo.fecha)).font(.caption).foregroundStyle(temaApp.texto.opacity(0.65))
    }
}
