import SwiftUI

struct FileRowView: View {
    let item: FileItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: FileTypeHelper.icon(for: item))
                .font(.title2)
                .foregroundStyle(FileTypeHelper.iconColor(for: item))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if !item.isDirectory {
                        Text(SizeFormatter.format(item.size))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)
                    }

                    Text(SizeFormatter.formatDate(item.modified))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if item.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else if !FileTypeHelper.isViewable(extension: item.extension) {
                Image(systemName: "arrow.down.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        FileRowView(item: FileItem(
            name: "Documents",
            type: .directory,
            size: 0,
            modified: Date(),
            extension: nil,
            absolutePath: "/Documents"
        ))

        FileRowView(item: FileItem(
            name: "photo.jpg",
            type: .file,
            size: 2_500_000,
            modified: Date().addingTimeInterval(-3600),
            extension: "jpg",
            absolutePath: "/photo.jpg"
        ))

        FileRowView(item: FileItem(
            name: "main.swift",
            type: .file,
            size: 15_000,
            modified: Date().addingTimeInterval(-86400),
            extension: "swift",
            absolutePath: "/main.swift"
        ))

        FileRowView(item: FileItem(
            name: "archive.zip",
            type: .file,
            size: 50_000_000,
            modified: Date().addingTimeInterval(-604800),
            extension: "zip",
            absolutePath: "/archive.zip"
        ))
    }
}
