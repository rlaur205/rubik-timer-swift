import Foundation
import TNoodleLibNative

/// Puzzle de TNoodle que corresponde a cada categoría de la app.
///
/// Los valores coinciden con el índice que espera `tnoodle_lib_scramble` en la
/// librería nativa (ver `PuzzleRegistry.Main` de TNoodle):
/// 0 2x2, 1 3x3, 2 4x4, 3 5x5, 4 6x6, 5 7x7, 6 Square-1, 7 Megaminx,
/// 8 Pyraminx, 9 Clock, 10 Skewb, 11 3x3 (normal), 12 3x3 sin inspección.
enum TNoodlePuzzle: Int32, Sendable {
    case twoByTwo = 0
    case threeByThree = 1
    case fourByFour = 2
    case fiveByFive = 3
    case sixBySix = 4
    case sevenBySeven = 5
    case squareOne = 6
    case megaminx = 7
    case pyraminx = 8
    case clock = 9
    case skewb = 10
    case threeByThreeSinInspeccion = 12

    /// Traduce una categoría de la app al puzzle de TNoodle.
    ///
    /// TNoodle no tiene eventos separados para OH ni BLD: OH usa el 3x3 normal y el
    /// BLD usa el 3x3 sin inspección, igual que en la WCA.
    static func paraCategoria(_ categoria: String) -> TNoodlePuzzle? {
        switch categoria {
        case "2x2": return .twoByTwo
        case "3x3": return .threeByThree
        case "4x4": return .fourByFour
        case "5x5": return .fiveByFive
        case "6x6": return .sixBySix
        case "7x7": return .sevenBySeven
        case "3x3 OH": return .threeByThree
        case "3x3 BLD": return .threeByThreeSinInspeccion
        case "Pyraminx": return .pyraminx
        case "Megaminx": return .megaminx
        case "Skewb": return .skewb
        case "Square 1": return .squareOne
        default: return nil
        }
    }
}

enum TNoodleError: LocalizedError {
    case motorNoDisponible
    case sinScramble

    var errorDescription: String? {
        switch self {
        case .motorNoDisponible:
            return "No se pudo iniciar el motor de scrambles TNoodle."
        case .sinScramble:
            return "TNoodle no devolvió ningún scramble."
        }
    }
}

/// Genera scrambles con **TNoodle compilado para iOS** (la misma solución que usa
/// CubeTime): random-state oficial de la WCA, en el dispositivo y sin internet.
///
/// La librería nativa expone una API de C con isolates de GraalVM. Cada scramble se
/// genera en su propio isolate y se destruye al terminar; así la memoria que reserva
/// TNoodle para devolver el `char *` se libera sola.
final class TNoodleScrambler: @unchecked Sendable {

    static let shared = TNoodleScrambler()

    /// GraalVM ejecuta un isolate por llamada. Serializamos para no crear varios a la
    /// vez desde hilos distintos.
    private let lock = NSLock()

    private init() {}

    /// Devuelve un scramble de TNoodle para el puzzle indicado.
    ///
    /// Los scrambles de Megaminx vienen en varias líneas; se unen en una sola para que
    /// la vista del cronómetro no se rompa.
    func scramble(_ puzzle: TNoodlePuzzle) throws -> String {
        try lock.withLock {
            var isolate: OpaquePointer?
            var thread: OpaquePointer?

            guard graal_create_isolate(nil, &isolate, &thread) == 0, let thread else {
                throw TNoodleError.motorNoDisponible
            }
            defer { graal_tear_down_isolate(thread) }

            guard let puntero = tnoodle_lib_scramble(thread, puzzle.rawValue) else {
                throw TNoodleError.sinScramble
            }

            let texto = String(cString: puntero)
                .replacingOccurrences(of: "\r\n", with: "\n")
                .split(whereSeparator: \.isNewline)
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !texto.isEmpty else {
                throw TNoodleError.sinScramble
            }

            return texto
        }
    }
}
