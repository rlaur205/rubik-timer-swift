import Foundation

func obtenerMejorPeor(listaTiempos: [Double], tipo: String) -> Double {
    guard !listaTiempos.isEmpty else {
        return 0.00
    }
    var tiempoSeleccionado: Double?
    if tipo == "mejor" {
        tiempoSeleccionado = listaTiempos.min()
    } else if tipo == "peor" {
        tiempoSeleccionado = listaTiempos.max()
    }
    if let tiempo = tiempoSeleccionado {
        // Retornamos el tiempo formateado
        return tiempo
    }
    
    return 0.00
}




func formatoTiempo(_ segundosTotales: Double) -> String {
    let minutos = Int(segundosTotales) / 60
    let segundos = Int(segundosTotales) % 60
    let decimas = Int((segundosTotales * 1000).truncatingRemainder(dividingBy: 1000))
    
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




func ordenarLista(_ lista: [Tiempo]) -> [Tiempo] {
    if lista.count <= 1 {
        return lista
    } else {
        // El pivote es el elemento en el medio del array
        let pivote = lista[lista.count / 2].tiempo
        
        // Se crean tres arrays: izq, centro y der
        var izq: [Tiempo] = []
        var der: [Tiempo] = []
        var centro: [Tiempo] = []
        
        // Iterar sobre cada elemento de la lista y distribuir en izq, centro o der según el valor de 'tiempo'
        for item in lista {
            if item.tiempo < pivote {
                izq.append(item)
            } else if item.tiempo == pivote {
                centro.append(item)
            } else {
                der.append(item)
            }
        }
        
        return ordenarLista(izq) + centro + ordenarLista(der)
    }
}



func obtenerTiemposRecorrer(categoria: String, nombreCategoria: String, listaSesiones: [Sesion]) -> [Tiempo] {
    var tiempos: [Tiempo] = []  // Inicializamos como array vacío
    
    // Recorremos las sesiones
    for sesion in listaSesiones {
        if sesion.nombre == nombreCategoria && sesion.categoria == categoria {
            tiempos = sesion.tiempos
            break
        }
    }
    
    return tiempos
}


func obtenerSesionActual(categoria: String, nombreCategoria: String, listaSesiones: [Sesion]) -> Sesion {

    var sesionActual: Sesion = Sesion(tiempos: [], nombre: "", categoria: "")
    
    for sesion in listaSesiones {
        if sesion.nombre == nombreCategoria && sesion.categoria == categoria {
            sesionActual = sesion
            break
        }
    }
    
    return sesionActual
}

func obtenerTiempos(sesion: Sesion) -> [Double] {
    
    var tiempos:[Double] = []
    
    for i in sesion.tiempos {
        tiempos.append(i.tiempo)
    }
    return tiempos
}


func ordentiemposMostrar(orden: Orden, catSele: String, nomSele: String, tPrincipal: [Sesion]) -> [Tiempo] {
    if orden == .fecha {
        return obtenerTiemposRecorrer(categoria: catSele, nombreCategoria: nomSele, listaSesiones: tPrincipal).reversed()
    } else if orden == .ascendente {
        return ordenarLista(obtenerTiemposRecorrer(categoria: catSele, nombreCategoria: nomSele, listaSesiones: tPrincipal))
    } else {
        return ordenarLista(obtenerTiemposRecorrer(categoria: catSele, nombreCategoria: nomSele, listaSesiones: tPrincipal)).reversed()
    }
}
