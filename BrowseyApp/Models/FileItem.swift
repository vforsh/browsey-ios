import Foundation

struct FileItem: Codable, Identifiable, Hashable {
    let name: String
    let type: FileType
    let size: Int64
    let modified: Date
    let `extension`: String?
    let absolutePath: String

    var id: String { absolutePath }

    var isDirectory: Bool {
        type == .directory
    }

    enum FileType: String, Codable {
        case file
        case directory
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case size
        case modified
        case `extension`
        case absolutePath
    }
}

struct DirectoryListing: Codable {
    let path: String
    let items: [FileItem]
}
