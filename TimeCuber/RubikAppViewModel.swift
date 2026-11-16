import Foundation
import SwiftUI

class RubikViewModel: ObservableObject {
    
    @Published var tiemposPrincipal: [Sesion] = []
    @Published var sesionActual: Sesion = Sesion(tiempos: [], nombre: "", categoria: "")
    @Published var tiemposRecorrer: [Tiempo] = []
    @Published var scrambleActual: String = ""
    @Published var idActual: UUID? = nil //id de la session actual
    @Published var ordenActual = Orden.fecha
    
    @Published var timerState = TimerState(
        estaCorriendo: false,
        estaTocando: false,
        tiempoInicio: nil,
        tiempoTranscurrido: 0,
        visibilidadPromedios: false
    )
    
    @Published var categoriaSeleccionada: String = UserDefaults.standard.string(forKey: "categoriaSeleccionada") ?? "3x3" {
        didSet {
            // Cuando esta variable cambie, guardamos el nuevo valor en la memoria del teléfono
            UserDefaults.standard.set(categoriaSeleccionada, forKey: "categoriaSeleccionada")
            // Y vamos preparando scrambles de la nueva categoría en segundo plano
            ScrambleService.shared.precargar(categoria: categoriaSeleccionada)
        }
    }
        
    @Published var nombreSeleccionada: String = UserDefaults.standard.string(forKey: "nombreSeleccionada") ?? "Standard" {
        didSet {
            // Lo mismo: si cambia el nombre, lo guardamos
            UserDefaults.standard.set(nombreSeleccionada, forKey: "nombreSeleccionada")
        }
    }
    
    init() {
        cargarSesiones()
        actualizarVista()
        // Arranca el motor de scrambles y empieza a precargar en segundo plano
        ScrambleService.shared.iniciar(categoria: categoriaSeleccionada)
    }

    func guardarSesiones() {
        let codificador = JSONEncoder()
        codificador.dateEncodingStrategy = .iso8601
        
        do {
            let datosCodificados = try codificador.encode(tiemposPrincipal)
            
            // CAMBIO 3: Guardamos "datosCodificados" en UserDefaults
            UserDefaults.standard.set(datosCodificados, forKey: "savedSesiones")
            
            print("Sesiones guardadas exitosamente")
        } catch {
            print("Error al guardar sesiones: \(error)")
        }
    }

    func cargarSesiones() {
        let decodificador = JSONDecoder()
        decodificador.dateDecodingStrategy = .iso8601

        if let datosGuardados = UserDefaults.standard.data(forKey: "savedSesiones"),
           let datosDecodificados = try? decodificador.decode([Sesion].self, from: datosGuardados) {
            
            tiemposPrincipal = datosDecodificados
            print("Sesiones cargadas exitosamente")
            
        } else {
            print("No hay sesiones guardadas, cargando defaults")
            tiemposPrincipal = [
                Sesion(tiempos: [], nombre: "Standard", categoria: "3x3"),
                Sesion(tiempos: [], nombre: "Standard2", categoria: "2x2"),
                Sesion(tiempos: [], nombre: "Standard4", categoria: "4x4"),
                Sesion(tiempos: [], nombre: "Standard3", categoria: "5x5"),
                Sesion(tiempos: [], nombre: "Standard6", categoria: "5x5")
            ]
        }
    }
    
    
    // ESTA ES LA FUNCIÓN QUE CALCULA TODO
    func actualizarVista() {
        // 1. Calculamos la lista de tiempos a mostrar (usando TU función global)
        tiemposRecorrer = obtenerTiemposRecorrer(
            categoria: categoriaSeleccionada,
            nombreCategoria: nombreSeleccionada,
            listaSesiones: tiemposPrincipal
        ).reversed()
        
        // 2. Buscamos la sesión actual (usando TU función global)
        sesionActual = obtenerSesionActual(
            categoria: categoriaSeleccionada,
            nombreCategoria: nombreSeleccionada,
            listaSesiones: tiemposPrincipal
        )
        
        // 3. Actualizamos el ID para que la vista sepa cuál es
        idActual = sesionActual.id
        
        // 4. Si no hay scramble (mezcla), generamos uno nuevo
        if scrambleActual.isEmpty {
            scrambleActual = ScrambleService.shared.siguiente(categoria: categoriaSeleccionada)
        }
    }
    
    
    func eliminarTiempoSeleccionado(tiempo:Tiempo){
        for index in tiemposPrincipal.indices {
            if tiemposPrincipal[index].id == idActual {
                tiemposPrincipal[index].tiempos.removeAll { $0.id == tiempo.id }
                tiemposRecorrer = ordentiemposMostrar(orden: ordenActual, catSele: categoriaSeleccionada, nomSele: nombreSeleccionada, tPrincipal: tiemposPrincipal)
                guardarSesiones()
                return
            }
        }
    }
    
