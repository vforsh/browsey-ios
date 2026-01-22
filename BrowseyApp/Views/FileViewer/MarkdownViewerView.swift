import SwiftUI

struct MarkdownViewerView: View {
    let content: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(parseMarkdown().enumerated()), id: \.offset) { _, element in
                    renderElement(element)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func parseMarkdown() -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        let lines = content.components(separatedBy: .newlines)
        var codeBlock: [String] = []
        var inCodeBlock = false
        var codeLanguage: String?

        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    elements.append(.codeBlock(codeBlock.joined(separator: "\n"), language: codeLanguage))
                    codeBlock = []
                    inCodeBlock = false
                    codeLanguage = nil
                } else {
                    inCodeBlock = true
                    codeLanguage = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    if codeLanguage?.isEmpty == true { codeLanguage = nil }
                }
                continue
            }

            if inCodeBlock {
                codeBlock.append(line)
                continue
            }

            if line.hasPrefix("# ") {
                elements.append(.heading1(String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                elements.append(.heading2(String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                elements.append(.heading3(String(line.dropFirst(4))))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                elements.append(.listItem(String(line.dropFirst(2))))
            } else if line.hasPrefix("> ") {
                elements.append(.quote(String(line.dropFirst(2))))
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                elements.append(.empty)
            } else {
                elements.append(.paragraph(line))
            }
        }

        return elements
    }

    @ViewBuilder
    private func renderElement(_ element: MarkdownElement) -> some View {
        switch element {
        case .heading1(let text):
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)

        case .heading2(let text):
            Text(text)
                .font(.title)
                .fontWeight(.bold)

        case .heading3(let text):
            Text(text)
                .font(.title2)
                .fontWeight(.semibold)

        case .paragraph(let text):
            Text(renderInlineMarkdown(text))
                .font(.body)

        case .listItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                Text(renderInlineMarkdown(text))
            }
            .font(.body)

        case .quote(let text):
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: 4)

                Text(text)
                    .font(.body)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

        case .codeBlock(let code, _):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(8)

        case .empty:
            Spacer()
                .frame(height: 8)
        }
    }

    private func renderInlineMarkdown(_ text: String) -> AttributedString {
        var result = AttributedString(text)

        // Bold
        if let boldRange = text.range(of: "\\*\\*(.+?)\\*\\*", options: .regularExpression) {
            let content = String(text[boldRange]).replacingOccurrences(of: "**", with: "")
            if let attrRange = result.range(of: String(text[boldRange])) {
                result.replaceSubrange(attrRange, with: AttributedString(content))
            }
        }

        // Inline code
        if let codeRange = text.range(of: "`(.+?)`", options: .regularExpression) {
            let content = String(text[codeRange]).replacingOccurrences(of: "`", with: "")
            if let attrRange = result.range(of: String(text[codeRange])) {
                var codeAttr = AttributedString(content)
                codeAttr.font = .system(.body, design: .monospaced)
                codeAttr.backgroundColor = Color(.secondarySystemGroupedBackground)
                result.replaceSubrange(attrRange, with: codeAttr)
            }
        }

        return result
    }
}

enum MarkdownElement {
    case heading1(String)
    case heading2(String)
    case heading3(String)
    case paragraph(String)
    case listItem(String)
    case quote(String)
    case codeBlock(String, language: String?)
    case empty
}

#Preview {
    MarkdownViewerView(content: """
    # Heading 1

    This is a paragraph with **bold** and `code`.

    ## Heading 2

    - List item 1
    - List item 2

    > This is a quote

    ```swift
    let x = 42
    print(x)
    ```
    """)
}
