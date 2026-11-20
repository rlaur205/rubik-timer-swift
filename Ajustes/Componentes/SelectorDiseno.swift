import SwiftUI

struct SelectorDiseno: View {
    @Binding var retroActivo: Bool
    let esquemaClasico: ColorScheme
    let esquemaRetro: ColorScheme
    let texto: Color
    let linea: Color
    let seleccion: Color

    @Environment(\.dynamicTypeSize) private var tamanoTexto

    private var distribucion: AnyLayout {
        if tamanoTexto.isAccessibilitySize {
            return AnyLayout(VStackLayout(spacing: 10))
        }
        return AnyLayout(HStackLayout(spacing: 10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Diseño de la app")
                .font(.subheadline.weight(.semibold))
                .accessibilityAddTraits(.isHeader)

            distribucion {
                tarjeta("Clásico", retro: false, esquema: esquemaClasico)
                tarjeta("Retro", retro: true, esquema: esquemaRetro)
            }
        }
        .foregroundStyle(texto)
    }

    private func tarjeta(_ titulo: String, retro: Bool, esquema: ColorScheme) -> some View {
        let activa = retroActivo == retro
        let forma = RoundedRectangle(cornerRadius: retroActivo ? 7 : 11)

        return Button {
            retroActivo = retro
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                IlustracionDiseno(retro: retro, oscura: esquema == .dark)
                    .aspectRatio(1.85, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: retroActivo ? 4 : 7))
                    .accessibilityHidden(true)

                HStack(spacing: 4) {
                    Text(titulo)
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 2)
                    Image(systemName: activa ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(activa ? seleccion : linea)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 3)
                .padding(.bottom, 2)
            }
            .padding(5)
            .background(activa ? seleccion.opacity(0.10) : .clear, in: forma)
            .overlay {
                forma.strokeBorder(activa ? seleccion : linea, lineWidth: activa ? 2 : 1)
            }
            .contentShape(forma)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(activa ? .isSelected : [])
        .accessibilityIdentifier(retro ? "diseno-retro" : "diseno-clasico")
    }
}

private struct IlustracionDiseno: View {
    let retro: Bool
    let oscura: Bool

    var body: some View {
        Canvas { contexto, tamano in
            var dibujo = contexto
            dibujo.scaleBy(x: tamano.width / 160, y: tamano.height / 88)
            if retro {
                dibujarRetro(dibujo)
            } else {
                dibujarClasico(dibujo)
            }
        }
    }

    private func dibujarClasico(_ dibujo: GraphicsContext) {
        let fondo = oscura ? Color(red: 0.08, green: 0.10, blue: 0.16) : Color(red: 0.87, green: 0.91, blue: 0.95)
        let superficie = oscura ? Color(red: 0.13, green: 0.17, blue: 0.25) : Color(red: 0.94, green: 0.96, blue: 0.98)
        let borde = oscura ? Color(red: 0.24, green: 0.31, blue: 0.42) : Color(red: 0.72, green: 0.79, blue: 0.86)
        let tinta = oscura ? Color(red: 0.62, green: 0.72, blue: 0.85) : Color(red: 0.18, green: 0.27, blue: 0.40)
        let acento = oscura ? Color(red: 0.37, green: 0.52, blue: 0.72) : Color(red: 0.30, green: 0.49, blue: 0.70)

        dibujo.fill(Path(CGRect(x: 0, y: 0, width: 160, height: 88)), with: .color(fondo))

        let panel = Path(roundedRect: CGRect(x: 22, y: 13, width: 116, height: 62), cornerRadius: 13)
        dibujo.fill(panel, with: .color(superficie))
        dibujo.stroke(panel, with: .color(borde), lineWidth: 1)

        for (desplazamiento, color) in [(-9.0, borde), (0.0, tinta), (9.0, acento)] {
            var curva = Path()
            curva.move(to: CGPoint(x: 43, y: 50 + desplazamiento))
            curva.addCurve(
                to: CGPoint(x: 80, y: 44 + desplazamiento),
                control1: CGPoint(x: 56, y: 50 + desplazamiento),
                control2: CGPoint(x: 63, y: 29 + desplazamiento)
            )
            curva.addCurve(
                to: CGPoint(x: 117, y: 38 + desplazamiento),
                control1: CGPoint(x: 97, y: 59 + desplazamiento),
                control2: CGPoint(x: 104, y: 38 + desplazamiento)
            )
            dibujo.stroke(curva, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }

    private func dibujarRetro(_ dibujo: GraphicsContext) {
        let paleta = PaletaRetro(oscura: oscura)
        dibujo.fill(Path(CGRect(x: 0, y: 0, width: 160, height: 88)), with: .color(paleta.fondo))

        for x in stride(from: 8, to: 160, by: 12) {
            for y in stride(from: 8, to: 88, by: 12) {
                let punto = CGRect(x: x, y: y, width: 1, height: 1)
                dibujo.fill(Path(ellipseIn: punto), with: .color(paleta.texto.opacity(0.32)))
            }
        }

        bloque(CGRect(x: 21, y: 15, width: 75, height: 56), color: paleta.lavanda)
        bloque(CGRect(x: 80, y: 25, width: 57, height: 45), color: paleta.naranja)
        bloque(CGRect(x: 97, y: 13, width: 44, height: 17), color: paleta.lima)

        for (x, alto) in [(34.0, 13.0), (45.0, 22.0), (56.0, 31.0), (67.0, 18.0)] {
            dibujo.fill(Path(CGRect(x: x, y: 59 - alto, width: 6, height: alto)), with: .color(paleta.tinta))
        }

        var cruz = Path()
        cruz.move(to: CGPoint(x: 102, y: 49))
        cruz.addLine(to: CGPoint(x: 118, y: 49))
        cruz.move(to: CGPoint(x: 110, y: 41))
        cruz.addLine(to: CGPoint(x: 110, y: 57))
        dibujo.stroke(cruz, with: .color(paleta.tinta), lineWidth: 2.5)

        func bloque(_ rect: CGRect, color: Color) {
            let forma = Path(roundedRect: rect, cornerRadius: 5)
            dibujo.fill(Path(roundedRect: rect.offsetBy(dx: 3, dy: 4), cornerRadius: 5), with: .color(paleta.sombra))
            dibujo.fill(forma, with: .color(color))
            dibujo.stroke(forma, with: .color(paleta.tinta), lineWidth: 1.8)
        }
    }
}
