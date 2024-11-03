import Vapor
import Gzip

struct GzipMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: req)

        // Only compress if the response should be compressed and is not empty
        if let body = response.body.data, !body.isEmpty {
            // Compress the response body using Gzip
            let compressedData = try body.gzipped()
            response.body = .init(data: compressedData)

            // Set the appropriate headers
            response.headers.replaceOrAdd(name: .contentEncoding, value: "gzip")
            response.headers.replaceOrAdd(name: .contentLength, value: "\(compressedData.count)")
        }

        return response
    }
}
