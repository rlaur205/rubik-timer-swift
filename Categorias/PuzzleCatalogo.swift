import Foundation

// MARK: - Modelos internos

struct PuzzleOption: Identifiable {
    let id: String          // identificador interno/base del puzzle
    let display: String     // texto visible e.g. "3×3"
    let eventos: [EventoOption]
}

struct EventoOption: Identifiable {
    let id: String          // string de categoría final que se guarda
    let nombre: String
    let badge: String       // "OH", "BLD" o ""
}

// MARK: - Catálogo de puzzles

let puzzleList: [PuzzleOption] = [
    PuzzleOption(id: "2x2",      display: "2×2",      eventos: [
        EventoOption(id: "2x2",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "3x3",      display: "3×3",      eventos: [
        EventoOption(id: "3x3",      nombre: "Normal",    badge: ""),
        EventoOption(id: "3x3 BLD",  nombre: "A ciegas",  badge: "BLD"),
        EventoOption(id: "3x3 OH",   nombre: "Una mano",  badge: "OH")
    ]),
    PuzzleOption(id: "4x4",      display: "4×4",      eventos: [
        EventoOption(id: "4x4",      nombre: "Normal",    badge: ""),
        EventoOption(id: "4x4 BLD",  nombre: "A ciegas",  badge: "BLD")
    ]),
    PuzzleOption(id: "5x5",      display: "5×5",      eventos: [
        EventoOption(id: "5x5",      nombre: "Normal",    badge: ""),
        EventoOption(id: "5x5 BLD",  nombre: "A ciegas",  badge: "BLD")
    ]),
    PuzzleOption(id: "6x6",      display: "6×6",      eventos: [
        EventoOption(id: "6x6",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "7x7",      display: "7×7",      eventos: [
        EventoOption(id: "7x7",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Pyraminx", display: "Pyraminx", eventos: [
        EventoOption(id: "Pyraminx", nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Megaminx", display: "Megaminx", eventos: [
        EventoOption(id: "Megaminx", nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Skewb",    display: "Skewb",    eventos: [
        EventoOption(id: "Skewb",    nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Square 1", display: "Square-1", eventos: [
        EventoOption(id: "Square 1", nombre: "Normal",    badge: "")
    ])
]
