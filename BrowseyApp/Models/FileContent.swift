import Foundation

struct FileContent: Codable {
    let type: ContentType
    let content: String?
    let language: String?
    let mimeType: String?
    let dimensions: ImageDimensions?

    enum ContentType: String, Codable {
        case text
        case markdown
        case image
        case binary
    }
}

struct ImageDimensions: Codable {
    let width: Int
    let height: Int
}

struct FileInfo: Codable {
    let name: String
    let type: String
    let size: Int64
    let modified: Date
    let created: Date?
    let absolutePath: String
}
