import SwiftUI

struct ServerRowView: View {
    let server: Server
    let isOnline: Bool?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: server.isDiscovered ? "antenna.radiowaves.left.and.right" : "server.rack")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(server.displayName)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Text("\(server.host):\(server.port)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let lastConnected = server.lastConnected {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(SizeFormatter.formatDate(lastConnected))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            statusIndicator
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var statusIndicator: some View {
        if let isOnline = isOnline {
            Circle()
                .fill(isOnline ? .green : .red)
                .frame(width: 10, height: 10)
        } else {
            ProgressView()
                .scaleEffect(0.7)
        }
    }
}

#Preview {
    List {
        ServerRowView(
            server: Server(name: "MacBook Pro", host: "192.168.1.100", port: 8080),
            isOnline: true
        )

        ServerRowView(
            server: Server(host: "192.168.1.101", port: 3000, lastConnected: Date()),
            isOnline: false
        )

        ServerRowView(
            server: Server(name: "Discovered Server", host: "192.168.1.102", port: 8080, isDiscovered: true),
            isOnline: nil
        )
    }
}
