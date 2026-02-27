import SwiftUI

/// Renders a single chat message bubble.
/// User messages are right-aligned with accent color.
/// Assistant messages are left-aligned with glass material.
struct ChatbotMessageView: View {
    let message: ChatMessage
    let displayedText: String

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: contentAlignment, spacing: 6) {
                ForEach(
                    Array(parseSegments(from: displayedText).enumerated()),
                    id: \.offset
                ) { _, segment in
                    segmentView(segment)
                }
            }
            .padding(.horizontal, ChatbotConstants.messagePaddingH)
            .padding(.vertical, ChatbotConstants.messagePaddingV)
            .background(bubbleBackground)

            if message.role == .assistant { Spacer(minLength: 60) }
        }
        .frame(
            maxWidth: .infinity,
            alignment: message.role == .user ? .trailing : .leading
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(message.role == .user ? "You" : "Assistant"): \(displayedText)"
        )
    }

    // MARK: - Helpers

    private var contentAlignment: HorizontalAlignment {
        message.role == .user ? .trailing : .leading
    }

    @ViewBuilder
    private func segmentView(_ segment: TextSegment) -> some View {
        switch segment {
        case .text(let str):
            Text(str)
                .font(Typography.bodyMedium)
                .foregroundStyle(textColor)
                .multilineTextAlignment(
                    message.role == .user ? .trailing : .leading
                )

        case .code(let str):
            Text(str)
                .font(Typography.code)
                .foregroundStyle(Color.archsysTextPrimary)
                .padding(ChatbotConstants.codeBlockPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color.archsysSurface.opacity(0.8),
                    in: RoundedRectangle(
                        cornerRadius: ChatbotConstants.codeBlockCornerRadius
                    )
                )
        }
    }

    private var textColor: Color {
        message.role == .user ? .white : Color.archsysTextPrimary
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if message.role == .user {
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusM)
                .fill(Color.homeAccent)
        } else {
            Color.clear
        }
    }
}

// MARK: - Text Segment Parsing

private enum TextSegment {
    case text(String)
    case code(String)
}

/// Splits response text into plain text and code block segments.
private func parseSegments(from text: String) -> [TextSegment] {
    let pattern = "```(?:swift)?\\n?([\\s\\S]*?)```"
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return [.text(text)]
    }

    var segments: [TextSegment] = []
    var lastEnd = text.startIndex
    let nsRange = NSRange(text.startIndex..., in: text)
    let matches = regex.matches(in: text, range: nsRange)

    for match in matches {
        guard let codeRange = Range(match.range(at: 1), in: text),
              let fullRange = Range(match.range, in: text)
        else { continue }

        let before = String(text[lastEnd..<fullRange.lowerBound])
            .trimmingCharacters(in: .newlines)
        if !before.isEmpty {
            segments.append(.text(before))
        }

        let code = String(text[codeRange])
            .trimmingCharacters(in: .newlines)
        if !code.isEmpty {
            segments.append(.code(code))
        }

        lastEnd = fullRange.upperBound
    }

    let remaining = String(text[lastEnd...])
        .trimmingCharacters(in: .newlines)
    if !remaining.isEmpty {
        segments.append(.text(remaining))
    }

    return segments.isEmpty ? [.text(text)] : segments
}