    func eliminarTodosTiempos(){
        tiemposRecorrer = []
        for i in tiemposPrincipal{
            if i.id == idActual{
                i.tiempos = []
            }
        }
        guardarSesiones()
    }
    
    func cambiarOrden(_ orden: Orden){
        
        ordenActual = orden
        
            tiemposRecorrer = ordentiemposMostrar(
                orden: orden,
                catSele: categoriaSeleccionada,
                nomSele: nombreSeleccionada,
                tPrincipal: tiemposPrincipal
            )
        }
    
    
    func registrarNuevoTiempo() {
        
        if let inicio = timerState.tiempoInicio {
            timerState.tiempoTranscurrido = Date().timeIntervalSince(inicio)
            }
            
        timerState.tiempoInicio = nil
        
        guard timerState.tiempoTranscurrido >= 0.01 else { return }
        
        if let index = tiemposPrincipal.firstIndex(where: { $0.id == sesionActual.id }) {
            tiemposPrincipal[index].tiempos.append(
                Tiempo(tiempo: timerState.tiempoTranscurrido, scramble: scrambleActual, fecha: Date())
            )
            tiemposRecorrer = obtenerTiemposRecorrer(
                categoria: sesionActual.categoria,
                nombreCategoria: sesionActual.nombre,
                listaSesiones: tiemposPrincipal
            ).reversed()
            sesionActual = tiemposPrincipal[index]
            guardarSesiones()
        }
        scrambleActual = ScrambleService.shared.siguiente(categoria: sesionActual.categoria)
    }

    func borrarUltimoTiempo() {
        
        if(obtenerTiempos(sesion: sesionActual).count != 0){
            timerState.estaCorriendo = false
            timerState.tiempoTranscurrido = 0
            
            for i in tiemposPrincipal {
                if i.id == sesionActual.id {
                    if let index = tiemposPrincipal.firstIndex(where: { $0.id == sesionActual.id }) {
                        tiemposPrincipal[index].tiempos.removeLast()
                        
                        // Forzar actualización de tiemposRecorrer
                        tiemposRecorrer = obtenerTiemposRecorrer(
                            categoria: sesionActual.categoria,
                            nombreCategoria: sesionActual.nombre,
                            listaSesiones: tiemposPrincipal
                        ).reversed()
                        
                        sesionActual = tiemposPrincipal[index]
                        
                        guardarSesiones()
                    }
                    break
                }
            }
            
            scrambleActual = ScrambleService.shared.siguiente(categoria: sesionActual.categoria)
            timerState.visibilidadPromedios = true

        
        }
    }
    
    func borrarCategoria(sesionAEliminar: Sesion){
        if let index = tiemposPrincipal.firstIndex(where: { $0.id == sesionAEliminar.id }) {
            tiemposPrincipal.remove(at: index)

            if idActual == sesionAEliminar.id {
                if let firstSesion = tiemposPrincipal.first {
                    idActual = firstSesion.id
                    nombreSeleccionada = firstSesion.nombre
                    categoriaSeleccionada = firstSesion.categoria
                } else {
                    idActual = nil
                }
            }
        }
    }
    
    func nuevoScramble() {
        scrambleActual = ScrambleService.shared.siguiente(categoria: categoriaSeleccionada)
    }

    
}
