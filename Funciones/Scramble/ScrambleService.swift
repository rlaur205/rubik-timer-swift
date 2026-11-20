import Foundation

enum EstadoScramble: Equatable {
    case preparando
    case listo(String)
    case error
}

/// Mantiene una cola por categoría. TNoodle se ejecuta en segundo plano en ScrambleEngine.
@MainActor
final class ScrambleService {
    static let shared = ScrambleService()

    private let objetivo = 5
    private var colas: [String: [String]] = [:]
    private var generando: Set<String> = []
    private var categoriaActiva: String?

    var alPrimerScramble: ((String) -> Void)?
    var alFallar: ((String) -> Void)?

    private init() {}

    func iniciar(categoria: String) -> EstadoScramble {
        ScrambleEngine.shared.warmUp()
        return siguiente(categoria: categoria)
    }

    func siguiente(categoria: String) -> EstadoScramble {
        categoriaActiva = categoria
        guard let puzzle = TNoodlePuzzle.paraCategoria(categoria) else { return .error }

        let siguiente: EstadoScramble
        if var cola = colas[categoria], !cola.isEmpty {
            siguiente = .listo(cola.removeFirst())
            colas[categoria] = cola
        } else {
            siguiente = .preparando
        }

        reponer(categoria: categoria, puzzle: puzzle)
        return siguiente
    }

    private func reponer(categoria: String, puzzle: TNoodlePuzzle) {
        guard (colas[categoria]?.count ?? 0) < objetivo,
              generando.insert(categoria).inserted else { return }

        Task(priority: .utility) {
            defer { generando.remove(categoria) }

            while categoriaActiva == categoria && (colas[categoria]?.count ?? 0) < objetivo {
                do {
                    let scramble = try await ScrambleEngine.shared.scramble(puzzle: puzzle)
                    let estabaVacia = colas[categoria, default: []].isEmpty
                    colas[categoria, default: []].append(scramble)
                    if estabaVacia { alPrimerScramble?(categoria) }
                } catch {
                    #if DEBUG
                    NSLog("[Scramble] no se pudo generar \(categoria): \(error.localizedDescription)")
                    #endif
                    alFallar?(categoria)
                    return
                }
            }
        }
    }
}
