import SwiftUI

struct FileBrowserView: View {
    let server: Server

    @State private var viewModel: FileBrowserViewModel
    @State private var selectedFile: FileItem?

    init(server: Server, path: String = "/") {
        self.server = server
        self._viewModel = State(initialValue: FileBrowserViewModel(server: server, path: path))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadDirectory()
                        }
                    }
                }
            } else if viewModel.items.isEmpty {
                ContentUnavailableView {
                    Label("Empty Folder", systemImage: "folder")
                } description: {
                    Text("This directory is empty")
                }
            } else {
                List {
                    if viewModel.canGoUp {
                        ParentDirectoryRow()
                            .onTapGesture {
                                Task {
                                    await viewModel.goUp()
                                }
                            }
                    }

                    ForEach(viewModel.sortedItems) { item in
                        FileRowView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                handleItemTap(item)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(viewModel.currentDirectoryName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedFile) { file in
            if file.isDirectory {
                FileBrowserView(server: server, path: file.absolutePath)
            } else {
                FileViewerView(server: server, file: file)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                BreadcrumbMenu(
                    currentPath: viewModel.currentPath,
                    onNavigate: { path in
                        Task {
                            await viewModel.navigateTo(path)
                        }
                    }
                )
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadDirectory()
        }
    }

    private func handleItemTap(_ item: FileItem) {
        selectedFile = item
    }
}

struct ParentDirectoryRow: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.turn.up.left")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            Text("..")
                .font(.body)
                .fontWeight(.medium)

            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct BreadcrumbMenu: View {
    let currentPath: String
    let onNavigate: (String) -> Void

    private var pathComponents: [(name: String, path: String)] {
        var components: [(String, String)] = [("Root", "/")]

        if currentPath != "/" {
            let parts = currentPath.split(separator: "/").map(String.init)
            var accumulatedPath = ""

            for part in parts {
                accumulatedPath += "/\(part)"
                components.append((part, accumulatedPath))
            }
        }

        return components
    }

    var body: some View {
        Menu {
            ForEach(pathComponents, id: \.path) { component in
                Button(component.name) {
                    onNavigate(component.path)
                }
            }
        } label: {
            Image(systemName: "folder.badge.gearshape")
        }
    }
}

#Preview {
    NavigationStack {
        FileBrowserView(server: Server(name: "Test", host: "localhost", port: 8080))
    }
}
