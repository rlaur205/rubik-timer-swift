import SwiftUI

struct AparienciaSeccion: View {
    @Bindable var estado: AjustesEstado
    let abrirSelectorTema: () -> Void
    @Environment(\.temaApp) private var temaApp
    @AppStorage("temaApp") private var temaElegido: TemaApp = .claro
    @AppStorage("temaDelSistema") private var temaDelSistema = true

    var body: some View {
        Section {
            NavigationLink {
                IdiomaSelectorView(estado: estado)
            } label: {
                HStack(spacing: 12) {
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
                titulo: "Tema del sistema",
                estaActivo: $temaDelSistema
            )
            .accessibilityIdentifier("tema-del-sistema")
            .filaTema(temaApp)

            Button(action: abrirSelectorTema) {
                AjustesFilaValor(
                    titulo: "Tema de la app",
                    valor: temaDelSistema ? "Sistema" : temaElegido.nombre,
                    bloqueada: temaDelSistema,
                    muestraIndicador: !temaDelSistema
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(temaDelSistema)
            .accessibilityIdentifier("abrir-selector-tema")
            .filaTema(temaApp)
        } header: {
            Text("APARIENCIA")
        }
        .animation(.easeInOut(duration: 0.2), value: temaDelSistema)
    }
}

#Preview {
    NavigationStack {
        List {
            AparienciaSeccion(estado: AjustesEstado(), abrirSelectorTema: {})
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Ajustes")
    }
}
