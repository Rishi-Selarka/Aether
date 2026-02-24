import SwiftUI
import SwiftData

struct CodeView: View {
    let graph: ArchitectureGraph
    let selectedNodeID: String?
    let onSelectNode: (String?) -> Void
    let onDismiss: () -> Void

    private var generatedCode: String {
        CodeGenerator.generateCode(from: graph)
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                architecturePanel
                Divider()
                codePanel
            }
            .navigationTitle("Code View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: LayoutConstants.spacingS) {
                        Button { copyToClipboard() } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        Button { onDismiss() } label: {
                            Text("Done")
                        }
                    }
                }
            }
        }
    }

    private var architecturePanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LayoutConstants.spacingM) {
                Text("Architecture")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Color.archsysTextPrimary)

                let patterns = CodeGenerator.detectPatterns(in: graph)
                if !patterns.isEmpty {
                    Text("Patterns: \(patterns.map(\.displayName).joined(separator: ", "))")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.archsysTextSecondary)
                }

                ForEach(graph.allNodes) { node in
                    ArchitectureNodeRow(
                        node: node,
                        isSelected: selectedNodeID == node.id,
                        connections: graph.allConnections.filter { $0.sourceID == node.id || $0.targetID == node.id }
                    ) {
                        onSelectNode(selectedNodeID == node.id ? nil : node.id)
                    }
                }
            }
            .padding(LayoutConstants.spacingM)
        }
        .frame(minWidth: 200, idealWidth: 280)
        .background(Color.archsysBackground)
    }

    private var codePanel: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(generatedCode.components(separatedBy: "\n").enumerated()), id: \.offset) { index, line in
                        CodeLineView(
                            lineNumber: index + 1,
                            content: line,
                            isHighlighted: false
                        )
                        .id(index)
                    }
                }
                .padding(LayoutConstants.spacingM)
            }
        }
        .frame(minWidth: 300)
        .background(Color.archsysSurface)
    }

    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = generatedCode
        #endif
    }
}

struct ArchitectureNodeRow: View {
    let node: GraphNode
    let isSelected: Bool
    let connections: [GraphEdge]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LayoutConstants.spacingS) {
                Image(systemName: node.type.sfSymbol)
                    .foregroundStyle(node.type.accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(node.type.displayName)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.archsysTextPrimary)

                    if !connections.isEmpty {
                        Text("\(connections.count) connections")
                            .font(Typography.bodySmall)
                            .foregroundStyle(Color.archsysTextTertiary)
                    }
                }
                Spacer()
            }
            .padding(LayoutConstants.spacingS)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusS)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.archsysSurface)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CodeLineView: View {
    let lineNumber: Int
    let content: String
    let isHighlighted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: LayoutConstants.spacingM) {
            Text("\(lineNumber)")
                .font(Typography.code)
                .foregroundStyle(Color.archsysTextTertiary)
                .frame(width: 36, alignment: .trailing)

            syntaxHighlightedText
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .background(isHighlighted ? Color.accentColor.opacity(0.15) : .clear)
    }

    @ViewBuilder
    private var syntaxHighlightedText: some View {
        if let commentStart = content.range(of: "//")?.lowerBound {
            let codePart = String(content[..<commentStart])
            let commentPart = String(content[commentStart...])
            HStack(alignment: .top, spacing: 0) {
                Text(codePart)
                    .font(Typography.code)
                    .foregroundStyle(Color.archsysTextPrimary)
                Text(commentPart)
                    .font(Typography.code)
                    .foregroundStyle(Color.green)
            }
            .textSelection(.enabled)
        } else {
            Text(content.isEmpty ? " " : content)
                .font(Typography.code)
                .foregroundStyle(keywordColor(for: content))
                .textSelection(.enabled)
        }
    }

    private func keywordColor(for text: String) -> Color {
        Color.archsysTextPrimary
    }
}
