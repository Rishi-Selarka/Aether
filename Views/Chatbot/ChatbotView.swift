import SwiftUI

// MARK: - Chat State

/// Observable state manager for the chatbot conversation and typewriter animation.
@Observable
final class ChatState {
    private(set) var messages: [ChatMessage] = []
    private(set) var responseState: ChatResponseState = .idle
    private(set) var displayedBotText: String = ""
    private var typewriterTask: Task<Void, Never>?

    var isGenerating: Bool {
        if case .generating = responseState { return true }
        return false
    }

    var isTyping: Bool {
        if case .typing = responseState { return true }
        return false
    }

    var isBusy: Bool { isGenerating || isTyping }

    // MARK: - Send Message

    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        responseState = .generating
        displayedBotText = ""

        let historySnapshot = Array(messages)

        Task { @MainActor in
            let response = await Self.getResponse(
                userMessage: text,
                history: historySnapshot
            )

            let botMessage = ChatMessage(role: .assistant, content: response)
            messages.append(botMessage)
            await startTypewriter(fullText: response)
        }
    }

    // MARK: - Typewriter Animation

    @MainActor
    private func startTypewriter(fullText: String) async {
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        if reduceMotion {
            displayedBotText = fullText
            responseState = .idle
            return
        }

        displayedBotText = ""
        responseState = .typing(fullText: fullText, revealedCount: 0)

        typewriterTask?.cancel()
        typewriterTask = Task { @MainActor in
            let characters = Array(fullText)

            for i in characters.indices {
                guard !Task.isCancelled else { break }

                displayedBotText = String(characters[...i])
                responseState = .typing(
                    fullText: fullText,
                    revealedCount: i + 1
                )

                let char = characters[i]
                let interval = (char == " " || char.isPunctuation)
                    ? ChatbotConstants.typewriterFastInterval
                    : ChatbotConstants.typewriterBaseInterval

                try? await Task.sleep(for: .seconds(interval))
            }

            displayedBotText = fullText
            responseState = .idle
        }
    }

    /// Immediately reveals full text, cancelling the typewriter animation.
    func skipTypewriter() {
        typewriterTask?.cancel()
        typewriterTask = nil
        if case .typing(let fullText, _) = responseState {
            displayedBotText = fullText
        }
        responseState = .idle
    }

    // MARK: - AI Integration

    private static func getResponse(
        userMessage: String,
        history: [ChatMessage]
    ) async -> String {
        // Exclude the user message we just appended (it's the last element)
        let priorHistory = Array(history.dropLast())

        guard #available(iOS 26, *) else {
            return ChatbotFallback.findResponse(for: userMessage)
        }

        let service = ChatbotService()
        return await service.respond(
            to: userMessage,
            conversationHistory: priorHistory
        )
    }
}

// MARK: - Chatbot View

struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var chatState = ChatState()
    @State private var inputText = ""

    private let suggestedQuestions: [SuggestedQuestion] = [
        SuggestedQuestion(text: "What is MVVM and how does it work in SwiftUI?"),
        SuggestedQuestion(text: "How should I structure a network layer?"),
        SuggestedQuestion(text: "Explain the Repository pattern"),
        SuggestedQuestion(text: "What's the difference between MVC and MVVM?"),
        SuggestedQuestion(text: "How does dependency injection improve testability?"),
        SuggestedQuestion(text: "What is a Circuit Breaker pattern?")
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.3)

            if chatState.messages.isEmpty {
                emptyState
            } else {
                messageList
            }

            ChatbotInputBar(
                text: $inputText,
                isEnabled: !chatState.isBusy,
                onSend: sendCurrentMessage
            )
        }
        .background(Color.archsysBackground)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("System Design Assistant")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)

            HStack {
                Button {
                    HapticManager.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.archsysTextSecondary)
                        .frame(
                            width: ChatbotConstants.closeButtonSize,
                            height: ChatbotConstants.closeButtonSize
                        )
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Close chat")

                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, ChatbotConstants.headerPaddingV)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Image(systemName: "bubble.left.and.text.bubble.right")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.archsysTextTertiary)

                VStack(spacing: 8) {
                    Text("Ask me anything about")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.archsysTextSecondary)
                    Text("System Design & Architecture")
                        .font(Typography.headingMedium)
                        .foregroundStyle(Color.archsysTextPrimary)
                }

                suggestedQuestionsGrid

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var suggestedQuestionsGrid: some View {
        VStack(spacing: 10) {
            ForEach(suggestedQuestions) { question in
                Button {
                    HapticManager.lightImpact()
                    inputText = question.text
                    sendCurrentMessage()
                } label: {
                    Text(question.text)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.archsysTextPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(
                                cornerRadius: ChatbotConstants.suggestedCornerRadius
                            )
                        )
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: ChatbotConstants.suggestedCornerRadius
                            )
                            .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                        }
                }
                .accessibilityLabel("Ask: \(question.text)")
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: ChatbotConstants.messageSpacing) {
                    ForEach(chatState.messages) { message in
                        let isLastAssistant =
                            message.id == chatState.messages.last?.id
                            && message.role == .assistant

                        let displayText = isLastAssistant && chatState.isBusy
                            ? chatState.displayedBotText
                            : message.content

                        ChatbotMessageView(
                            message: message,
                            displayedText: displayText
                        )
                        .id(message.id)
                        .onTapGesture {
                            if isLastAssistant && chatState.isTyping {
                                chatState.skipTypewriter()
                            }
                        }
                    }

                    if chatState.isGenerating {
                        HStack {
                            TypingIndicator()
                                .padding(.leading, 4)
                            Spacer()
                        }
                        .id("loading")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: chatState.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chatState.displayedBotText) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Actions

    private func sendCurrentMessage() {
        let trimmed = inputText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        chatState.sendMessage(trimmed)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if chatState.isGenerating {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo("loading", anchor: .bottom)
            }
        } else if let lastID = chatState.messages.last?.id {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
}

// MARK: - Typing Indicator

/// Three bouncing dots shown while waiting for Foundation Models response.
private struct TypingIndicator: View {
    @State private var animateFirst = false
    @State private var animateSecond = false
    @State private var animateThird = false

    var body: some View {
        HStack(spacing: 5) {
            dot(animating: animateFirst)
            dot(animating: animateSecond)
            dot(animating: animateThird)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
        }
        .onAppear { startAnimation() }
        .accessibilityLabel("Generating response")
    }

    private func dot(animating: Bool) -> some View {
        Circle()
            .fill(Color.archsysTextTertiary)
            .frame(width: 8, height: 8)
            .offset(y: animating ? -4 : 0)
    }

    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: 0.4)
            .repeatForever(autoreverses: true)
        ) {
            animateFirst = true
        }
        withAnimation(
            .easeInOut(duration: 0.4)
            .repeatForever(autoreverses: true)
            .delay(0.15)
        ) {
            animateSecond = true
        }
        withAnimation(
            .easeInOut(duration: 0.4)
            .repeatForever(autoreverses: true)
            .delay(0.3)
        ) {
            animateThird = true
        }
    }
}
