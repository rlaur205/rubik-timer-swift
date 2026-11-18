import SwiftUI

// MARK: - Modelos internos

private struct PuzzleOption {
    let id: String          // identificador interno del puzzle
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
        EventoOption(id: "3x3 BLD",  nombre: "A ciegas",  badge: "BLD"),
        EventoOption(id: "3x3 OH",   nombre: "Una mano",  badge: "OH")
    ]),
    PuzzleOption(id: "4x4",      display: "4×4",      sfSymbol: "square.grid.3x3",               eventos: [
        EventoOption(id: "4x4",      nombre: "Normal",    badge: ""),
        EventoOption(id: "4x4 BLD",  nombre: "A ciegas",  badge: "BLD")
    ]),
    PuzzleOption(id: "5x5",      display: "5×5",      sfSymbol: "rectangle.split.3x3",           eventos: [
        EventoOption(id: "5x5",      nombre: "Normal",    badge: ""),
        EventoOption(id: "5x5 BLD",  nombre: "A ciegas",  badge: "BLD")
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
    ])
]

// MARK: - Vista principal

struct CrearCategoriaView: View {

    @ObservedObject var vm: RubikViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var mostrarFormulario: Bool
    @Binding var mostrarAlertaNombreInvalido: Bool

    @State private var nuevoNombre = ""
    @State private var puzzleIdx: Int = 1          // 3×3 por defecto
    @State private var eventoId: String = "3x3"    // Normal por defecto
    // Puzzle cuyo popover de eventos está abierto (nil = ninguno)
    @State private var popoverPuzzleIdx: Int? = nil

    // MARK: Computed helpers
    private var puzzle: PuzzleOption { puzzleList[puzzleIdx] }

    private var textoCrearComo: String {
        let ev = puzzle.eventos.first(where: { $0.id == eventoId }) ?? puzzle.eventos[0]
        if ev.badge.isEmpty { return puzzle.display }
        return "\(puzzle.display) \(ev.badge)"
    }

    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {

            // ── Contenido ────────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // — Nombre ——————————————————————————————————
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Nombre")
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(.secondary)

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
                            .background(EstiloVisual.acento.opacity(0.055))
                            .cornerRadius(10)
                    }

                    // — Puzzle ——————————————————————————————————
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Puzzle")
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                            spacing: 10
                        ) {
                            ForEach(Array(puzzleList.enumerated()), id: \.element.id) { idx, p in
                                puzzleCell(p, idx: idx)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .scrollBounceBehavior(.basedOnSize)

            Spacer(minLength: 0)

            // ── Barra inferior ───────────────────────────────────────
            VStack(spacing: 0) {
                Button(action: crearSesion) {
                    Text("Crear sesión")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .accionPrincipal()
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .tint(EstiloVisual.acento)
        // Alerta de nombre inválido
        .alert("Nombre inválido", isPresented: $mostrarAlertaNombreInvalido) {
            Button("Aceptar") {}
        } message: {
            Text("El nombre no puede estar vacío y tiene un máximo de 10 caracteres.")
        }
        // Sheet compacto, con el material nativo de iOS en todo el sheet y el
        // indicador de arrastre para cerrarlo (ya no hay botón ✕).
        .presentationDetents([.height(480)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subvistas

    @ViewBuilder
    private func puzzleCell(_ p: PuzzleOption, idx: Int) -> some View {
        let isSelected = puzzleIdx == idx
        let tieneVariosEventos = p.eventos.count > 1

        Button {
            let cambioDePuzzle = puzzleIdx != idx
            puzzleIdx = idx
            // Al cambiar de puzzle se empieza por su primer evento (Normal).
            if cambioDePuzzle { eventoId = p.eventos[0].id }

            if tieneVariosEventos {
                popoverPuzzleIdx = idx
            } else {
                popoverPuzzleIdx = nil
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: p.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
                Text(textoCelda(p, isSelected: isSelected))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(isSelected ? EstiloVisual.acento : EstiloVisual.acento.opacity(0.055))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .popover(
            isPresented: Binding(
                get: { popoverPuzzleIdx == idx },
                set: { if !$0 { popoverPuzzleIdx = nil } }
            ),
            arrowEdge: .top
        ) {
            popoverEventos(p)
        }
    }

    @ViewBuilder
    private func popoverEventos(_ p: PuzzleOption) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Evento · \(p.display)")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.bottom, 2)

            ForEach(p.eventos) { ev in
                let seleccionado = eventoId == ev.id

                Button {
                    eventoId = ev.id
                    popoverPuzzleIdx = nil
                } label: {
                    HStack(spacing: 8) {
                        Text(ev.nombre)
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        if !ev.badge.isEmpty {
                            Text(ev.badge)
                                .font(.caption2).bold()
                                .foregroundStyle(EstiloVisual.acento)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(EstiloVisual.acento.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        Spacer(minLength: 12)

                        if seleccionado {
                            Image(systemName: "checkmark")
                                .font(.footnote).bold()
                                .foregroundStyle(EstiloVisual.acento)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(seleccionado ? EstiloVisual.acento.opacity(0.12) : Color.clear)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(width: 210)
        .presentationCompactAdaptation(.popover)
    }

    /// Texto del botón del grid; añade el badge del evento cuando está elegido.
    private func textoCelda(_ p: PuzzleOption, isSelected: Bool) -> String {
        guard isSelected else { return p.display }
        let ev = p.eventos.first(where: { $0.id == eventoId }) ?? p.eventos[0]
        return ev.badge.isEmpty ? p.display : "\(p.display) \(ev.badge)"
    }

    // MARK: - Acción

    private func crearSesion() {
        let nombre = nuevoNombre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nombre.isEmpty else {
            mostrarAlertaNombreInvalido = true
            return
        }
        let nuevaSesion = Sesion(tiempos: [], nombre: nombre, categoria: eventoId)
        vm.tiemposPrincipal.append(nuevaSesion)
        vm.guardarSesiones()
        nuevoNombre = ""
        mostrarFormulario = false
    }
}

#Preview {
    CrearCategoriaView(
        vm: RubikViewModel(),
        mostrarFormulario: .constant(true),
        mostrarAlertaNombreInvalido: .constant(false)
    )
}
