import Foundation
import SwiftUI

@MainActor
class RubikViewModel: ObservableObject {
    private static let claveHistorial = "savedSesiones"
    private static let claveSesionSeleccionada = "sesionSeleccionadaID"

    @Published private(set) var tiemposPrincipal: [Sesion]
    @Published private(set) var sesionActual: Sesion
    @Published private(set) var tiemposRecorrer: [Tiempo] = []
    @Published private(set) var estadoScramble = EstadoScramble.preparando
    @Published private(set) var ordenActual = Orden.fecha
    @Published private var idTiempoMostrado: UUID?

    var scrambleActual: String {
        if case .listo(let scramble) = estadoScramble { return scramble }
        return ""
    }

    var scrambleListo: Bool {
        if case .listo = estadoScramble { return true }
        return false
    }

    var resultadoCronometro: Tiempo? {
        guard let ultimo = sesionActual.tiempos.last, ultimo.id == idTiempoMostrado else { return nil }
        return ultimo
    }

    var puedePenalizarUltimoTiempo: Bool { sesionActual.tiempos.last?.esDNFDeInspeccion == false }

    @Published private(set) var timerState = TimerState()
    private var vencimientoInspeccion: Task<Void, Never>?

    init() {
        let sesionesGuardadas = Self.cargarSesiones()
        let sesiones = sesionesGuardadas.flatMap { $0.isEmpty ? nil : $0 } ?? Self.sesionesIniciales()
        tiemposPrincipal = sesiones
        sesionActual = Self.recuperarSeleccion(en: sesiones) ?? sesiones[0]

        // Los UUID de las sesiones nuevas deben sobrevivir aunque aún no tengan tiempos.
        if UserDefaults.standard.object(forKey: Self.claveHistorial) == nil || sesionesGuardadas?.isEmpty == true {
            guardarSesiones()
        }
        guardarSeleccion()
        actualizarVista()

        ScrambleService.shared.alPrimerScramble = { [weak self] categoria in
            guard let self, self.estadoScramble == .preparando,
                  categoria == self.sesionActual.categoria else { return }
            self.nuevoScramble()
        }
        ScrambleService.shared.alFallar = { [weak self] categoria in
            guard let self, self.estadoScramble == .preparando,
                  categoria == self.sesionActual.categoria else { return }
            self.estadoScramble = .error
        }
        estadoScramble = ScrambleService.shared.iniciar(categoria: sesionActual.categoria)
    }

    private static func cargarSesiones() -> [Sesion]? {
        guard let datos = UserDefaults.standard.data(forKey: claveHistorial) else { return nil }
        let decodificador = JSONDecoder()
        decodificador.dateDecodingStrategy = .iso8601
        return try? decodificador.decode([Sesion].self, from: datos)
    }

    private static func sesionesIniciales() -> [Sesion] {
        [
            Sesion(tiempos: [], nombre: "Standard", categoria: "3x3"),
            Sesion(tiempos: [], nombre: "Standard2", categoria: "2x2"),
            Sesion(tiempos: [], nombre: "Standard4", categoria: "4x4"),
            Sesion(tiempos: [], nombre: "Standard3", categoria: "5x5"),
            Sesion(tiempos: [], nombre: "Standard6", categoria: "5x5")
        ]
    }

    private static func recuperarSeleccion(en sesiones: [Sesion]) -> Sesion? {
        let preferencias = UserDefaults.standard
        if let valor = preferencias.string(forKey: claveSesionSeleccionada),
           let id = UUID(uuidString: valor) {
            return sesiones.first { $0.id == id }
        }

        // Las versiones anteriores guardaban únicamente el nombre y la categoría.
        let nombre = preferencias.string(forKey: "nombreSeleccionada") ?? "Standard"
        let categoria = preferencias.string(forKey: "categoriaSeleccionada") ?? "3x3"
        return sesiones.first { $0.nombre == nombre && $0.categoria == categoria }
    }

    private func guardarSeleccion() {
        UserDefaults.standard.set(sesionActual.id.uuidString, forKey: Self.claveSesionSeleccionada)
    }

    private func guardarSesiones() {
        let codificador = JSONEncoder()
        codificador.dateEncodingStrategy = .iso8601

        do {
            let datos = try codificador.encode(tiemposPrincipal)
            UserDefaults.standard.set(datos, forKey: Self.claveHistorial)
        } catch {
            print("Error al guardar sesiones: \(error)")
        }
    }

    private func actualizarTiempos() {
        tiemposRecorrer = ordenarTiempos(sesionActual.tiempos, por: ordenActual)
    }

    private func guardarCambiosSesionActual() {
        actualizarTiempos()
        guardarSesiones()
    }

    func actualizarVista() {
        actualizarTiempos()
    }

    func eliminarTiempoSeleccionado(tiempo: Tiempo) {
        guard let indice = sesionActual.tiempos.firstIndex(where: { $0.id == tiempo.id }) else { return }
        sesionActual.tiempos.remove(at: indice)
        if idTiempoMostrado == tiempo.id {
            limpiarResultadoCronometro()
        }
        guardarCambiosSesionActual()
    }

    func eliminarTodosTiempos() {
        sesionActual.tiempos.removeAll()
        limpiarResultadoCronometro()
        guardarCambiosSesionActual()
    }

