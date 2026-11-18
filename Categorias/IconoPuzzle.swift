import SwiftUI

/// Pictogramas vectoriales dibujados en una cuadrícula de 100 × 100.
struct IconoPuzzle: View {
    let categoria: String
    var size: CGFloat = 22
    var multiplicadorTrazo: CGFloat = 1

    var body: some View {
        Canvas { contexto, medidas in
            var contexto = contexto
            let escala = min(medidas.width, medidas.height) / 100
            contexto.scaleBy(x: escala, y: escala)

            let variante = categoria.split(separator: " ").last
            let dimension = max(1, categoria.first?.wholeNumberValue ?? 1)
            let tieneVariante = variante == "BLD" || variante == "OH"
            var dibujo = contexto
            if tieneVariante {
                dibujo.translateBy(x: 2, y: 0)
                dibujo.scaleBy(x: 0.82, y: 0.82)
            }

            let trazado: Path
            switch categoria {
            case "Pyraminx": trazado = Self.pyraminx
            case "Megaminx": trazado = Self.megaminx
            case "Skewb": trazado = Self.skewb
            case "Square 1": trazado = Self.square1
            default: trazado = Self.cuadricula(dimension)
            }

            // Un trazo más fino conserva las divisiones de los cubos grandes en la cuadrícula.
            let grosor: CGFloat = medidas.width <= 26 && dimension >= 5 ? 1.6 : 2.2
            dibujo.stroke(
                trazado,
                with: .foreground,
                style: StrokeStyle(lineWidth: grosor * multiplicadorTrazo, lineCap: .round, lineJoin: .round)
            )

            if tieneVariante {
                contexto.stroke(
                    variante == "BLD" ? Self.ojoTachado : Self.mano,
                    with: .foreground,
                    style: StrokeStyle(lineWidth: 3.6 * multiplicadorTrazo, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private static let caraCuadrada = CGRect(x: 12, y: 12, width: 76, height: 76)

    private static func cuadricula(_ dimension: Int) -> Path {
        let cara = caraCuadrada
        return Path { trazado in
            trazado.addRect(cara)
            for linea in 1..<dimension {
                let avance = CGFloat(linea) * cara.width / CGFloat(dimension)
                let x = cara.minX + avance
                let y = cara.minY + avance
                trazado.linea(CGPoint(x: x, y: cara.minY), CGPoint(x: x, y: cara.maxY))
                trazado.linea(CGPoint(x: cara.minX, y: y), CGPoint(x: cara.maxX, y: y))
            }
        }
    }

    private static let skewb = Path { trazado in
        let cara = caraCuadrada
        trazado.addRect(cara)
        trazado.poligono([
            CGPoint(x: cara.midX, y: cara.minY),
            CGPoint(x: cara.maxX, y: cara.midY),
            CGPoint(x: cara.midX, y: cara.maxY),
            CGPoint(x: cara.minX, y: cara.midY)
        ])
    }

    private static let square1 = Path { trazado in
        let cara = caraCuadrada
        let centro = CGPoint(x: cara.midX, y: cara.midY)
        // Cada pieza de arista ocupa 30°, centrados en el lado de la cara.
        let semibase = cara.width / 2 * tan(CGFloat.pi / 12)

        trazado.addRect(cara)
        for lado in [cara.minY, cara.maxY] {
            trazado.linea(centro, CGPoint(x: centro.x - semibase, y: lado))
            trazado.linea(centro, CGPoint(x: centro.x + semibase, y: lado))
        }
        for lado in [cara.minX, cara.maxX] {
            trazado.linea(centro, CGPoint(x: lado, y: centro.y - semibase))
            trazado.linea(centro, CGPoint(x: lado, y: centro.y + semibase))
        }
    }

    private static let pyraminx = Path { trazado in
        func punto(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: 50 + 44 * (x - y), y: 8 + 80 * (x + y))
        }

        trazado.poligono([punto(0, 0), punto(1, 0), punto(0, 1)])
        for linea in 1...2 {
            let avance = CGFloat(linea) / 3
            trazado.linea(punto(avance, 0), punto(0, avance))
            trazado.linea(punto(avance, 0), punto(avance, 1 - avance))
            trazado.linea(punto(0, avance), punto(1 - avance, avance))
        }
    }

    private static let megaminx = Path { trazado in
        let paso = 2 * CGFloat.pi / 5
        let inicio = -CGFloat.pi / 2
        let angulos = (0..<5).map { inicio + CGFloat($0) * paso }
        let contorno = angulos.map { CGPoint(x: 50 + 45 * cos($0), y: 52 + 45 * sin($0)) }
        let centro = angulos.map { CGPoint(x: 50 + 20 * cos($0), y: 52 + 20 * sin($0)) }

        trazado.poligono(contorno)
        trazado.poligono(centro)
        for indice in contorno.indices {
            let actual = contorno[indice]
            let siguiente = contorno[(indice + 1) % contorno.count]
            let mitad = CGPoint(x: (actual.x + siguiente.x) / 2, y: (actual.y + siguiente.y) / 2)
            trazado.linea(centro[indice], actual)
            trazado.linea(centro[indice], mitad)
        }
    }

    private static let ojoTachado = Path { trazado in
        trazado.move(to: CGPoint(x: 65, y: 87))
        trazado.addQuadCurve(to: CGPoint(x: 97, y: 87), control: CGPoint(x: 81, y: 68))
        trazado.addQuadCurve(to: CGPoint(x: 65, y: 87), control: CGPoint(x: 81, y: 104))
        trazado.linea(CGPoint(x: 70, y: 74), CGPoint(x: 92, y: 98))
    }

    private static let mano = Path { trazado in
        trazado.move(to: CGPoint(x: 74, y: 98))
        trazado.addLines([
            CGPoint(x: 66, y: 86), CGPoint(x: 70, y: 83), CGPoint(x: 75, y: 88),
            CGPoint(x: 75, y: 72), CGPoint(x: 81, y: 72), CGPoint(x: 81, y: 84),
            CGPoint(x: 86, y: 79), CGPoint(x: 95, y: 84), CGPoint(x: 94, y: 98)
        ])
        trazado.closeSubpath()
    }
}

private extension Path {
    mutating func linea(_ inicio: CGPoint, _ final: CGPoint) {
        move(to: inicio)
        addLine(to: final)
    }

    mutating func poligono(_ puntos: [CGPoint]) {
        addLines(puntos)
        closeSubpath()
    }
}
