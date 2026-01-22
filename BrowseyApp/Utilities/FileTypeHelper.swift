import SwiftUI

struct FileTypeHelper {
    static func icon(for item: FileItem) -> String {
        if item.isDirectory {
            return "folder.fill"
        }

        guard let ext = item.extension?.lowercased() else {
            return "doc.fill"
        }

        switch ext {
        // Images
        case "jpg", "jpeg", "png", "gif", "webp", "svg", "bmp", "ico", "tiff", "heic":
            return "photo.fill"

        // Videos
        case "mp4", "mov", "avi", "mkv", "webm", "m4v":
            return "film.fill"

        // Audio
        case "mp3", "wav", "flac", "aac", "ogg", "m4a":
            return "music.note"

        // Code
        case "swift", "ts", "tsx", "js", "jsx", "py", "rb", "go", "rs", "java", "kt", "c", "cpp", "h", "hpp", "cs", "php":
            return "chevron.left.forwardslash.chevron.right"

        // Markup & Config
        case "html", "htm", "xml", "json", "yaml", "yml", "toml":
            return "doc.text.fill"

        // Markdown
        case "md", "markdown":
            return "doc.richtext.fill"

        // Documents
        case "pdf":
            return "doc.fill"
        case "doc", "docx":
            return "doc.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        case "ppt", "pptx":
            return "rectangle.split.3x1.fill"

        // Archives
        case "zip", "tar", "gz", "rar", "7z":
            return "archivebox.fill"

        // Text
        case "txt", "log", "csv":
            return "doc.text.fill"

        // Fonts
        case "ttf", "otf", "woff", "woff2":
            return "textformat"

        default:
            return "doc.fill"
        }
    }

    static func iconColor(for item: FileItem) -> Color {
        if item.isDirectory {
            return .blue
        }

        guard let ext = item.extension?.lowercased() else {
            return .gray
        }

        switch ext {
        // Images
        case "jpg", "jpeg", "png", "gif", "webp", "svg", "bmp", "ico", "tiff", "heic":
            return .pink

        // Videos
        case "mp4", "mov", "avi", "mkv", "webm", "m4v":
            return .purple

        // Audio
        case "mp3", "wav", "flac", "aac", "ogg", "m4a":
            return .orange

        // Code
        case "swift":
            return .orange
        case "ts", "tsx":
            return .blue
        case "js", "jsx":
            return .yellow
        case "py":
            return .green
        case "go":
            return .cyan
        case "rs":
            return .orange
        case "java", "kt":
            return .red
        case "c", "cpp", "h", "hpp":
            return .blue
        case "cs":
            return .purple
        case "php":
            return .indigo
        case "rb":
            return .red

        // Markup & Config
        case "html", "htm":
            return .orange
        case "xml":
            return .orange
        case "json":
            return .yellow
        case "yaml", "yml":
            return .red
        case "toml":
            return .gray

        // Markdown
        case "md", "markdown":
            return .blue

        // Archives
        case "zip", "tar", "gz", "rar", "7z":
            return .brown

        default:
            return .gray
        }
    }

    static func isViewable(extension ext: String?) -> Bool {
        guard let ext = ext?.lowercased() else {
            return false
        }

        let viewableExtensions: Set<String> = [
            // Text
            "txt", "log", "csv", "md", "markdown",
            // Code
            "swift", "ts", "tsx", "js", "jsx", "py", "rb", "go", "rs", "java", "kt",
            "c", "cpp", "h", "hpp", "cs", "php", "sh", "bash", "zsh",
            // Markup & Config
            "html", "htm", "xml", "json", "yaml", "yml", "toml", "plist",
            "css", "scss", "less", "sql",
            // Images
            "jpg", "jpeg", "png", "gif", "webp", "svg", "bmp", "ico", "heic"
        ]

        return viewableExtensions.contains(ext)
    }
}
