import Foundation

/// Cola de scrambles por categoría con generación en segundo plano.
///
/// Los scrambles los genera TNoodle en el propio dispositivo (ver `TNoodleScrambler`).
/// `siguiente(categoria:)` es **síncrona y nunca bloquea**: devuelve al instante el
/// siguiente scramble de la cola. Si la cola está vacía (primer arranque) o el motor
/// falla, devuelve una cadena vacía: la app simplemente no muestra scramble en ese
/// momento, sin inventarse ninguno.
final class ScrambleService: @unchecked Sendable {

    static let shared = ScrambleService()

    /// Cuántos scrambles mantener listos por categoría.
    private let objetivo = 5

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

    /// Calienta el motor y empieza a precargar la categoría actual.
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
        guard let puzzle = TNoodlePuzzle.paraCategoria(categoria) else {
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
        reponer(categoria: categoria, puzzle: puzzle)

        return resultado ?? ""
    }

    /// Asegura que haya scrambles en cola para una categoría.
    func precargar(categoria: String) {
        guard let puzzle = TNoodlePuzzle.paraCategoria(categoria) else { return }
        reponer(categoria: categoria, puzzle: puzzle)
    }

    // MARK: - Generación

    private func reponer(categoria: String, puzzle: TNoodlePuzzle) {
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
                    let scramble = try await ScrambleEngine.shared.scramble(puzzle: puzzle)

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
                    NSLog("[Scramble] \(categoria) → \(scramble)")
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
                    // El motor es local: si falla no hay nada que reintentar. La app
                    // se queda sin scramble para esta categoría hasta que cambie.
                    _ = lock.withLock {
                        generando.remove(categoria)
                    }

                    #if DEBUG
                    NSLog("[Scramble] no se pudo generar \(categoria): \(error.localizedDescription)")
                    #endif
                    return
                }
            }
        }
    }
}
