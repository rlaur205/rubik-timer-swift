import SwiftUI
import WebKit

/// Diagrama 2D del scramble, dibujado con el `TwistyPlayer` de cubing.js dentro de
/// un `WKWebView` transparente y sin interacción.
///
/// La página del visor se sirve desde el servidor local de `ScrambleEngine`; si ese
/// servidor no arranca, simplemente no se dibuja nada. Los scrambles los genera
/// TNoodle en el propio dispositivo (ver `TNoodleScrambler`).
struct ImagenScrambleView: UIViewRepresentable {

    let scramble: String
    let categoria: String

    func makeCoordinator() -> Coordinador {
        Coordinador()
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

        context.coordinator.configurar(vista)
        return vista
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.mostrar(scramble: scramble, categoria: categoria)
    }
}

extension ImagenScrambleView {

    @MainActor
    final class Coordinador: NSObject, WKNavigationDelegate {

        private weak var webView: WKWebView?
        private var cargando = false
        private var paginaLista = false
        private var pendiente: (puzzle: String, alg: String)?
        private var aplicadoPuzzle: String?
        private var aplicadoAlg: String?

        func configurar(_ webView: WKWebView) {
            self.webView = webView
        }

        /// Guarda el scramble y lo pinta cuando la página esté lista.
        func mostrar(scramble: String, categoria: String) {
            guard let puzzle = Self.puzzle(para: categoria), !scramble.isEmpty else {
                return
            }

            pendiente = (puzzle: puzzle, alg: scramble)
            cargarSiHaceFalta()
            aplicarPendiente()
        }

        // MARK: - Carga

        private func cargarSiHaceFalta() {
            guard webView != nil, !cargando, !paginaLista else { return }
            cargando = true

            Task { @MainActor in
                // `viewerURL()` arranca el motor si aún no estaba listo, así que
                // puede tardar un poco. Reintentamos por si el motor se reconstruye.
                for intento in 0..<3 {
                    if let url = try? await ScrambleEngine.shared.viewerURL() {
                        webView?.load(URLRequest(url: url))
                        return
                    }

                    cargando = false
                    if intento < 2 {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        cargando = true
                    }
                }

                cargando = false
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            paginaLista = true
            cargando = false
            #if DEBUG
            NSLog("[Scramble] visor cargado")
            #endif
            aplicarPendiente()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            NSLog("[Scramble] visor fallo: \(error.localizedDescription)")
            #endif
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            #if DEBUG
            NSLog("[Scramble] visor fallo provisional: \(error.localizedDescription)")
            #endif
        }

        // MARK: - Dibujo

        private func aplicarPendiente() {
            guard paginaLista, let webView, let pendiente else { return }
            guard aplicadoPuzzle != pendiente.puzzle || aplicadoAlg != pendiente.alg else { return }

            aplicadoPuzzle = pendiente.puzzle
            aplicadoAlg = pendiente.alg

            Task { @MainActor in
                do {
                    _ = try await webView.callAsyncJavaScript(
                        "return await window.__setScramble(puzzle, alg);",
                        arguments: ["puzzle": pendiente.puzzle, "alg": pendiente.alg],
                        in: nil,
                        contentWorld: .page
                    )
                    #if DEBUG
                    NSLog("[Scramble] visor pintado \(pendiente.puzzle)")
                    #endif
                } catch {
                    #if DEBUG
                    NSLog("[Scramble] visor error al pintar: \(error.localizedDescription)")
                    #endif
                }
            }
        }

        // MARK: - Categorías

        /// Identificador de puzzle que entiende cubing.js.
        static func puzzle(para categoria: String) -> String? {
            switch categoria {
            case "2x2": return "2x2x2"
            case "3x3", "3x3 OH", "3x3 BLD": return "3x3x3"
            case "4x4": return "4x4x4"
            case "5x5": return "5x5x5"
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
