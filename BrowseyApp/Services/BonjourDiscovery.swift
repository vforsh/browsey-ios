import Foundation
import Network

@Observable
class BonjourDiscovery {
    private(set) var discoveredServers: [Server] = []
    private(set) var isSearching = false

    private var browser: NWBrowser?
    private var connections: [NWConnection] = []

    func startDiscovery() {
        guard browser == nil else { return }

        isSearching = true
        discoveredServers = []

        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        let browser = NWBrowser(for: .bonjour(type: "_browsey._tcp", domain: nil), using: parameters)

        browser.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isSearching = true
                case .failed, .cancelled:
                    self?.isSearching = false
                default:
                    break
                }
            }
        }

        browser.browseResultsChangedHandler = { [weak self] results, changes in
            self?.handleBrowseResults(results)
        }

        browser.start(queue: .main)
        self.browser = browser
    }

    func stopDiscovery() {
        browser?.cancel()
        browser = nil
        isSearching = false

        for connection in connections {
            connection.cancel()
        }
        connections = []
    }

    private func handleBrowseResults(_ results: Set<NWBrowser.Result>) {
        for result in results {
            if case .service(let name, let type, let domain, _) = result.endpoint {
                resolveService(name: name, type: type, domain: domain)
            }
        }
    }

    private func resolveService(name: String, type: String, domain: String) {
        let endpoint = NWEndpoint.service(name: name, type: type, domain: domain, interface: nil)
        let connection = NWConnection(to: endpoint, using: .tcp)

        connection.stateUpdateHandler = { [weak self] state in
            if case .ready = state {
                if let innerEndpoint = connection.currentPath?.remoteEndpoint,
                   case .hostPort(let host, let port) = innerEndpoint {
                    DispatchQueue.main.async {
                        let hostString: String
                        switch host {
                        case .ipv4(let addr):
                            hostString = "\(addr)"
                        case .ipv6(let addr):
                            hostString = "\(addr)"
                        case .name(let hostname, _):
                            hostString = hostname
                        @unknown default:
                            hostString = "unknown"
                        }

                        let server = Server(
                            name: name,
                            host: hostString,
                            port: Int(port.rawValue),
                            isDiscovered: true
                        )

                        if !self!.discoveredServers.contains(where: { $0.host == server.host && $0.port == server.port }) {
                            self?.discoveredServers.append(server)
                        }
                    }
                }
                connection.cancel()
            }
        }

        connection.start(queue: .global())
        connections.append(connection)
    }
}
