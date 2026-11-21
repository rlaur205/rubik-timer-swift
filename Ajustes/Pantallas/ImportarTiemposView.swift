import SwiftUI
import UniformTypeIdentifiers

struct ImportarTiemposView: View {
    @ObservedObject var vm: RubikViewModel
    var estiloRetro = false
    @Environment(\.dismiss) private var cerrar
    @Environment(\.dynamicTypeSize) private var tipoDinamico
    @Environment(\.temaApp) private var tema
    @Environment(\.retro) private var retro
    @State private var mostrarArchivos = false
    @State private var archivo: URL?
    @State private var importacion: ImportacionCSTimer?
    @State private var leyendo = false
    @State private var error: String?
    @State private var sesionesCreadas: Int?

    private var alturaPanel: PresentationDetent {
        if tipoDinamico.isAccessibilitySize || (importacion != nil && sesionesCreadas == nil) {
            return .large
        }
        return error == nil ? .height(285) : .medium
    }

    private var sesionesNuevas: [ImportacionCSTimer.Sesion] {
        let ids = Set(vm.tiemposPrincipal.map(\.id))
        return importacion?.sesiones.filter { !ids.contains($0.id) } ?? []
    }

    var body: some View {
        NavigationStack {
            List {
                if let sesionesCreadas {
                    Section {
                        Text("Sesiones creadas: \(sesionesCreadas.formatted())")
                        Button("Listo") { cerrar() }
                    }
                } else if let importacion {
                    vistaPrevia(importacion)
                } else if leyendo {
                    ProgressView("Leyendo respaldo…")
                } else {
                    Section("Importar desde") {
                        Button {
                            mostrarArchivos = true
                        } label: {
                            HStack {
                                Text("csTimer")
                                Spacer()
                                Image(systemName: "folder").accessibilityHidden(true)
                            }
                        }
                        fuentePendiente("CubeTime")
                        fuentePendiente("Twisty Timer")
                    }
                }
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Importar tiempos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { cerrar() }
                }
            }
            .tint(estiloRetro ? (retro.oscura ? retro.lima : retro.tinta) : tema.acento)
        }
        .presentationDetents([alturaPanel])
        .presentationDragIndicator(.visible)
        .fileImporter(isPresented: $mostrarArchivos, allowedContentTypes: [.plainText, .json]) { resultado in
            switch resultado {
            case .success(let url):
                error = nil
                importacion = nil
                leyendo = true
                archivo = url
            case .failure(let fallo):
                error = fallo.localizedDescription
            }
        }
        .task(id: archivo) {
            guard let archivo else { return }
            await leer(archivo)
        }
    }

    private func fuentePendiente(_ nombre: String) -> some View {
        HStack {
            Text(nombre)
            Spacer()
            Text("Próximamente").font(.footnote)
        }
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
    }

    private func vistaPrevia(_ importacion: ImportacionCSTimer) -> some View {
        let nuevas = sesionesNuevas
        let repetidas = importacion.sesiones.count - nuevas.count
        let cantidad = nuevas.reduce(0) { $0 + $1.tiempos.count }

        return Group {
            Section("Respaldo de csTimer") {
                LabeledContent("Sesiones nuevas", value: nuevas.count.formatted())
                LabeledContent("Tiempos a importar", value: cantidad.formatted())
                if importacion.sesionesOmitidas > 0 {
                    LabeledContent("Sesiones de puzzles no compatibles", value: importacion.sesionesOmitidas.formatted())
                    LabeledContent("Tiempos omitidos", value: importacion.tiemposOmitidos.formatted())
                }
                if repetidas > 0 {
                    LabeledContent("Sesiones ya importadas", value: repetidas.formatted())
                }
                Button("Importar sesiones") {
                    do {
                        sesionesCreadas = try vm.importarSesiones(nuevas)
                        error = nil
                    } catch {
                        self.error = "No se pudieron guardar las sesiones. \(error.localizedDescription)"
                    }
                }
                .disabled(nuevas.isEmpty)
                Button("Elegir otro archivo") { mostrarArchivos = true }
            }
            if !nuevas.isEmpty {
                Section("Sesiones") {
                    ForEach(nuevas) { sesion in
                        LabeledContent {
                            Text(sesion.tiempos.count.formatted())
                                .monospacedDigit()
                                .accessibilityLabel("\(sesion.tiempos.count.formatted()) tiempos")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(sesion.nombre)
                                Text(sesion.categoria)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func leer(_ url: URL) async {
        let lectura = Task.detached(priority: .userInitiated) { try ImportadorCSTimer.leer(url) }
        do {
            let resultado = try await withTaskCancellationHandler {
                try await lectura.value
            } onCancel: {
                lectura.cancel()
            }
            try Task.checkCancellation()
            importacion = resultado
        } catch is CancellationError {
            return
        } catch {
            self.error = error.localizedDescription
        }
        leyendo = false
        archivo = nil
    }
}
