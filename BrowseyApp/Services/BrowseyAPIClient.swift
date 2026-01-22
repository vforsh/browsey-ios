import Foundation

actor BrowseyAPIClient {
    static let shared = BrowseyAPIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
    }

    func listDirectory(server: Server, path: String) async throws -> DirectoryListing {
        let url = buildURL(server: server, endpoint: "/api/list", path: path)
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        return try decoder.decode(DirectoryListing.self, from: data)
    }

    func viewFile(server: Server, path: String) async throws -> FileContent {
        let url = buildURL(server: server, endpoint: "/api/view", path: path)
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        return try decoder.decode(FileContent.self, from: data)
    }

    func getFileInfo(server: Server, path: String) async throws -> FileInfo {
        let url = buildURL(server: server, endpoint: "/api/stat", path: path)
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        return try decoder.decode(FileInfo.self, from: data)
    }

    func downloadFile(server: Server, path: String) async throws -> Data {
        let url = buildURL(server: server, endpoint: "/api/file", path: path)
        let (data, response) = try await session.data(from: url)
        try validateResponse(response)
        return data
    }

    func checkConnection(server: Server) async throws -> Bool {
        let url = buildURL(server: server, endpoint: "/api/list", path: "/")
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...299).contains(httpResponse.statusCode)
            }
            return false
        } catch {
            return false
        }
    }

    nonisolated func getImageURL(server: Server, path: String) -> URL {
        Self.buildURL(server: server, endpoint: "/api/file", path: path)
    }

    private func buildURL(server: Server, endpoint: String, path: String) -> URL {
        Self.buildURL(server: server, endpoint: endpoint, path: path)
    }

    private static func buildURL(server: Server, endpoint: String, path: String) -> URL {
        var components = URLComponents(url: server.baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "path", value: path)]
        return components.url!
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server error (HTTP \(statusCode))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
