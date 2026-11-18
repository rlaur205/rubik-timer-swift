import SwiftUI

struct AparienciaSeccion: View {
    @Bindable var estado: AjustesEstado
    @Environment(\.dynamicTypeSize) private var tamanoTexto
    @Environment(\.temaApp) private var temaApp
    @AppStorage("temaApp") private var temaElegido: TemaApp = .claro
    @AppStorage("temaDelSistema") private var temaDelSistema = true

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
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                }
                .accessibilityElement(children: .combine)
                .accessibilityValue(estado.idioma.nombre)
            }
            .filaTema(temaApp)

            AjustesToggleFila(
                sistema: "desktopcomputer",
                color: .gray,
                titulo: "Tema del sistema",
                subtitulo: "Sigue el modo claro/oscuro del iPhone",
                estaActivo: $temaDelSistema
            )
            .accessibilityIdentifier("tema-del-sistema")
            .filaTema(temaApp)

            AjustesFilaValor(
                sistema: "paintpalette.fill",
                color: .purple,
                titulo: "Tema de la app",
                valor: temaDelSistema ? "Sistema" : temaElegido.nombre,
                bloqueada: temaDelSistema
            )
            .filaTema(temaApp)

            if !temaDelSistema {
                galeriaTemas
            }
        } header: {
            Text("APARIENCIA")
        } footer: {
            Text("Desactiva «Tema del sistema» para elegir un tema propio.")
                .foregroundStyle(temaApp.texto.opacity(0.65))
        }
        .animation(.easeInOut(duration: 0.2), value: temaDelSistema)
    }

    private var galeriaTemas: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 8),
                count: tamanoTexto.isAccessibilitySize ? 2 : 4
            ),
            spacing: 10
        ) {
            ForEach(TemaApp.allCases) { tema in
                AjustesTarjetaTema(
                    tema: tema,
                    seleccionado: temaElegido == tema
                ) {
                    temaElegido = tema
                }
            }
        }
        .padding(.vertical, 4)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .filaTema(temaApp)
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
