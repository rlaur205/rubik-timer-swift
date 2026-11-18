import SwiftUI

struct IdiomaSelectorView: View {
    @Bindable var estado: AjustesEstado
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        List {
            Section {
                ForEach(IdiomaAjuste.allCases) { idioma in
                    Button {
                        estado.idioma = idioma
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(idioma.nombre)
                                    .foregroundStyle(temaApp.texto)
                                if let detalle = idioma.detalle {
                                    Text(detalle)
                                        .font(.footnote)
                                        .foregroundStyle(temaApp.texto.opacity(0.65))
                                }
                            }
                            Spacer(minLength: 8)
                            if estado.idioma == idioma {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(temaApp.acento)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(estado.idioma == idioma ? .isSelected : AccessibilityTraits())
                    .listRowBackground(temaApp.superficie)
                    .listRowSeparatorTint(temaApp.linea)
                }
            } footer: {
                Text("La selección es una preferencia local de esta pantalla y no cambia el idioma de la app.")
                    .foregroundStyle(temaApp.texto.opacity(0.65))
            }
        }
        .listStyle(.insetGrouped)
        .id(temaApp)
        .scrollContentBackground(.hidden)
        .background(temaApp.fondo)
        .foregroundStyle(temaApp.texto)
        .navigationTitle("Idioma")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(temaApp.fondo, for: .navigationBar)
        .toolbarColorScheme(temaApp.colorScheme, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        IdiomaSelectorView(estado: AjustesEstado())
    }
}
