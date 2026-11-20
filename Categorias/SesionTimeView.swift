import SwiftUI

struct SesionTimeView: View {
    @ObservedObject var vm: RubikViewModel
    let sesion: Sesion
    let eliminarTiempo: () -> Void
    @Environment(\.temaApp) private var temaApp
    private var seleccionada: Bool { vm.idActual == sesion.id }

    var body: some View {
        Button {
            vm.seleccionarSesion(sesion)
        } label: {
            HStack(spacing: 14) {
                IconoPuzzle(categoria: sesion.categoria, size: 36, multiplicadorTrazo: 1.45)
                    .foregroundStyle(seleccionada ? temaApp.acento : temaApp.texto.opacity(0.85))
                    .frame(width: 38)
                VStack(alignment: .leading, spacing: 4) {
                    Text(sesion.nombre).font(.headline).foregroundStyle(temaApp.texto)
                    Text(sesion.categoria).font(.subheadline).foregroundStyle(temaApp.texto.opacity(0.65))
                }
                Spacer(minLength: 8)
                if seleccionada {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(temaApp.acento)
                        .accessibilityLabel("Sesión actual")
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(seleccionada ? [.isSelected] : [])
        .contextMenu {
            Button("Eliminar sesión", systemImage: "trash", role: .destructive, action: eliminarTiempo)
        }
    }
}
