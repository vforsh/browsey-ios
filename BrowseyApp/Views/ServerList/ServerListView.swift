import SwiftUI

struct ServerListView: View {
    @Environment(ServerStorage.self) private var serverStorage
    @Environment(BonjourDiscovery.self) private var bonjourDiscovery

    @State private var viewModel = ServerListViewModel()
    @State private var showAddServer = false
    @State private var showQRScanner = false
    @State private var selectedServer: Server?

    var body: some View {
        List {
            if !bonjourDiscovery.discoveredServers.isEmpty {
                Section("Discovered") {
                    ForEach(bonjourDiscovery.discoveredServers) { server in
                        ServerRowView(
                            server: server,
                            isOnline: viewModel.isOnline(server)
                        )
                        .onTapGesture {
                            selectedServer = server
                        }
                    }
                }
            }

            Section("Saved Servers") {
                if serverStorage.savedServers.isEmpty {
                    ContentUnavailableView {
                        Label("No Servers", systemImage: "server.rack")
                    } description: {
                        Text("Add a server manually or scan a QR code")
                    }
                } else {
                    ForEach(serverStorage.savedServers) { server in
                        ServerRowView(
                            server: server,
                            isOnline: viewModel.isOnline(server)
                        )
                        .onTapGesture {
                            selectedServer = server
                            serverStorage.updateLastConnected(server)
                        }
                    }
                    .onDelete(perform: deleteServers)
                }
            }
        }
        .navigationTitle("Browsey")
        .navigationDestination(item: $selectedServer) { server in
            FileBrowserView(server: server)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showAddServer = true
                    } label: {
                        Label("Add Manually", systemImage: "plus")
                    }

                    Button {
                        showQRScanner = true
                    } label: {
                        Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                if viewModel.isCheckingConnections || bonjourDiscovery.isSearching {
                    ProgressView()
                }
            }
        }
        .refreshable {
            await refreshAll()
        }
        .sheet(isPresented: $showAddServer) {
            AddServerSheet { server in
                serverStorage.addServer(server)
            }
        }
        .sheet(isPresented: $showQRScanner) {
            QRScannerView { server in
                serverStorage.addServer(server)
                showQRScanner = false
            }
        }
        .task {
            bonjourDiscovery.startDiscovery()
            await refreshAll()
        }
    }

    private func refreshAll() async {
        let allServers = serverStorage.savedServers + bonjourDiscovery.discoveredServers
        await viewModel.checkAllConnections(servers: allServers)
    }

    private func deleteServers(at offsets: IndexSet) {
        for index in offsets {
            serverStorage.removeServer(serverStorage.savedServers[index])
        }
    }
}

#Preview {
    NavigationStack {
        ServerListView()
    }
    .environment(ServerStorage())
    .environment(BonjourDiscovery())
}
