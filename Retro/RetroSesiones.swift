import SwiftUI

struct RetroSesiones: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.retro) private var paleta
    @State private var mostrarFormulario = false
    @State private var porEliminar: Sesion?

    var body: some View {
        PantallaRetro {
            EncabezadoRetro(titulo: "Sesiones", contador: vm.tiemposPrincipal.count) {
                IconoBotonRetro(titulo: "Nueva sesión", icono: "plus", relleno: paleta.lima) {
                    mostrarFormulario = true
                }
            }
            ForEach(vm.tiemposPrincipal) { sesion in
                fila(sesion)
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            RetroNuevaSesion(vm: vm)
        }
        .sheet(item: $porEliminar) { sesion in
            if vm.tiemposPrincipal.count > 1 {
                ConfirmacionRetro(
                    titulo: "Eliminar sesión",
                    mensaje: "Se eliminará «\(sesion.nombre)» junto con todos sus tiempos.",
                    accionTitulo: "Eliminar"
                ) { vm.borrarCategoria(sesionAEliminar: sesion) }
            } else {
                PanelRetro(titulo: "Eliminar sesión") {
                    Text("Debe quedar al menos una sesión.")
                }
                .presentationDetents([.medium])
            }
        }
    }

    private func fila(_ sesion: Sesion) -> some View {
        let activa = vm.sesionActual.id == sesion.id
        return Button {
            vm.seleccionarSesion(sesion)
        } label: {
            HStack(spacing: 10) {
                IconoPuzzle(categoria: sesion.categoria, size: 30, multiplicadorTrazo: 1.55)
                    .foregroundStyle(paleta.tinta)
                    .frame(width: 50, height: 50)
                    .cajaRetro(activa ? paleta.coral : paleta.lavanda, relieve: false, radio: 11)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(sesion.nombre).font(.title3.weight(.black))
                    Text("\(sesion.categoria) · \(sesion.tiempos.count.formatted()) solves")
                        .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        .foregroundStyle(paleta.texto)
                        .accessibilityLabel("\(sesion.categoria), \(sesion.tiempos.count) tiempos")
                }
                Spacer(minLength: 3)
                if activa {
                    SelloRetro(texto: "ACTIVA", color: paleta.coral)
                }
            }
            .padding(11)
            .contentShape(Rectangle())
            .cajaRetro()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(activa ? .isSelected : [])
        .contextMenu {
            Button("Eliminar sesión", systemImage: "trash", role: .destructive) { porEliminar = sesion }
        }
    }
}

private struct RetroNuevaSesion: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.retro) private var paleta
    @Environment(\.dismiss) private var cerrar
    @State private var nombre = ""
    @State private var puzzle = "3x3"
    @State private var evento = "3x3"
    @FocusState private var editandoNombre: Bool

    var body: some View {
        PanelRetro(titulo: "Nueva sesión") {
            SeccionRetro(titulo: "NOMBRE", color: paleta.amarillo) {
                TextField("Nombre de la sesión", text: $nombre)
                    .font(.system(.body, design: .monospaced, weight: .semibold))
                    .focused($editandoNombre)
                    .submitLabel(.done)
                    .onSubmit { editandoNombre = false }
                    .padding(10)
                    .cajaRetro(relieve: false)
                    .accessibilityIdentifier("retro-nombre-sesion")
                    .onChange(of: nombre) { _, nuevo in
                        if nuevo.count > 10 { nombre = String(nuevo.prefix(10)) }
                    }
                Text("\(nombre.count)/10")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(paleta.secundario)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            SeccionRetro(titulo: "PUZZLE", color: paleta.lavanda) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65), spacing: 7)], spacing: 7) {
                    ForEach(puzzleList) { opcion in
                        botonPuzzle(opcion)
                    }
                }
                if let opcion = puzzleList.first(where: { $0.id == puzzle }), opcion.eventos.count > 1 {
                    VStack(spacing: 7) {
                        ForEach(opcion.eventos) { opcionEvento in
                            Button {
                                evento = opcionEvento.id
                            } label: {
                                HStack {
                                    Text(opcionEvento.nombre)
                                    Spacer()
                                    if !opcionEvento.badge.isEmpty { Text(opcionEvento.badge) }
                                    if evento == opcionEvento.id { Image(systemName: "checkmark") }
                                }
                            }
                            .buttonStyle(BotonRetro(relleno: evento == opcionEvento.id ? paleta.menta : nil))
                            .accessibilityAddTraits(evento == opcionEvento.id ? .isSelected : [])
                        }
                    }
                }
            }

        }
        .safeAreaInset(edge: .bottom) {
            Button {
                if vm.crearSesion(nombre: nombre, categoria: evento) { cerrar() }
            } label: {
                Text("Crear sesión").frame(maxWidth: .infinity)
            }
            .buttonStyle(BotonRetro(relleno: paleta.lima))
            .disabled(nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 17)
            .padding(.vertical, 10)
            .background(paleta.fondo)
        }
    }

    private func botonPuzzle(_ opcion: PuzzleOption) -> some View {
        let seleccionada = opcion.id == puzzle
        return Button {
            if !seleccionada {
                puzzle = opcion.id
                evento = opcion.eventos[0].id
            }
        } label: {
            VStack(spacing: 5) {
                IconoPuzzle(categoria: opcion.id, size: 25, multiplicadorTrazo: 1.3)
                Text(opcion.display)
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(seleccionada ? paleta.tinta : paleta.texto)
            .frame(maxWidth: .infinity, minHeight: 62)
            .contentShape(Rectangle())
            .cajaRetro(seleccionada ? paleta.lima : nil, relieve: false, radio: 11)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(seleccionada ? .isSelected : [])
    }
}
