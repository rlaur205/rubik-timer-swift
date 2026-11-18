import SwiftUI

struct IdiomaSelectorView: View {
    @Bindable var estado: AjustesEstado

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
                                    .foregroundStyle(.primary)
                                if let detalle = idioma.detalle {
                                    Text(detalle)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer(minLength: 8)
                            if estado.idioma == idioma {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(EstiloVisual.acento)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(estado.idioma == idioma ? .isSelected : AccessibilityTraits())
                }
            } footer: {
                Text("La selección es una preferencia local de esta pantalla y no cambia el idioma de la app.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Idioma")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        IdiomaSelectorView(estado: AjustesEstado())
    }
}
