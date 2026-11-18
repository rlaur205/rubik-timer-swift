import Foundation
import SwiftUI

@MainActor
class RubikViewModel: ObservableObject {
    
    @Published var tiemposPrincipal: [Sesion] = []
    @Published var sesionActual: Sesion = Sesion(tiempos: [], nombre: "", categoria: "")
    @Published var tiemposRecorrer: [Tiempo] = []
    @Published var scrambleActual: String = ""
    @Published var idActual: UUID? = nil //id de la session actual
    @Published var ordenActual = Orden.fecha
    @Published private var idTiempoMostrado: UUID?

    var resultadoCronometro: Tiempo? {
        guard let ultimo = sesionActual.tiempos.last, ultimo.id == idTiempoMostrado else { return nil }
        return ultimo
    }
    
    @Published var timerState = TimerState(
        estaCorriendo: false,
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
        // Cuando el motor termine el primer scramble, lo mostramos si la pantalla
        // sigue vacía (al arrancar la cola todavía está en marcha).
        ScrambleService.shared.alPrimerScramble = { [weak self] categoria in
            guard let self,
                  self.scrambleActual.isEmpty,
                  categoria == self.categoriaSeleccionada
            else { return }

            self.scrambleActual = ScrambleService.shared.siguiente(categoria: categoria)
        }
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

    func establecerPenalizacion(_ penalizacion: PenalizacionTiempo, tiempoID: UUID) {
        guard let sesion = tiemposPrincipal.first(where: { $0.id == sesionActual.id }),
              let indice = sesion.tiempos.firstIndex(where: { $0.id == tiempoID }) else { return }

        if sesion.tiempos.last?.id == tiempoID {
            idTiempoMostrado = tiempoID
        }
        guard sesion.tiempos[indice].penalizacion != penalizacion else { return }

        sesion.tiempos[indice].penalizacion = penalizacion
        sesionActual = sesion
        tiemposRecorrer = ordentiemposMostrar(
            orden: ordenActual,
            catSele: categoriaSeleccionada,
            nomSele: nombreSeleccionada,
            tPrincipal: tiemposPrincipal
        )
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
        idTiempoMostrado = nil
        
        guard timerState.tiempoTranscurrido >= 0.01 else { return }
        
        if let index = tiemposPrincipal.firstIndex(where: { $0.id == sesionActual.id }) {
            let tiempo = Tiempo(
                tiempo: timerState.tiempoTranscurrido,
                scramble: scrambleActual,
                fecha: Date(),
                categoria: sesionActual.categoria
            )
            tiemposPrincipal[index].tiempos.append(tiempo)
            idTiempoMostrado = tiempo.id
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
        
        if !sesionActual.tiempos.isEmpty {
            idTiempoMostrado = nil
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
