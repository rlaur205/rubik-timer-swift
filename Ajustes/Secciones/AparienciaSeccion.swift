import SwiftUI

struct AparienciaSeccion: View {
    @Bindable var estado: AjustesEstado
    @Environment(\.dynamicTypeSize) private var tamanoTexto

    var body: some View {
        Section {
            NavigationLink {
                IdiomaSelectorView(estado: estado)
            } label: {
                HStack(spacing: 12) {
                    AjustesIcono(sistema: "globe", color: .indigo)
                    Text("Idioma")
                    Spacer(minLength: 8)
                    Text(estado.idioma.nombre)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityValue(estado.idioma.nombre)
            }

            AjustesToggleFila(
                sistema: "desktopcomputer",
                color: .gray,
                titulo: "Tema del sistema",
                subtitulo: "Sigue el modo claro/oscuro del iPhone",
                estaActivo: $estado.temaSistema
            )

            AjustesFilaValor(
                sistema: "paintpalette.fill",
                color: .purple,
                titulo: "Tema de la app",
                valor: estado.temaSistema ? "Sistema" : estado.tema.nombre,
                bloqueada: estado.temaSistema
            )

            if !estado.temaSistema {
                galeriaTemas
            }
        } header: {
            Text("APARIENCIA")
        } footer: {
            Text("Desactiva «Tema del sistema» para elegir un tema propio.")
        }
        .animation(.easeInOut(duration: 0.2), value: estado.temaSistema)
    }

    private var galeriaTemas: some View {
        LazyVGrid(
            columns: [GridItem(
                .adaptive(minimum: tamanoTexto.isAccessibilitySize ? 132 : 60),
                spacing: 8
            )],
            alignment: .center,
            spacing: 10
        ) {
            ForEach(TemaAjuste.allCases) { tema in
                AjustesTarjetaTema(
                    tema: tema,
                    seleccionado: estado.tema == tema
                ) {
                    estado.tema = tema
                }
            }
        }
        .padding(.vertical, 4)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .accessibilityLabel("Selector de tema de la app")
    }
}

#Preview {
    NavigationStack {
        List {
            AparienciaSeccion(estado: AjustesEstado())
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
