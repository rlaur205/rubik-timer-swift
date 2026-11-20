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

    @Published var timerState = TimerState(
        estaCorriendo: false,
        tiempoInicio: nil,
        tiempoTranscurrido: 0,
        visibilidadPromedios: false
    )

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
        guard let indice = sesionActual.tiempos.firstIndex(where: { $0.id == tiempoID }) else { return }

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

    func registrarNuevoTiempo() {
        if let inicio = timerState.tiempoInicio {
            timerState.tiempoTranscurrido = Date().timeIntervalSince(inicio)
        }

        timerState.tiempoInicio = nil
        idTiempoMostrado = nil
        guard timerState.tiempoTranscurrido >= 0.01,
              case .listo(let scramble) = estadoScramble else { return }

        let tiempo = Tiempo(
            tiempo: timerState.tiempoTranscurrido,
            scramble: scramble,
            fecha: Date(),
            categoria: sesionActual.categoria
        )
        sesionActual.tiempos.append(tiempo)
        idTiempoMostrado = tiempo.id
        guardarCambiosSesionActual()
        nuevoScramble()
    }

    func borrarUltimoTiempo(id: UUID) {
        guard !timerState.estaCorriendo, sesionActual.tiempos.last?.id == id else { return }
        sesionActual.tiempos.removeLast()
        limpiarResultadoCronometro()
        guardarCambiosSesionActual()
        nuevoScramble()
        timerState.visibilidadPromedios = true
    }

    private func limpiarResultadoCronometro() {
        idTiempoMostrado = nil
        if !timerState.estaCorriendo { timerState.tiempoTranscurrido = 0 }
    }

    func seleccionarSesion(_ sesion: Sesion) {
        guard let guardada = tiemposPrincipal.first(where: { $0.id == sesion.id }) else { return }
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
        guard tiemposPrincipal.count > 1,
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
