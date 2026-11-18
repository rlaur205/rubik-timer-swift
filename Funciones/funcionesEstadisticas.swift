import Foundation

enum ResultadoPromedio: Equatable {
    case insuficiente
    case valor(Double)
    case dnf
}

struct ResultadoPB {
    let resultado: ResultadoPromedio
    let tiempos: [Tiempo]
}

func mejorTiempo(tiempos: [Tiempo]) -> Tiempo? {
    tiempos
        .filter { $0.segundosValidos != nil }
        .min { ($0.segundosValidos ?? .infinity) < ($1.segundosValidos ?? .infinity) }
}

func peorTiempo(tiempos: [Tiempo]) -> Tiempo? {
    tiempos
        .filter { $0.segundosValidos != nil }
        .max { ($0.segundosValidos ?? -.infinity) < ($1.segundosValidos ?? -.infinity) }
}

func mediaTotal(tiempos: [Tiempo]) -> ResultadoPromedio {
    let validos = tiempos.compactMap(\.segundosValidos)
    guard !validos.isEmpty else {
        return .insuficiente
    }
    return .valor(validos.reduce(0, +) / Double(validos.count))
}

func mo3(tiempos: [Tiempo]) -> ResultadoPromedio {
    guard tiempos.count >= 3 else {
        return .insuficiente
    }
    return calcularMo3(tiempos.suffix(3))
}

func avg(tiempos: [Tiempo], cantidad: Int) -> ResultadoPromedio {
    guard cantidad >= 3, tiempos.count >= cantidad else {
        return .insuficiente
    }
    return calcularAvg(tiempos.suffix(cantidad), cantidad: cantidad)
}

func PBmo3(tiempos: [Tiempo]) -> ResultadoPB {
    mejorVentanaPB(tiempos: tiempos, cantidad: 3) { ventana in
        calcularMo3(ventana)
    }
}

func PBavg(tiempos: [Tiempo], cantidad: Int) -> ResultadoPB {
    mejorVentanaPB(tiempos: tiempos, cantidad: cantidad) { ventana in
        calcularAvg(ventana, cantidad: cantidad)
    }
}

func desviacion(tiempos: [Tiempo]) -> String {
    let validos = tiempos.compactMap(\.segundosValidos)
    guard validos.count >= 2 else {
        return "—"
    }

    let count = Double(validos.count)
    let media = validos.reduce(0.0, +) / count
    let sumatorioCuadradosDiferencias = validos.reduce(0.0) { result, valor in
        let diferencia = valor - media
        return result + (diferencia * diferencia)
    }
    let valorDesviacion = sqrt(sumatorioCuadradosDiferencias / (count - 1))
    return String(format: "%.2f", valorDesviacion)
}

func grafica(tiempos: [Tiempo]) -> [Item] {
    tiempos.enumerated().compactMap { index, tiempo in
        guard let segundos = tiempo.segundosValidos else {
            return nil
        }
        return Item(value: segundos, indice: index + 1)
    }
}

private func calcularMo3<S: Collection>(_ ventana: S) -> ResultadoPromedio where S.Element == Tiempo {
    guard ventana.count == 3 else {
        return .insuficiente
    }
    var suma = 0.0
    for tiempo in ventana {
        guard let segundos = tiempo.segundosValidos else {
            return .dnf
        }
        suma += segundos
    }
    return .valor(suma / 3.0)
}

private func calcularAvg<S: Collection>(_ ventana: S, cantidad: Int) -> ResultadoPromedio where S.Element == Tiempo {
    guard cantidad >= 3, ventana.count == cantidad else {
        return .insuficiente
    }

    var suma = 0.0
    var minimo = Double.infinity
    var maximo = -Double.infinity
    var cantidadDNF = 0

    for tiempo in ventana {
        if let segundos = tiempo.segundosValidos {
            suma += segundos
            if segundos < minimo { minimo = segundos }
            if segundos > maximo { maximo = segundos }
        } else {
            cantidadDNF += 1
            if cantidadDNF >= 2 {
                return .dnf
            }
        }
    }

    // Con 1 DNF se descarta como el peor y solo se elimina 1 mejor.
    let sumaRecortada = cantidadDNF == 1 ? (suma - minimo) : (suma - minimo - maximo)
    return .valor(sumaRecortada / Double(cantidad - 2))
}

private func mejorVentanaPB(
    tiempos: [Tiempo],
    cantidad: Int,
    evaluar: (ArraySlice<Tiempo>) -> ResultadoPromedio
) -> ResultadoPB {
    guard cantidad >= 3, tiempos.count >= cantidad else {
        return ResultadoPB(resultado: .insuficiente, tiempos: [])
    }

    var mejorValor: Double?
    var mejorVentana: ArraySlice<Tiempo>?
    var ventanaDNF: ArraySlice<Tiempo>?

    for inicio in 0...(tiempos.count - cantidad) {
        let ventana = tiempos[inicio..<(inicio + cantidad)]
        switch evaluar(ventana) {
        case .valor(let valor):
            if valor < (mejorValor ?? .infinity) {
                mejorValor = valor
                mejorVentana = ventana
            }
        case .dnf:
            if ventanaDNF == nil {
                ventanaDNF = ventana
            }
        case .insuficiente:
            break
        }
    }

    if let mejorValor, let mejorVentana {
        return ResultadoPB(resultado: .valor(mejorValor), tiempos: Array(mejorVentana))
    }
    if let ventanaDNF {
        return ResultadoPB(resultado: .dnf, tiempos: Array(ventanaDNF))
    }
    return ResultadoPB(resultado: .insuficiente, tiempos: [])
}
