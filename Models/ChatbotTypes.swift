import Foundation

// MARK: - Message Role

enum ChatMessageRole: String, Codable {
    case user
    case assistant
}

// MARK: - Chat Message

struct ChatMessage: Identifiable {
    let id: UUID
    let role: ChatMessageRole
    let content: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        role: ChatMessageRole,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - Suggested Question

struct SuggestedQuestion: Identifiable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

// MARK: - Chat Response State

enum ChatResponseState: Equatable {
    case idle
    case generating
    case typing(fullText: String, revealedCount: Int)
    case error(String)
}
