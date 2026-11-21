import Foundation
import JavaScriptCore

/// Conserva las tablas del solver entre scrambles y ejecuta JavaScript fuera del hilo de la interfaz.
actor FTOScrambler {
    static let shared = FTOScrambler()

    private var contexto: JSContext?

    func scramble() throws -> String {
        let js = try preparar()
        js.exception = nil
        guard let resultado = js.objectForKeyedSubscript("__generarFTO")?.call(withArguments: []),
              resultado.isString, let scramble = resultado.toString(), !scramble.isEmpty,
              js.exception == nil else {
            throw ScrambleEngineError.generacion("El solver de FTO no devolvió un scramble.")
        }
        return scramble
    }

    private func preparar() throws -> JSContext {
        if let contexto { return contexto }

        guard let url = Bundle.main.url(forResource: "fto", withExtension: "js", subdirectory: "ScrambleEngine"),
              let js = JSContext() else {
            throw ScrambleEngineError.recursosNoEncontrados
        }
        let enteroAleatorio: @convention(block) () -> Double = {
            Double(UInt32.random(in: UInt32.min...UInt32.max))
        }
        let relojMonotono: @convention(block) () -> Double = {
            ProcessInfo.processInfo.systemUptime * 1000
        }
        js.setObject(enteroAleatorio, forKeyedSubscript: "__enteroAleatorio" as NSString)
        js.setObject(relojMonotono, forKeyedSubscript: "__relojMonotono" as NSString)
        js.evaluateScript(try String(contentsOf: url, encoding: .utf8), withSourceURL: url)
        if let error = js.exception?.toString() {
            throw ScrambleEngineError.generacion(error)
        }
        contexto = js
        return js
    }
}
