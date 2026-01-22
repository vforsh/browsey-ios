import Foundation

@Observable
class ServerStorage {
    private(set) var savedServers: [Server] = []

    private let userDefaultsKey = "savedServers"

    init() {
        loadServers()
    }

    func addServer(_ server: Server) {
        var serverToAdd = server
        serverToAdd.lastConnected = Date()

        if let index = savedServers.firstIndex(where: { $0.host == server.host && $0.port == server.port }) {
            savedServers[index] = serverToAdd
        } else {
            savedServers.append(serverToAdd)
        }

        saveServers()
    }

    func removeServer(_ server: Server) {
        savedServers.removeAll { $0.id == server.id }
        saveServers()
    }

    func updateLastConnected(_ server: Server) {
        if let index = savedServers.firstIndex(where: { $0.id == server.id }) {
            savedServers[index].lastConnected = Date()
            saveServers()
        }
    }

    private func loadServers() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }

        do {
            savedServers = try JSONDecoder().decode([Server].self, from: data)
        } catch {
            print("Failed to load servers: \(error)")
        }
    }

    private func saveServers() {
        do {
            let data = try JSONEncoder().encode(savedServers)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save servers: \(error)")
        }
    }
}
