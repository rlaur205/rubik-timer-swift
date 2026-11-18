import SwiftUI

// MARK: - Icono de fila

/// Icono SF blanco dentro de un cuadrado redondeado de color, al estilo de Ajustes.
struct AjustesIcono: View {
    let sistema: String
    let color: Color

    var body: some View {
        Image(systemName: sistema)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 29, height: 29)
            .background(color, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .accessibilityHidden(true)
    }
}

// MARK: - Filas

struct AjustesToggleFila: View {
    let sistema: String
    let color: Color
    let titulo: String
    var subtitulo: String?
    @Binding var estaActivo: Bool

    var body: some View {
        Toggle(isOn: $estaActivo) {
            HStack(spacing: 12) {
                AjustesIcono(sistema: sistema, color: color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(titulo)
                    if let subtitulo {
                        Text(subtitulo)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .tint(EstiloVisual.acento)
    }
}

struct AjustesFilaValor: View {
    let sistema: String
    let color: Color
    let titulo: String
    let valor: String
    var bloqueada = false

    var body: some View {
        HStack(spacing: 12) {
            AjustesIcono(sistema: sistema, color: color)
            Text(titulo)
            Spacer(minLength: 8)
            Text(valor)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
            if bloqueada {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .opacity(bloqueada ? 0.5 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityValue(bloqueada ? "\(valor). Bloqueado por Tema del sistema" : valor)
    }
}

// MARK: - Selector de color

struct AjustesCirculoColor: View {
    let opcion: ColorListoAjuste
    let seleccionado: Bool
    let accion: () -> Void

    @ScaledMetric(relativeTo: .body) private var diametro: CGFloat = 30

    var body: some View {
        Button(action: accion) {
            ZStack {
                Circle()
                    .strokeBorder(seleccionado ? EstiloVisual.acento : .clear, lineWidth: 2.5)
                    .frame(width: diametro + 8, height: diametro + 8)
                Circle()
                    .fill(opcion.color)
                    .frame(width: diametro, height: diametro)
                    .overlay {
                        Circle().strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    }
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Color \(opcion.nombre)")
        .accessibilityValue(seleccionado ? "Seleccionado" : "No seleccionado")
        .accessibilityHint("Selecciona este color para cuando el temporizador esté listo")
        .accessibilityAddTraits(seleccionado ? .isSelected : AccessibilityTraits())
    }
}

// MARK: - Tarjeta de tema

struct AjustesTarjetaTema: View {
    let tema: TemaAjuste
    let seleccionado: Bool
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            VStack(spacing: 8) {
                superficieMiniatura
                Text(tema.nombre)
                    .font(.caption2)
                    .foregroundStyle(seleccionado ? EstiloVisual.acento : Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(seleccionado ? EstiloVisual.acento.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        seleccionado ? EstiloVisual.acento : Color.secondary.opacity(0.25),
                        lineWidth: seleccionado ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tema \(tema.nombre)")
        .accessibilityValue(seleccionado ? "Seleccionado" : "No seleccionado")
        .accessibilityHint("Selecciona este tema para la vista previa")
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(seleccionado ? .isSelected : AccessibilityTraits())
    }

    private var superficieMiniatura: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(tema.fondo)

            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(tema.superficie)
                    .frame(height: 42)
                    .overlay(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 3) {
                            Capsule().fill(tema.linea).frame(height: 3)
                            Capsule().fill(tema.linea).frame(height: 3)
                            Capsule().fill(tema.acento).frame(height: 3).padding(.trailing, 8)
                        }
                        .padding(6)
                    }

                Capsule().fill(tema.linea).frame(height: 4).padding(.horizontal, 4)
                Capsule().fill(tema.linea).frame(height: 4).padding(.horizontal, 4)
            }
            .padding(7)
        }
        .frame(height: 66)
        .accessibilityHidden(true)
    }
}

// MARK: - Vistas previas

struct AjustesVistaPreviaScramble: View {
    let tamano: TamanoScramble

    var body: some View {
        Text("R U2 F′ D L2 B R′ U")
            .font(.system(size: tamano.tamanoFuente, weight: .medium, design: .monospaced))
            .foregroundStyle(.primary)
            .minimumScaleFactor(0.6)
            .lineLimit(2)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                Color(uiColor: .tertiarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .animation(.easeInOut(duration: 0.2), value: tamano)
            .accessibilityLabel("Vista previa del scramble: R U2 F prima D L2 B R prima U")
    }
}

struct AjustesVistaPreviaTimer: View {
    let tamano: Double
    let precision: PrecisionAjuste

    var body: some View {
        Text(precision.ejemplo)
            .font(.system(size: CGFloat(tamano), weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                Color(uiColor: .tertiarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .animation(.easeInOut(duration: 0.2), value: tamano)
            .animation(.easeInOut(duration: 0.2), value: precision)
            .accessibilityLabel("Vista previa del temporizador")
            .accessibilityValue(precision.ejemplo)
    }
}

// MARK: - Aviso honesto de función futura

extension View {
    func mostrarAviso(_ aviso: Binding<AjustesAviso?>) -> some View {
        alert(
            aviso.wrappedValue?.titulo ?? "",
            isPresented: Binding(
                get: { aviso.wrappedValue != nil },
                set: { if !$0 { aviso.wrappedValue = nil } }
            ),
            presenting: aviso.wrappedValue
        ) { _ in
            Button("Entendido", role: .cancel) { }
        } message: { aviso in
            Text(aviso.mensaje)
        }
    }
}
