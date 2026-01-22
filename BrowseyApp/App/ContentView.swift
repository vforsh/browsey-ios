import SwiftUI

struct ContentView: View {
    @State private var serverStorage = ServerStorage()
    @State private var bonjourDiscovery = BonjourDiscovery()

    var body: some View {
        NavigationStack {
            ServerListView()
        }
        .environment(serverStorage)
        .environment(bonjourDiscovery)
    }
}

#Preview {
    ContentView()
}
