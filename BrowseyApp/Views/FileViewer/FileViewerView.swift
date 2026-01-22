import SwiftUI

struct FileViewerView: View {
    let server: Server
    let file: FileItem

    @State private var viewModel: FileViewerViewModel
    @State private var showFileInfo = false
    @State private var showShareSheet = false
    @State private var downloadedFileURL: URL?

    init(server: Server, file: FileItem) {
        self.server = server
        self.file = file
        self._viewModel = State(initialValue: FileViewerViewModel(server: server, file: file))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadContent()
                        }
                    }
                }
            } else if let content = viewModel.content {
                contentView(for: content)
            } else {
                BinaryFileView(file: file) {
                    downloadFile()
                }
            }
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showFileInfo = true
                    } label: {
                        Label("File Info", systemImage: "info.circle")
                    }

                    Button {
                        downloadFile()
                    } label: {
                        Label("Download", systemImage: "arrow.down.circle")
                    }

                    if downloadedFileURL != nil {
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showFileInfo) {
            FileInfoSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = downloadedFileURL {
                ShareSheet(items: [url])
            }
        }
        .task {
            await viewModel.loadContent()
            await viewModel.loadFileInfo()
        }
    }

    @ViewBuilder
    private func contentView(for content: FileContent) -> some View {
        switch content.type {
        case .text:
            CodeViewerView(content: content.content ?? "", language: content.language)

        case .markdown:
            MarkdownViewerView(content: content.content ?? "")

        case .image:
            ImageViewerView(imageURL: viewModel.imageURL)

        case .binary:
            BinaryFileView(file: file) {
                downloadFile()
            }
        }
    }

    private func downloadFile() {
        Task {
            if let url = await viewModel.downloadFile() {
                await MainActor.run {
                    downloadedFileURL = url
                    showShareSheet = true
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        FileViewerView(
            server: Server(name: "Test", host: "localhost", port: 8080),
            file: FileItem(
                name: "test.swift",
                type: .file,
                size: 1024,
                modified: Date(),
                extension: "swift",
                absolutePath: "/test.swift"
            )
        )
    }
}
