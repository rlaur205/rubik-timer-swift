import SwiftUI
import WebKit

struct ImagenScrambleView: View {
    let scramble: String
    let categoria: String

    var body: some View {
        let solicitud = SolicitudDiagrama(scramble: scramble, categoria: categoria)
        VisorDiagrama(solicitud: solicitud)
            .id(solicitud)
    }
}

private struct SolicitudDiagrama: Hashable {
    let scramble: String
    let categoria: String
}

private enum EstadoDiagrama {
    case cargando
    case listo
    case error
}

private struct VisorDiagrama: View {
    let solicitud: SolicitudDiagrama
    @State private var estado: EstadoDiagrama = .cargando
    @State private var intento = 0

    var body: some View {
        ZStack {
            DiagramaWeb(solicitud: solicitud, cambiarEstado: { estado = $0 })
                .id(intento)
                .opacity(estado == .listo ? 1 : 0)
                .accessibilityHidden(estado != .listo)
                .accessibilityLabel("Diagrama del scramble")
                .accessibilityIdentifier("diagrama-scramble")

            switch estado {
            case .cargando:
                ProgressView("Cargando diagrama…").font(.subheadline)
            case .listo:
                EmptyView()
            case .error:
                VStack(spacing: 8) {
                    Text("No se pudo cargar el diagrama.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    Button("Reintentar") {
                        estado = .cargando
                        intento += 1
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("reintentar-diagrama")
                }
                .padding(8)
            }
        }
    }
}

private struct DiagramaWeb: UIViewRepresentable {
    let solicitud: SolicitudDiagrama
    let cambiarEstado: (EstadoDiagrama) -> Void

    func makeCoordinator() -> Coordinador {
        Coordinador(solicitud: solicitud, cambiarEstado: cambiarEstado)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuracion = WKWebViewConfiguration()
        configuracion.websiteDataStore = .nonPersistent()

        let vista = WKWebView(frame: .zero, configuration: configuracion)
        vista.isOpaque = false
        vista.backgroundColor = .clear
        vista.underPageBackgroundColor = .clear
        vista.isUserInteractionEnabled = false
        vista.scrollView.isScrollEnabled = false
        vista.scrollView.backgroundColor = .clear
        vista.scrollView.contentInsetAdjustmentBehavior = .never
        vista.navigationDelegate = context.coordinator
        context.coordinator.cargar(en: vista)
        return vista
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinador) {
        coordinator.cancelar()
        webView.navigationDelegate = nil
        webView.stopLoading()
    }

    @MainActor
    final class Coordinador: NSObject, WKNavigationDelegate {
        private let solicitud: SolicitudDiagrama
        private let cambiarEstado: (EstadoDiagrama) -> Void
        private var tarea: Task<Void, Never>?
        private var limite: Task<Void, Never>?
        private var navegacion: WKNavigation?
        private var url: URL?

        init(solicitud: SolicitudDiagrama, cambiarEstado: @escaping (EstadoDiagrama) -> Void) {
            self.solicitud = solicitud
            self.cambiarEstado = cambiarEstado
        }

        func cargar(en vista: WKWebView) {
            limite = Task { [weak self, weak vista] in
                do { try await Task.sleep(for: .seconds(12)) } catch { return }
                guard let self, let vista else { return }
                if navegacion != nil, let url { ScrambleEngine.shared.invalidarServidorVisor(en: url) }
                finalizar(.error)
                vista.stopLoading()
            }

            tarea = Task { [weak self, weak vista] in
                do {
                    let url = try await ScrambleEngine.shared.viewerURL()
                    guard !Task.isCancelled, let self, let vista else { return }
                    self.url = url
                    navegacion = vista.load(URLRequest(url: url))
                    if navegacion == nil { finalizar(.error) }
                } catch {
                    if !Task.isCancelled { self?.finalizar(.error) }
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let navegacion, navegacion === navigation else { return }
            self.navegacion = nil
            guard let puzzle = Self.puzzle(para: solicitud.categoria) else {
                finalizar(.error)
                return
            }

            let alg = solicitud.scramble
            tarea = Task { [weak self, weak webView] in
                guard let webView else { return }
                do {
                    let resultado = try await webView.callAsyncJavaScript(
                        "return await window.__setScramble(puzzle, alg);",
                        arguments: ["puzzle": puzzle, "alg": alg],
                        in: nil,
                        contentWorld: .page
                    )
                    if !Task.isCancelled {
                        self?.finalizar((resultado as? Bool) == true ? .listo : .error)
                    }
                } catch {
                    if !Task.isCancelled { self?.finalizar(.error) }
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            falloNavegacion(navigation)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            falloNavegacion(navigation)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            finalizar(.error)
        }

        private func falloNavegacion(_ navigation: WKNavigation?) {
            guard let navegacion, navegacion === navigation else { return }
            if let url { ScrambleEngine.shared.invalidarServidorVisor(en: url) }
            finalizar(.error)
        }

        private func finalizar(_ estado: EstadoDiagrama) {
            cancelar()
            cambiarEstado(estado)
        }

        func cancelar() {
            tarea?.cancel()
            limite?.cancel()
            tarea = nil
            limite = nil
            navegacion = nil
        }

        /// Identificador de puzzle que entiende cubing.js.
        static func puzzle(para categoria: String) -> String? {
            switch categoria {
            case "2x2": return "2x2x2"
            case "3x3", "3x3 OH", "3x3 BLD": return "3x3x3"
            case "4x4", "4x4 BLD": return "4x4x4"
            case "5x5", "5x5 BLD": return "5x5x5"
            case "6x6": return "6x6x6"
            case "7x7": return "7x7x7"
            case "Pyraminx": return "pyraminx"
            case "Megaminx": return "megaminx"
            case "Skewb": return "skewb"
            case "Square 1": return "square1"
            default: return nil
            }
        }
    }
}
