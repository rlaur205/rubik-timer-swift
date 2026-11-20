import SwiftUI

// MARK: - Vista principal

struct CrearCategoriaView: View {

    @ObservedObject var vm: RubikViewModel
    @Environment(\.temaApp) private var temaApp
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
                                .foregroundStyle(temaApp.texto.opacity(0.65))

                            Spacer()
                            Text("\(nuevoNombre.count)/10")
                                .font(.caption)
                                .foregroundStyle(nuevoNombre.count >= 10 ? Color.red : temaApp.texto.opacity(0.65))
                        }
                        TextField("Nombre de la sesión", text: $nuevoNombre)
                            .onChange(of: nuevoNombre) { _, new in
                                if new.count > 10 { nuevoNombre = String(new.prefix(10)) }
                            }
                            .padding(12)
                            .background(temaApp.superficie)
                            .foregroundStyle(temaApp.texto)
                            .cornerRadius(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(temaApp.linea, lineWidth: 1)
                            }
                    }

                    // — Puzzle ——————————————————————————————————
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Puzzle")
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(temaApp.texto.opacity(0.65))

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
                        .foregroundStyle(temaApp.textoSobreAcento)
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
        .tint(temaApp.acento)
        .foregroundStyle(temaApp.texto)
        .background(temaApp.fondo)
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
        .presentationBackground(temaApp.fondo)
    }

    // MARK: - Subvistas

    @ViewBuilder
    private func puzzleCell(_ p: PuzzleOption, idx: Int) -> some View {
        let isSelected = puzzleIdx == idx
        let tieneVariosEventos = p.eventos.count > 1
        let iconCategoria = isSelected ? eventoId : p.id

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
                IconoPuzzle(categoria: iconCategoria, size: 26)
                    .foregroundStyle(isSelected ? (temaApp.colorScheme == .dark ? Color.black : Color.white) : temaApp.texto)
                Text(textoCelda(p, isSelected: isSelected))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? (temaApp.colorScheme == .dark ? Color.black : Color.white) : temaApp.texto)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(isSelected ? temaApp.acento : temaApp.superficie)
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(temaApp.linea, lineWidth: isSelected ? 0 : 1)
            }
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
                .foregroundStyle(temaApp.texto.opacity(0.65))
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
                            .foregroundStyle(temaApp.texto)

                        if !ev.badge.isEmpty {
                            Text(ev.badge)
                                .font(.caption2).bold()
                                .foregroundStyle(temaApp.acento)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(temaApp.acento.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        Spacer(minLength: 12)

                        if seleccionado {
                            Image(systemName: "checkmark")
                                .font(.footnote).bold()
                                .foregroundStyle(temaApp.acento)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(seleccionado ? temaApp.acento.opacity(0.12) : Color.clear)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(width: 210)
        .foregroundStyle(temaApp.texto)
        .background(temaApp.fondo)
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
        guard vm.crearSesion(nombre: nuevoNombre, categoria: eventoId) else {
            mostrarAlertaNombreInvalido = true
            return
        }
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
