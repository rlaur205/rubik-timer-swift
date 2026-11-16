import Foundation

/// Cola de scrambles por categoría con generación en segundo plano.
///
/// `siguiente(categoria:)` es **síncrona y nunca falla**: devuelve al instante un
/// scramble de la cola si hay uno listo y, si no, recurre a los generadores Swift de
/// siempre (`scrambleMostrar`). Mientras tanto se repone la cola en segundo plano y
/// los siguientes scrambles ya vienen del motor random-state de cubing.js.
///
/// Así la UI nunca se queda esperando y, aunque el motor no llegue a cargar, la app
/// sigue siendo 100 % funcional.
final class ScrambleService: @unchecked Sendable {

    static let shared = ScrambleService()

    /// Cuántos scrambles mantener listos por categoría.
    private let objetivo = 5

    private let lock = NSLock()
    private var colas: [String: [String]] = [:]
    private var generando: Set<String> = []

    private init() {}

    // MARK: - API

    /// Arranca el motor y empieza a precargar la categoría actual.
    func iniciar(categoria: String) {
        Task { @MainActor in
            ScrambleEngine.shared.warmUp()
        }
        precargar(categoria: categoria)
    }

    /// Devuelve el siguiente scramble para una categoría. Nunca bloquea.
    func siguiente(categoria: String) -> String {
        guard let eventID = Self.eventID(para: categoria) else {
            return scrambleMostrar(categoria: categoria)
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

        if let resultado, !resultado.isEmpty {
            return resultado
        }

        return scrambleMostrar(categoria: categoria)
    }

    /// Asegura que haya scrambles en cola para una categoría.
    func precargar(categoria: String) {
        guard let eventID = Self.eventID(para: categoria) else { return }
        reponer(categoria: categoria, eventID: eventID)
    }

    // MARK: - Generación

    private func reponer(categoria: String, eventID: String) {
        let debeGenerar: Bool = lock.withLock {
            let enCola = colas[categoria]?.count ?? 0
            if enCola >= objetivo || generando.contains(categoria) {
                return false
            }
            generando.insert(categoria)
            return true
        }

        guard debeGenerar else { return }

        Task.detached(priority: .utility) { [self] in
            while true {
                do {
                    let scramble = try await ScrambleEngine.shared.scramble(eventID: eventID, timeout: 25)

                    let llena: Bool = lock.withLock {
                        var cola = colas[categoria] ?? []
                        cola.append(scramble)
                        let llena = cola.count >= objetivo
                        colas[categoria] = cola
                        if llena {
                            generando.remove(categoria)
                        }
                        return llena
                    }

                    #if DEBUG
                    NSLog("[Scramble] \(eventID) → \(scramble)")
                    #endif

                    if llena {
                        return
                    }
                } catch {
                    _ = lock.withLock {
                        generando.remove(categoria)
                    }

                    #if DEBUG
                    NSLog("[Scramble] no se pudo generar \(eventID): \(error.localizedDescription)")
                    #endif
                    return
                }
            }
        }
    }

    // MARK: - Categorías

    /// Traduce una categoría de la app al identificador de evento de cubing.js.
    static func eventID(para categoria: String) -> String? {
        switch categoria {
        case "2x2": return "222"
        case "3x3": return "333"
        case "4x4": return "444"
        case "5x5": return "555"
        case "6x6": return "666"
        case "7x7": return "777"
        case "3x3 OH": return "333oh"
        case "3x3 BLD": return "333bf"
        case "Pyraminx": return "pyram"
        case "Megaminx": return "minx"
        case "Skewb": return "skewb"
        case "Square 1": return "sq1"
        default: return nil
        }
    }
}
