import SwiftUI

struct AddServerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAdd: (Server) -> Void

    @State private var name = ""
    @State private var host = ""
    @State private var port = "8080"
    @State private var isTesting = false
    @State private var testResult: Bool?
    @State private var showError = false

    private var isValid: Bool {
        !host.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(port) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (optional)", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()

                    TextField("Host (IP or hostname)", text: $host)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Server Details")
                }

                Section {
                    Button {
                        testConnection()
                    } label: {
                        HStack {
                            Text("Test Connection")

                            Spacer()

                            if isTesting {
                                ProgressView()
                            } else if let result = testResult {
                                Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(result ? .green : .red)
                            }
                        }
                    }
                    .disabled(!isValid || isTesting)
                }
            }
            .navigationTitle("Add Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addServer()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Connection Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Could not connect to the server. Please check the host and port.")
            }
        }
    }

    private func testConnection() {
        guard let portInt = Int(port) else { return }

        let server = Server(
            name: name.trimmingCharacters(in: .whitespaces),
            host: host.trimmingCharacters(in: .whitespaces),
            port: portInt
        )

        isTesting = true
        testResult = nil

        Task {
            let result = await (try? BrowseyAPIClient.shared.checkConnection(server: server)) ?? false

            await MainActor.run {
                isTesting = false
                testResult = result
                if !result {
                    showError = true
                }
            }
        }
    }

    private func addServer() {
        guard let portInt = Int(port) else { return }

        let server = Server(
            name: name.trimmingCharacters(in: .whitespaces),
            host: host.trimmingCharacters(in: .whitespaces),
            port: portInt
        )

        onAdd(server)
        dismiss()
    }
}

#Preview {
    AddServerSheet { _ in }
}
