import SwiftUI

// MARK: - Modelos internos

private struct PuzzleOption: Identifiable {
    let id: String          // clave interna (categoria para TNoodle)
    let display: String     // texto visible e.g. "3×3"
    let sfSymbol: String
    let eventos: [EventoOption]
}

private struct EventoOption: Identifiable {
    let id: String          // string de categoría final que se guarda
    let nombre: String
    let badge: String       // "OH", "BLD" o ""
}

// MARK: - Catálogo de puzzles

private let puzzleList: [PuzzleOption] = [
    PuzzleOption(id: "2x2",      display: "2×2",      sfSymbol: "square.grid.2x2.fill",          eventos: [
        EventoOption(id: "2x2",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "3x3",      display: "3×3",      sfSymbol: "square.grid.3x3.fill",          eventos: [
        EventoOption(id: "3x3",      nombre: "Normal",    badge: ""),
        EventoOption(id: "3x3 OH",   nombre: "Una mano",  badge: "OH"),
        EventoOption(id: "3x3 BLD",  nombre: "A ciegas",  badge: "BLD"),
        EventoOption(id: "3x3 FMC",  nombre: "Min. movs.", badge: "FMC")
    ]),
    PuzzleOption(id: "4x4",      display: "4×4",      sfSymbol: "square.grid.3x3",               eventos: [
        EventoOption(id: "4x4",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "5x5",      display: "5×5",      sfSymbol: "rectangle.split.3x3",           eventos: [
        EventoOption(id: "5x5",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "6x6",      display: "6×6",      sfSymbol: "square.grid.3x3.topleft.filled", eventos: [
        EventoOption(id: "6x6",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "7x7",      display: "7×7",      sfSymbol: "square.grid.3x3.middleright.filled", eventos: [
        EventoOption(id: "7x7",      nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Pyraminx", display: "Pyraminx", sfSymbol: "triangle.fill",                 eventos: [
        EventoOption(id: "Pyraminx", nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Megaminx", display: "Megaminx", sfSymbol: "seal.fill",                     eventos: [
        EventoOption(id: "Megaminx", nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Skewb",    display: "Skewb",    sfSymbol: "rhombus",                       eventos: [
        EventoOption(id: "Skewb",    nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Square 1", display: "Square-1", sfSymbol: "square.on.square",              eventos: [
        EventoOption(id: "Square 1", nombre: "Normal",    badge: "")
    ]),
    PuzzleOption(id: "Clock",    display: "Clock",    sfSymbol: "clock",                         eventos: [
        EventoOption(id: "Clock",    nombre: "Normal",    badge: "")
    ])
]

// Slots fijos que siempre se muestran en la fila de eventos
private let eventSlots: [(nombre: String, badge: String)] = [
    ("Normal",     ""),
    ("Una mano",   "OH"),
    ("A ciegas",   "BLD"),
    ("Min. movs.", "FMC")
]

// MARK: - Vista principal

struct CrearCategoriaView: View {

    @ObservedObject var vm: RubikViewModel
    @Binding var mostrarFormulario: Bool
    @Binding var mostrarAlertaNombreInvalido: Bool

    @State private var nuevoNombre = ""
    @State private var puzzleIdx: Int = 1          // 3×3 por defecto
    @State private var eventoId: String = "3x3"    // Normal por defecto

    // MARK: Computed helpers
    private var puzzle: PuzzleOption { puzzleList[puzzleIdx] }

    private var categoriaFinal: String {
        // Para FMC reutilizamos el scramble de 3x3 normal (misma práctica WCA)
        if eventoId == "3x3 FMC" { return "3x3" }
        return eventoId
    }

    private var textoCrearComo: String {
        let ev = puzzle.eventos.first(where: { $0.id == eventoId }) ?? puzzle.eventos[0]
        if ev.badge.isEmpty { return puzzle.display }
        return "\(puzzle.display) \(ev.badge)"
    }

    private var infoEvento: String {
        switch puzzle.eventos.count {
        case 1: return "🔒 \(puzzle.display) solo tiene un evento oficial, se elige solo"
        case 2: return "ⓘ El \(puzzle.display) tiene 2 eventos oficiales: Normal y A ciegas"
        case 4: return "ⓘ El \(puzzle.display) tiene 4 eventos oficiales"
        default: return "ⓘ El \(puzzle.display) tiene \(puzzle.eventos.count) eventos"
        }
    }

    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {

            // ── Header ──────────────────────────────────────────────
            HStack(alignment: .center) {
                Text("Nueva sesión")
                    .font(.largeTitle).bold()
                Spacer()
                Button { mostrarFormulario = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()

            // ── Contenido scrollable ─────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // — Nombre ——————————————————————————————————
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            stepHeader(numero: "1", label: "NOMBRE")
                            Spacer()
                            Text("\(nuevoNombre.count)/10")
                                .font(.caption)
                                .foregroundStyle(nuevoNombre.count >= 10 ? Color.red : Color.secondary)
                        }
                        TextField("Nombre de la sesión", text: $nuevoNombre)
                            .onChange(of: nuevoNombre) { _, new in
                                if new.count > 10 { nuevoNombre = String(new.prefix(10)) }
                            }
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    // — Paso 1: Puzzle ———————————————————————————
                    VStack(alignment: .leading, spacing: 12) {
                        stepHeader(numero: "2", label: "PUZZLE")

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                            spacing: 10
                        ) {
                            ForEach(Array(puzzleList.enumerated()), id: \.element.id) { idx, p in
                                puzzleCell(p, idx: idx)
                            }
                        }
                    }

                    // — Paso 2: Evento ———————————————————————————
                    VStack(alignment: .leading, spacing: 12) {
                        stepHeader(numero: "3", label: "EVENTO")

                        HStack(spacing: 8) {
                            ForEach(eventSlots, id: \.nombre) { slot in
                                eventoCell(slot)
                            }
                        }

                        Text(infoEvento)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 20)
                }
                .padding(20)
            }

            // ── Barra inferior ───────────────────────────────────────
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Text("Se creará como")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(textoCrearComo)
                        .font(.subheadline).bold()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Button(action: crearSesion) {
                    Text("Crear sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(Color(.systemBackground))
        }
        // Alerta de nombre inválido
        .alert("Nombre inválido", isPresented: $mostrarAlertaNombreInvalido) {
            Button("Aceptar") {}
        } message: {
            Text("El nombre no puede estar vacío y tiene un máximo de 10 caracteres.")
        }
    }

    // MARK: - Subvistas

    @ViewBuilder
    private func stepHeader(numero: String, label: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.blue).frame(width: 20, height: 20)
                Text(numero).font(.caption2).bold().foregroundColor(.white)
            }
            Text(label)
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func puzzleCell(_ p: PuzzleOption, idx: Int) -> some View {
        let isSelected = puzzleIdx == idx
        Button {
            puzzleIdx = idx
            eventoId = p.eventos[0].id  // resetear al primer evento disponible
        } label: {
            VStack(spacing: 6) {
                Image(systemName: p.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : .primary)
                Text(p.display)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func eventoCell(_ slot: (nombre: String, badge: String)) -> some View {
        // ¿Existe este slot en el puzzle actual?
        let matchEvento = puzzle.eventos.first(where: { $0.badge == slot.badge })
        let isAvailable = matchEvento != nil
        let isSingleEvent = puzzle.eventos.count == 1
        let isSelected = eventoId == matchEvento?.id

        Button {
            if let ev = matchEvento, !isSingleEvent {
                eventoId = ev.id
            }
        } label: {
            VStack(spacing: 3) {
                // Candado si el puzzle solo tiene un evento y este es el disponible
                if isSingleEvent && isAvailable {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                Text(slot.nombre)
                    .font(.caption2).bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        isSelected   ? Color.white :
                        isAvailable  ? Color.primary :
                        Color.secondary.opacity(0.4)
                    )
                if !slot.badge.isEmpty {
                    Text(slot.badge)
                        .font(.caption2)
                        .foregroundStyle(
                            isSelected  ? Color.white.opacity(0.85) :
                            isAvailable ? Color.secondary :
                            Color.secondary.opacity(0.3)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                isSelected  ? Color.blue :
                isAvailable ? Color(.secondarySystemBackground) :
                Color(.secondarySystemBackground).opacity(0.4)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable || isSingleEvent)
    }

    // MARK: - Acción

    private func crearSesion() {
        let nombre = nuevoNombre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nombre.isEmpty else {
            mostrarAlertaNombreInvalido = true
            return
        }
        let nuevaSesion = Sesion(tiempos: [], nombre: nombre, categoria: categoriaFinal)
        vm.tiemposPrincipal.append(nuevaSesion)
        vm.guardarSesiones()
        nuevoNombre = ""
        mostrarFormulario = false
    }
}

#Preview {
    ContentView()
}
