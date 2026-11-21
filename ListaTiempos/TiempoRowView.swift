import SwiftUI

struct TiempoRowView: View {
    let tiempo: Tiempo
    let abrirDetalle: () -> Void
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Button(action: abrirDetalle) {
            contenido
        }
        .buttonStyle(.plain)
        .accessibilityHint("Abre los detalles del tiempo")
    }

    private var contenido: some View {
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
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var valor: some View {
        Text(tiempo.texto(largo: true))
            .font(.system(.title, design: .rounded, weight: .bold))
            .monospacedDigit()
            .foregroundStyle(temaApp.texto)
    }

    private var fecha: some View {
        Text(formatoFecha(tiempo.fecha))
            .font(.subheadline)
            .monospacedDigit()
            .foregroundStyle(temaApp.texto.opacity(0.8))
    }
}
