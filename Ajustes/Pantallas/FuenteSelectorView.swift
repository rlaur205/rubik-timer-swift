import SwiftUI

struct FuenteSelectorFila<Fuente: FuenteAjuste>: View {
    let titulo: String
    let ejemplo: String
    let pesoPredeterminado: Font.Weight
    let identificador: String
    @Binding var seleccion: Fuente
    @State private var mostrarSelector = false

    var body: some View {
        Button { mostrarSelector = true } label: {
            AjustesFilaValor(titulo: titulo, valor: seleccion.nombre, muestraIndicador: true)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("selector-\(identificador)")
        .popover(isPresented: $mostrarSelector) {
            FuenteSelectorView(
                ejemplo: ejemplo,
                pesoPredeterminado: pesoPredeterminado,
                identificadorLista: identificador,
                seleccion: $seleccion
            )
        }
    }
}

private struct FuenteSelectorView<Fuente: FuenteAjuste>: View {
    let ejemplo: String
    let pesoPredeterminado: Font.Weight
    let identificadorLista: String
    @Binding var seleccion: Fuente
    @Environment(\.dismiss) private var cerrar
    @Environment(\.temaApp) private var temaApp

    var body: some View {
        List {
            ForEach(Fuente.allCases) { opcion in
                Button {
                    seleccion = opcion
                    cerrar()
                } label: {
                    HStack(spacing: 12) {
                        Text(opcion.nombre)
                            .font(opcion.fontLista(tamano: 17, pesoPredeterminado: pesoPredeterminado))
                            .foregroundStyle(temaApp.texto)

                        Spacer(minLength: 8)

                        Text(ejemplo)
                            .font(opcion.fontLista(tamano: 16, pesoPredeterminado: pesoPredeterminado))
                            .monospacedDigit()
                            .foregroundStyle(temaApp.texto.opacity(0.75))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        if seleccion == opcion {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(temaApp.acento)
                                .accessibilityHidden(true)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(opcion.nombre)
                .accessibilityValue(seleccion == opcion ? "Seleccionado" : "")
                .accessibilityAddTraits(seleccion == opcion ? .isSelected : [])
                .accessibilityIdentifier("\(identificadorLista)-\(opcion.id)")
                .filaTema(temaApp)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .frame(idealWidth: 320, maxWidth: 320, idealHeight: 420, maxHeight: 420)
        .presentationBackground(temaApp.superficie)
        .presentationCompactAdaptation(.popover)
    }
}
