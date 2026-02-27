import SwiftUI

/// Text input field with send button for the chatbot.
struct ChatbotInputBar: View {
    @Binding var text: String
    let isEnabled: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask about system design...", text: $text, axis: .vertical)
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.archsysTextPrimary)
                .lineLimit(1...4)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit {
                    guard canSend else { return }
                    sendMessage()
                }
                .accessibilityLabel("Message input")
                .accessibilityHint("Type a system design question")

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(
                        canSend ? Color.homeAccent : Color.archsysTextTertiary
                    )
            }
            .disabled(!canSend)
            .accessibilityLabel("Send message")
            .archsysMinTouchTarget()
        }
        .padding(.horizontal, ChatbotConstants.inputPaddingH)
        .padding(.vertical, ChatbotConstants.inputPaddingV)
        .background {
            RoundedRectangle(cornerRadius: ChatbotConstants.inputCornerRadius)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: ChatbotConstants.inputCornerRadius)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var canSend: Bool {
        isEnabled && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendMessage() {
        guard canSend else { return }
        HapticManager.lightImpact()
        onSend()
    }
}
