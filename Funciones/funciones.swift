import Foundation

func formatoTiempo(_ segundosTotales: Double) -> String {
    // Corrige el error de representación binaria al caer justo en un milisegundo.
    let milisegundos = Int((segundosTotales * 1000).nextUp)
    let minutos = milisegundos / 60_000
    let segundos = milisegundos / 1000 % 60
    let decimas = milisegundos % 1000
    
    if minutos > 0 {
        return String(format: "%d:%02d.%03d", minutos, segundos, decimas)
    } else {
        return String(format: "%d.%03d", segundos, decimas)
    }
}



func formatoFecha(_ fecha: Date) -> String {
        let formateadorFecha = DateFormatter()
        formateadorFecha.dateFormat = "dd/MM/yy HH:mm"
        formateadorFecha.locale = Locale(identifier: "es_ES") // Establecer el locale para formato de 24 horas
        return formateadorFecha.string(from: fecha)
    }






func ft(_ segundosTotales: Double) -> String {
    let minutos = Int(segundosTotales) / 60
    let segundos = Int(segundosTotales) % 60
    let decimas = Int((segundosTotales * 1000).truncatingRemainder(dividingBy: 1000))
    
    if minutos > 0 {
        return String(format: "%d:%02d.%03d", minutos, segundos, decimas)
    } else {
        return String(format: "%d.%03d", segundos, decimas)
    }
}



func convertirAHoras(_ horaTexto: String) -> Double {
    let partes = horaTexto.components(separatedBy: ":")
    var minutos = 0
    var segundos = 0.0

    if partes.count == 2 {
        if let mins = Int(partes[0]), let secs = Double(partes[1]) {
            minutos = mins
            segundos = secs
        }
    } else if partes.count == 1 {
        if let secs = Double(partes[0]) {
            segundos = secs
        }
    } else {
        fatalError("El formato de la hora no es válido.")
    }

    return Double(minutos) * 60 + segundos
}


func ordenarTiempos(_ tiempos: [Tiempo], por orden: Orden) -> [Tiempo] {
    switch orden {
    case .fecha:
        return tiempos.reversed()
    case .ascendente:
        return tiempos.sorted { ($0.segundosValidos ?? .infinity) < ($1.segundosValidos ?? .infinity) }
    case .descendente:
        return ordenarTiempos(tiempos, por: .ascendente).reversed()
    }
}
