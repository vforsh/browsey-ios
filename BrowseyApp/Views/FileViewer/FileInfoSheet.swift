import SwiftUI

struct FileInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: FileViewerViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    InfoRow(label: "Name", value: viewModel.file.name)
                    InfoRow(label: "Type", value: viewModel.file.extension?.uppercased() ?? "Unknown")
                    InfoRow(label: "Size", value: SizeFormatter.format(viewModel.file.size))
                }

                Section {
                    InfoRow(label: "Modified", value: SizeFormatter.formatDate(viewModel.file.modified))

                    if let created = viewModel.fileInfo?.created {
                        InfoRow(label: "Created", value: SizeFormatter.formatDate(created))
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Path")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(viewModel.file.absolutePath)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("File Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .textSelection(.enabled)
        }
    }
}

struct BinaryFileView: View {
    let file: FileItem
    let onDownload: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: FileTypeHelper.icon(for: file))
                .font(.system(size: 64))
                .foregroundStyle(FileTypeHelper.iconColor(for: file))

            VStack(spacing: 8) {
                Text(file.name)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(SizeFormatter.format(file.size))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Text("This file type cannot be previewed")
                .font(.callout)
                .foregroundStyle(.secondary)

            Button {
                onDownload()
            } label: {
                Label("Download", systemImage: "arrow.down.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    FileInfoSheet(
        viewModel: FileViewerViewModel(
            server: Server(name: "Test", host: "localhost", port: 8080),
            file: FileItem(
                name: "document.pdf",
                type: .file,
                size: 1_234_567,
                modified: Date(),
                extension: "pdf",
                absolutePath: "/path/to/document.pdf"
            )
        )
    )
}
