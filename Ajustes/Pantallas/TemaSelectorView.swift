import SwiftUI

struct TemaSelectorView: View {
    @AppStorage("temaApp") private var temaElegido: TemaApp = .claro
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var tamanoTexto

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columnas, spacing: 10) {
                    ForEach(TemaApp.allCases) { tema in
                        AjustesTarjetaTema(
                            tema: tema,
                            seleccionado: temaElegido == tema
                        ) {
                            temaElegido = tema
                        }
                    }
                }
                .padding()
            }
            .background(temaElegido.superficie)
            .navigationTitle("Tema de la app")
            .navigationBarTitleDisplayMode(.inline)
            .tint(temaElegido.acento)
            .toolbarBackground(temaElegido.superficie, for: .navigationBar)
            .toolbarColorScheme(temaElegido.colorScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                    .accessibilityIdentifier("cerrar-selector-tema")
                }
            }
        }
        .environment(\.temaApp, temaElegido)
        .environment(\.colorScheme, temaElegido.colorScheme)
        .preferredColorScheme(temaElegido.colorScheme)
        .presentationDetents(detentes)
        .presentationDragIndicator(.visible)
        .presentationBackground(temaElegido.superficie)
    }

    private var columnas: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 8),
            count: tamanoTexto.isAccessibilitySize ? 2 : 4
        )
    }

    private var detentes: Set<PresentationDetent> {
        tamanoTexto.isAccessibilitySize ? [.large] : [.height(505), .large]
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            TemaSelectorView()
        }
}
