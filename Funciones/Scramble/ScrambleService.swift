import Foundation

/// Cola de scrambles por categoría con generación en segundo plano.
///
/// Los scrambles se piden a un servidor TNoodle (ver `TNoodleClient`).
/// `siguiente(categoria:)` es **síncrona y nunca bloquea**: devuelve al instante el
/// siguiente scramble de la cola. Si la cola está vacía (primer arranque) o el servidor
/// no responde, devuelve una cadena vacía: la app simplemente no muestra scramble en
/// ese momento, sin inventarse ninguno.
final class ScrambleService: @unchecked Sendable {

    static let shared = ScrambleService()

    /// Cuántos scrambles mantener listos por categoría.
    private let objetivo = 5

    /// Reintentos ante un fallo del servidor TNoodle (red caída, servidor dormido…).
    private let esperaReintento: UInt64 = 5_000_000_000

    private let lock = NSLock()
    private var colas: [String: [String]] = [:]
    private var generando: Set<String> = []
    private var categoriaActiva: String?

    /// Aviso en el hilo principal cuando una categoría pasa de 0 a 1 scrambles
    /// listos. La app lo usa para rellenar la pantalla si estaba vacía esperando
    /// al motor.
    var alPrimerScramble: (@MainActor (String) -> Void)?

    private init() {}

    // MARK: - API

    /// Comprueba el servidor TNoodle y empieza a precargar la categoría actual.
    func iniciar(categoria: String) {
        Task { @MainActor in
            ScrambleEngine.shared.warmUp()
        }
        precargar(categoria: categoria)
    }

    /// Devuelve el siguiente scramble para una categoría. Nunca bloquea.
    ///
    /// Si todavía no hay ninguno listo (o el motor no está disponible) devuelve una
    /// cadena vacía.
    func siguiente(categoria: String) -> String {
        guard let eventID = Self.eventID(para: categoria) else {
            return ""
        }

        let resultado: String? = lock.withLock {
            guard var cola = colas[categoria], !cola.isEmpty else {
                return nil
            }
            let primero = cola.removeFirst()
            colas[categoria] = cola
            return primero
        }

        // Reponemos lo que acabamos de consumir.
        reponer(categoria: categoria, eventID: eventID)

        return resultado ?? ""
    }

    /// Asegura que haya scrambles en cola para una categoría.
    func precargar(categoria: String) {
        guard let eventID = Self.eventID(para: categoria) else { return }
        reponer(categoria: categoria, eventID: eventID)
    }

    // MARK: - Generación

    private func reponer(categoria: String, eventID: String) {
        let debeGenerar: Bool = lock.withLock {
            categoriaActiva = categoria

            let enCola = colas[categoria]?.count ?? 0
            if enCola >= objetivo || generando.contains(categoria) {
                return false
            }
            generando.insert(categoria)
            return true
        }

        guard debeGenerar else { return }

        Task.detached(priority: .utility) { [self] in
            var fallos = 0

            while true {
                // Si cambiamos de categoría o la cola ya se llenó, este bucle sobra.
                let seguir: Bool = lock.withLock {
                    let llena = (colas[categoria]?.count ?? 0) >= objetivo
                    if llena || categoriaActiva != categoria {
                        generando.remove(categoria)
                        return false
                    }
                    return true
                }
                guard seguir else { return }

                do {
                    let scramble = try await ScrambleEngine.shared.scramble(eventID: eventID, timeout: 25)
                    fallos = 0

                    let (llena, eraVacia): (Bool, Bool) = lock.withLock {
                        var cola = colas[categoria] ?? []
                        let eraVacia = cola.isEmpty
                        cola.append(scramble)
                        let llena = cola.count >= objetivo
                        colas[categoria] = cola
                        if llena {
                            generando.remove(categoria)
                        }
                        return (llena, eraVacia)
                    }

                    #if DEBUG
                    NSLog("[Scramble] \(eventID) → \(scramble)")
                    #endif

                    if eraVacia {
                        await MainActor.run { [weak self] in
                            guard let self, let aviso = self.alPrimerScramble else { return }
                            aviso(categoria)
                        }
                    }

                    if llena {
                        return
                    }
                } catch {
                    fallos += 1

                    // Con el servidor TNoodle caído se reintenta mientras la categoría
                    // siga activa, en vez de dejar la pantalla sin scrambles para siempre.
                    if fallos <= 3 {
                        #if DEBUG
                        NSLog("[Scramble] fallo \(fallos) en \(eventID): \(error.localizedDescription)")
                        #endif
                    }

                    try? await Task.sleep(nanoseconds: esperaReintento)
                }
            }
        }
    }

    // MARK: - Categorías

    /// Traduce una categoría de la app al identificador de evento de TNoodle.
    ///
    /// TNoodle no tiene eventos separados para OH ni BLD: las manos libres usan `333`
    /// y el BLD usa `333ni` (3x3 sin inspección).
    static func eventID(para categoria: String) -> String? {
        switch categoria {
        case "2x2": return "222"
        case "3x3": return "333"
        case "4x4": return "444"
        case "5x5": return "555"
        case "6x6": return "666"
        case "7x7": return "777"
        case "3x3 OH": return "333"
        case "3x3 BLD": return "333ni"
        case "Pyraminx": return "pyram"
        case "Megaminx": return "minx"
        case "Skewb": return "skewb"
        case "Square 1": return "sq1"
        default: return nil
        }
    }
}
