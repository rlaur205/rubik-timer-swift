import SwiftUI

// MARK: - Filas

struct AjustesToggleFila: View {
    let titulo: String
    var subtitulo: String?
    @Binding var estaActivo: Bool

    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Toggle(isOn: $estaActivo) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                if let subtitulo {
                    Text(subtitulo)
                        .font(.footnote)
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(temaApp.acento)
    }
}

struct AjustesFilaValor: View {
    let titulo: String
    let valor: String
    var bloqueada = false
    var muestraIndicador = false

    @Environment(\.temaApp) private var temaApp

    var body: some View {
        HStack(spacing: 12) {
            Text(titulo)
            Spacer(minLength: 8)
            Text(valor)
                .foregroundStyle(temaApp.texto.opacity(0.65))
                .multilineTextAlignment(.trailing)
            if bloqueada {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(temaApp.texto.opacity(0.4))
                    .accessibilityHidden(true)
            }
            if muestraIndicador {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(temaApp.texto.opacity(0.35))
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
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Button(action: accion) {
            ZStack {
                Circle()
                    .strokeBorder(seleccionado ? temaApp.acento : .clear, lineWidth: 2.5)
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
    let tema: TemaApp
    let seleccionado: Bool
    let accion: () -> Void

    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Button(action: accion) {
            VStack(spacing: 8) {
                superficieMiniatura
                    .padding(.horizontal, 4)
                Text(tema.nombre)
                    .font(seleccionado ? .footnote.bold() : .caption2)
                    .foregroundStyle(seleccionado ? (temaApp.colorScheme == .dark ? Color.white : Color.black) : temaApp.texto.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tema \(tema.nombre)")
        .accessibilityValue(seleccionado ? "Seleccionado" : "No seleccionado")
        .accessibilityHint("Selecciona este tema para la app")
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(seleccionado ? .isSelected : AccessibilityTraits())
        .accessibilityIdentifier("tema-" + tema.rawValue)
    }

    private var superficieMiniatura: some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(tema.fondo)
            .frame(height: 66)
            .overlay {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(tema.superficie)
                        .frame(height: 42)
                        .overlay(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 3) {
                                Capsule().fill(tema.estilo(.resumen).acento).frame(height: 3)
                                Capsule().fill(tema.estilo(.promedios).acento).frame(height: 3)
                                Capsule().fill(tema.estilo(.records).acento).frame(height: 3).padding(.trailing, 8)
                            }
                            .padding(6)
                        }

                    Capsule().fill(tema.linea).frame(height: 4).padding(.horizontal, 4)
                    Capsule().fill(tema.linea).frame(height: 4).padding(.horizontal, 4)
                }
                .padding(.horizontal, 7)
            }
            .overlay(alignment: .bottomTrailing) {
                if seleccionado {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(temaApp.colorScheme == .dark ? Color.black : Color.white)
                        .frame(width: 16, height: 16)
                        .background(temaApp.estilo(.resumen).acento, in: Circle())
                        .padding(4)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Vistas previas

struct AjustesVistaPreviaScramble: View {
    let tamano: TamanoScramble
    var fuente: FuenteScrambleAjuste = .predeterminado
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Text("R U2 F′ D L2 B R′ U")
            // 3x3 es la categoría inicial; usa la misma escala que el cronómetro.
            .font(fuente.font(tamano: tamano.tamanoFuenteAjustado(para: "3x3"), pesoPredeterminado: .medium))
            .monospacedDigit()
            .foregroundStyle(temaApp.texto)
            .minimumScaleFactor(0.6)
            .lineLimit(2)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                temaApp.superficie,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .animation(.easeInOut(duration: 0.2), value: tamano)
            .animation(.easeInOut(duration: 0.2), value: fuente)
            .accessibilityLabel("Vista previa del scramble: R U2 F prima D L2 B R prima U")
            .accessibilityIdentifier("preview-scramble")
    }
}

struct AjustesVistaPreviaTimer: View {
    let tamano: Double
    let precision: PrecisionAjuste
    var fuente: FuenteTimerAjuste = .predeterminado
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        Text(precision.ejemplo)
            .font(fuente.font(tamano: CGFloat(tamano), pesoPredeterminado: .semibold))
            .monospacedDigit()
            .foregroundStyle(temaApp.texto)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                temaApp.superficie,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .animation(.easeInOut(duration: 0.2), value: tamano)
            .animation(.easeInOut(duration: 0.2), value: precision)
            .animation(.easeInOut(duration: 0.2), value: fuente)
            .accessibilityLabel("Vista previa del temporizador")
            .accessibilityValue(precision.ejemplo)
            .accessibilityIdentifier("preview-timer")
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
