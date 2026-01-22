import SwiftUI

struct CodeViewerView: View {
    let content: String
    let language: String?

    @State private var showLineNumbers = true

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                if showLineNumbers {
                    lineNumbersView
                }

                codeContentView
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Toggle(isOn: $showLineNumbers) {
                    Label("Line Numbers", systemImage: "list.number")
                }
            }
        }
    }

    private var lines: [String] {
        content.components(separatedBy: .newlines)
    }

    private var lineNumbersView: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                Text("\(index + 1)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 30, alignment: .trailing)
            }
        }
        .padding(.trailing, 8)
        .padding(.trailing, 8)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 1)
        }
    }

    private var codeContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line.isEmpty ? " " : line)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .padding(.leading, 8)
    }
}

#Preview {
    NavigationStack {
        CodeViewerView(
            content: """
            import SwiftUI

            struct ContentView: View {
                var body: some View {
                    Text("Hello, World!")
                }
            }

            #Preview {
                ContentView()
            }
            """,
            language: "swift"
        )
    }
}
