import Foundation

struct Server: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var host: String
    var port: Int
    var lastConnected: Date?
    var isDiscovered: Bool

    var baseURL: URL {
        URL(string: "http://\(host):\(port)")!
    }

    var displayName: String {
        if name.isEmpty {
            return "\(host):\(port)"
        }
        return name
    }

    init(id: UUID = UUID(), name: String = "", host: String, port: Int = 8080, lastConnected: Date? = nil, isDiscovered: Bool = false) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.lastConnected = lastConnected
        self.isDiscovered = isDiscovered
    }

    static func fromURL(_ url: URL) -> Server? {
        guard let host = url.host, let port = url.port else {
            return nil
        }
        return Server(host: host, port: port)
    }
}
