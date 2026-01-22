import Foundation

@Observable
class ServerListViewModel {
    private(set) var connectionStatuses: [UUID: Bool] = [:]
    private(set) var isCheckingConnections = false

    private let apiClient = BrowseyAPIClient.shared

    func checkConnection(for server: Server) async {
        let isOnline = await (try? apiClient.checkConnection(server: server)) ?? false
        await MainActor.run {
            connectionStatuses[server.id] = isOnline
        }
    }

    func checkAllConnections(servers: [Server]) async {
        await MainActor.run {
            isCheckingConnections = true
        }

        await withTaskGroup(of: Void.self) { group in
            for server in servers {
                group.addTask {
                    await self.checkConnection(for: server)
                }
            }
        }

        await MainActor.run {
            isCheckingConnections = false
        }
    }

    func parseServerURL(_ urlString: String) -> Server? {
        var normalizedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        if !normalizedURL.hasPrefix("http://") && !normalizedURL.hasPrefix("https://") {
            normalizedURL = "http://\(normalizedURL)"
        }

        guard let url = URL(string: normalizedURL),
              let host = url.host else {
            return nil
        }

        let port = url.port ?? 8080
        return Server(host: host, port: port)
    }

    func isOnline(_ server: Server) -> Bool? {
        connectionStatuses[server.id]
    }
}