    func establecerPenalizacion(_ penalizacion: PenalizacionTiempo, tiempoID: UUID) {
        guard let indice = sesionActual.tiempos.firstIndex(where: { $0.id == tiempoID }),
              !sesionActual.tiempos[indice].esDNFDeInspeccion else { return }

        if sesionActual.tiempos.last?.id == tiempoID {
            idTiempoMostrado = tiempoID
        }
        guard sesionActual.tiempos[indice].penalizacion != penalizacion else { return }

        sesionActual.tiempos[indice].penalizacion = penalizacion
        guardarCambiosSesionActual()
    }

    func cambiarOrden(_ orden: Orden) {
        ordenActual = orden
        actualizarTiempos()
    }

    func iniciarInspeccion() {
        guard scrambleListo, !timerState.intentoActivo else { return }
        let reloj = ContinuousClock()
        let inicio = reloj.now
        timerState.fase = .inspeccion(inicio)

        vencimientoInspeccion = Task { [weak self] in
            do {
                try await reloj.sleep(until: inicio.advanced(by: TimerState.finInspeccion))
            } catch {
                return
            }

            self?.vencerInspeccion(inicio: inicio)
        }
    }

    func iniciarResolucion(desdeInspeccion: Bool) {
        guard scrambleListo, !timerState.estaCorriendo,
              timerState.enInspeccion == desdeInspeccion else { return }

        var penalizacion = PenalizacionTiempo.ninguna
        if case .inspeccion(let inicio) = timerState.fase {
            let transcurrido = inicio.duration(to: ContinuousClock().now)
            if transcurrido >= TimerState.finInspeccion {
                vencerInspeccion(inicio: inicio)
                return
            }
            if transcurrido >= TimerState.inspeccionSinPenalizacion {
                penalizacion = .masDos
            }
            cancelarVencimientoInspeccion()
        }

        idTiempoMostrado = nil
        timerState = TimerState(fase: .resolucion(Date(), penalizacion))
    }

    func detenerResolucion() {
        guard case .resolucion(let inicio, let penalizacion) = timerState.fase else { return }
        let duracion = Date().timeIntervalSince(inicio)
        timerState = TimerState(tiempoTranscurrido: duracion)
        guard duracion >= 0.01 else { return }

        registrarTiempo(duracion, penalizacion: penalizacion)
    }

    private func vencerInspeccion(inicio: ContinuousClock.Instant) {
        guard case .inspeccion(let activa) = timerState.fase, activa == inicio else { return }
        cancelarVencimientoInspeccion()
        timerState = TimerState()
        registrarTiempo(0, penalizacion: .dnf)
    }

    private func cancelarVencimientoInspeccion() {
        vencimientoInspeccion?.cancel()
        vencimientoInspeccion = nil
    }

    private func registrarTiempo(_ duracion: TimeInterval, penalizacion: PenalizacionTiempo) {
        guard case .listo(let scramble) = estadoScramble else { return }
        let tiempo = Tiempo(
            tiempo: duracion,
            scramble: scramble,
            fecha: Date(),
            categoria: sesionActual.categoria,
            penalizacion: penalizacion
        )
        sesionActual.tiempos.append(tiempo)
        idTiempoMostrado = tiempo.id
        guardarCambiosSesionActual()
        nuevoScramble()
    }

    func borrarUltimoTiempo(id: UUID) {
        guard !timerState.intentoActivo, sesionActual.tiempos.last?.id == id else { return }
        sesionActual.tiempos.removeLast()
        limpiarResultadoCronometro()
        guardarCambiosSesionActual()
        nuevoScramble()
    }

    private func limpiarResultadoCronometro() {
        idTiempoMostrado = nil
        if !timerState.intentoActivo { timerState.tiempoTranscurrido = 0 }
    }

    func seleccionarSesion(_ sesion: Sesion) {
        guard !timerState.intentoActivo, let guardada = tiemposPrincipal.first(where: { $0.id == sesion.id }) else { return }
        sesionActual = guardada
        guardarSeleccion()
        actualizarTiempos()
        nuevoScramble()
    }

    func crearSesion(nombre: String, categoria: String) -> Bool {
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nombreLimpio.isEmpty, nombreLimpio.count <= 10 else { return false }
        tiemposPrincipal.append(Sesion(tiempos: [], nombre: nombreLimpio, categoria: categoria))
        guardarSesiones()
        return true
    }

    func borrarCategoria(sesionAEliminar: Sesion) {
        guard !timerState.intentoActivo, tiemposPrincipal.count > 1,
              let index = tiemposPrincipal.firstIndex(where: { $0.id == sesionAEliminar.id }) else { return }
        tiemposPrincipal.remove(at: index)
        if sesionActual.id == sesionAEliminar.id, let primeraSesion = tiemposPrincipal.first {
            seleccionarSesion(primeraSesion)
        }
        guardarSesiones()
    }

    func reintentarScramble() {
        guard estadoScramble == .error else { return }
        nuevoScramble()
    }

    private func nuevoScramble() {
        estadoScramble = ScrambleService.shared.siguiente(categoria: sesionActual.categoria)
    }
}
