import Foundation
import Network

/// Servidor HTTP mínimo que sirve los recursos del motor de scrambles en `127.0.0.1`.
///
/// ¿Por qué un servidor y no `file://`? Porque `WKWebView` no deja cargar módulos ES
/// ni crear Web Workers desde `file://`, y los `WKURLSchemeHandler` personalizados
/// tampoco los soportan de forma fiable. Sirviendo en loopback el motor tiene un
/// origen `http://127.0.0.1:<puerto>` normal y funciona igual que en un navegador.
///
/// Solo escucha en la interfaz de loopback, así que no es accesible desde la red.
final class ScrambleHTTPServer: @unchecked Sendable {

    private let root: URL
    private let queue = DispatchQueue(label: "com.laurencio.scramble.http")
    private var listener: NWListener?

    init(root: URL) {
        self.root = root
    }

    /// Arranca el servidor en un puerto libre y devuelve el puerto asignado.
    func start() async throws -> UInt16 {
        try await withCheckedThrowingContinuation { continuation in
            let box = ContinuationBox(continuation)

            queue.async { [self] in
                do {
                    let parameters = NWParameters.tcp
                    parameters.allowLocalEndpointReuse = true
                    parameters.requiredInterfaceType = .loopback

                    let listener = try NWListener(using: parameters, on: .any)

                    listener.stateUpdateHandler = { state in
                        switch state {
                        case .ready:
                            box.resume(.success(listener.port?.rawValue ?? 0))
                        case .failed(let error):
                            box.resume(.failure(error))
                        case .cancelled:
                            box.resume(.failure(URLError(.cancelled)))
                        default:
                            break
                        }
                    }

                    listener.newConnectionHandler = { [weak self] connection in
                        self?.accept(connection)
                    }

                    self.listener = listener
                    listener.start(queue: self.queue)
                } catch {
                    box.resume(.failure(error))
                }
            }
        }
    }

    /// Cierra el servidor. Se usa al reconstruir el motor tras un fallo.
    func cancel() {
        queue.async { [self] in
            listener?.cancel()
            listener = nil
        }
    }

    // MARK: - Peticiones

    private func accept(_ connection: NWConnection) {
        connection.start(queue: queue)
        receive(on: connection, buffer: Data())
    }

    private func receive(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else {
                connection.cancel()
                return
            }

            var buffer = buffer
            if let data {
                buffer.append(data)
            }

            if let headerEnd = buffer.range(of: Data("\r\n\r\n".utf8)) {
                let header = String(decoding: buffer[..<headerEnd.lowerBound], as: UTF8.self)
                self.respond(to: connection, header: header)
                return
            }

            if error != nil || isComplete || buffer.count > 64 * 1024 {
                connection.cancel()
                return
            }

            self.receive(on: connection, buffer: buffer)
        }
    }

    private func respond(to connection: NWConnection, header: String) {
        guard let requestLine = header.split(separator: "\r\n").first else {
            send(status: 400, reason: "Bad Request", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2, parts[0] == "GET" else {
            send(status: 405, reason: "Method Not Allowed", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        var path = String(parts[1])
        if let queryStart = path.firstIndex(of: "?") {
            path = String(path[..<queryStart])
        }
        if path.isEmpty || path == "/" {
            path = "/index.html"
        }

        let decoded = path.removingPercentEncoding ?? path
        let relative = decoded.hasPrefix("/") ? String(decoded.dropFirst()) : decoded

        // Nada de salir del directorio de recursos.
        guard !relative.split(separator: "/").contains("..") else {
            send(status: 403, reason: "Forbidden", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        let fileURL = root.appendingPathComponent(relative)

        guard let body = try? Data(contentsOf: fileURL) else {
            send(status: 404, reason: "Not Found", body: Data(), contentType: "text/plain", on: connection)
            return
        }

        send(
            status: 200,
            reason: "OK",
            body: body,
            contentType: Self.contentType(for: fileURL.pathExtension),
            on: connection
        )
    }

    private func send(
        status: Int,
        reason: String,
        body: Data,
        contentType: String,
        on connection: NWConnection
    ) {
        var response = Data()
        response.append(Data("HTTP/1.1 \(status) \(reason)\r\n".utf8))
        response.append(Data("Content-Type: \(contentType)\r\n".utf8))
        response.append(Data("Content-Length: \(body.count)\r\n".utf8))
        response.append(Data("Cache-Control: no-store\r\n".utf8))
        response.append(Data("Connection: close\r\n\r\n".utf8))
        response.append(body)

        connection.send(content: response, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private static func contentType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "js", "mjs": return "text/javascript; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "json": return "application/json; charset=utf-8"
        case "wasm": return "application/wasm"
        case "svg": return "image/svg+xml"
        case "png": return "image/png"
        default: return "application/octet-stream"
        }
    }
}

/// Contenedor con cerrojo para no reanudar una `CheckedContinuation` dos veces.
private final class ContinuationBox: @unchecked Sendable {

    private let lock = NSLock()
    private var continuation: CheckedContinuation<UInt16, Error>?

    init(_ continuation: CheckedContinuation<UInt16, Error>) {
        self.continuation = continuation
    }

    func resume(_ result: Result<UInt16, Error>) {
        lock.lock()
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume(with: result)
    }
}
