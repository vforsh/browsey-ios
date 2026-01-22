import Foundation

@Observable
class FileBrowserViewModel {
    let server: Server

    private(set) var currentPath: String
    private(set) var items: [FileItem] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    private let apiClient = BrowseyAPIClient.shared

    var currentDirectoryName: String {
        if currentPath == "/" {
            return server.displayName
        }
        return URL(fileURLWithPath: currentPath).lastPathComponent
    }

    var canGoUp: Bool {
        currentPath != "/"
    }

    var parentPath: String {
        let url = URL(fileURLWithPath: currentPath)
        let parent = url.deletingLastPathComponent().path
        return parent.isEmpty ? "/" : parent
    }

    var sortedItems: [FileItem] {
        items.sorted { item1, item2 in
            if item1.isDirectory != item2.isDirectory {
                return item1.isDirectory
            }
            return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
        }
    }

    init(server: Server, path: String = "/") {
        self.server = server
        self.currentPath = path
    }

    func loadDirectory() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            let listing = try await apiClient.listDirectory(server: server, path: currentPath)
            await MainActor.run {
                self.items = listing.items
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }

    func refresh() async {
        await loadDirectory()
    }

    func navigateTo(_ path: String) async {
        await MainActor.run {
            currentPath = path
        }
        await loadDirectory()
    }

    func goUp() async {
        await navigateTo(parentPath)
    }
}
