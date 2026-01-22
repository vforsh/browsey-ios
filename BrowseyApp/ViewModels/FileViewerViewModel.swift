import Foundation

@Observable
class FileViewerViewModel {
    let server: Server
    let file: FileItem

    private(set) var content: FileContent?
    private(set) var fileInfo: FileInfo?
    private(set) var isLoading = false
    private(set) var error: Error?

    private let apiClient = BrowseyAPIClient.shared

    var imageURL: URL {
        apiClient.getImageURL(server: server, path: file.absolutePath)
    }

    init(server: Server, file: FileItem) {
        self.server = server
        self.file = file
    }

    func loadContent() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            let fileContent = try await apiClient.viewFile(server: server, path: file.absolutePath)
            await MainActor.run {
                self.content = fileContent
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }

    func loadFileInfo() async {
        do {
            let info = try await apiClient.getFileInfo(server: server, path: file.absolutePath)
            await MainActor.run {
                self.fileInfo = info
            }
        } catch {
            print("Failed to load file info: \(error)")
        }
    }

    func downloadFile() async -> URL? {
        do {
            let data = try await apiClient.downloadFile(server: server, path: file.absolutePath)

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(file.name)
            try data.write(to: tempURL)
            return tempURL
        } catch {
            await MainActor.run {
                self.error = error
            }
            return nil
        }
    }
}
