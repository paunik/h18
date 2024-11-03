import Vapor
import Gzip

struct GzipMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: req)

        guard req.headers[.acceptEncoding].contains(where: { $0.contains("gzip") }) else {
            return response
        }

        guard let body = response.body.data, !body.isEmpty else {
            return response
        }

        // Compress the response body using Gzip
        let compressedData = try body.gzipped()
        response.body = .init(data: compressedData)

        // Set the appropriate headers
        response.headers.replaceOrAdd(name: .contentEncoding, value: "gzip")

        return response
    }
}