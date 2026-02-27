import Foundation
import FoundationModels

// MARK: - Chatbot Service (iOS 26+)

@available(iOS 26, *)
struct ChatbotService {

    private let maxHistoryMessages = 10

    func respond(
        to userMessage: String,
        conversationHistory: [ChatMessage]
    ) async -> String {
        guard SystemLanguageModel.default.isAvailable else {
            return ChatbotFallback.findResponse(for: userMessage)
        }

        do {
            let session = LanguageModelSession(instructions: Self.systemPrompt)

            let prompt = buildPrompt(
                userMessage: userMessage,
                history: conversationHistory
            )

            let response = try await session.respond(to: prompt)
            let text = response.content
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return text.isEmpty
                ? ChatbotFallback.findResponse(for: userMessage)
                : text
        } catch {
            return ChatbotFallback.findResponse(for: userMessage)
        }
    }

    // MARK: - System Prompt

    private static let systemPrompt: String = """
        You are an expert iOS system design and mobile architecture tutor inside \
        an educational iPad app called City Architect. The app teaches system design \
        through a city-building metaphor with 5 tiers of increasing complexity: \
        Tier 1 (Local Storage), Tier 2 (Networking), Tier 3 (Performance), \
        Tier 4 (Resilience), Tier 5 (Advanced/ML).

        Your deep knowledge covers:
        - Architecture patterns: MVC, MVVM, MVP, VIPER, Clean Architecture, TCA, \
          Redux, Flux
        - iOS components: UI Layer, ViewModel, Repository, API Client, Database, \
          Cache (memory, network, image), Background Worker, Circuit Breaker, \
          Retry Handler, Fallback Provider, Health Monitor, ML Model, WebSocket, \
          Event Bus, State Machine
        - SwiftUI and UIKit: view lifecycle, state management (@State, @StateObject, \
          @ObservedObject, @EnvironmentObject, @Observable, @Binding), navigation, \
          layout system, gestures, animations
        - Swift concurrency: async/await, structured concurrency, TaskGroup, actors, \
          Sendable, MainActor, AsyncSequence, AsyncStream
        - Networking: URLSession, REST API design, GraphQL, WebSocket, HTTP caching, \
          certificate pinning, retry strategies
        - Persistence: SwiftData, Core Data, UserDefaults, Keychain, File Manager, \
          SQLite, Realm
        - Performance: lazy loading, pagination, image optimization, memory management, \
          Instruments profiling, reducing app launch time
        - Resilience patterns: circuit breaker, retry with exponential backoff, \
          fallback, bulkhead, health monitoring, graceful degradation
        - Testing: XCTest, XCUITest, dependency injection for testability, mocking \
          with protocols, test doubles, integration testing
        - Design principles: SOLID, DRY, KISS, separation of concerns, \
          composition over inheritance, protocol-oriented programming

        Rules:
        - Be concise and educational. 2-6 sentences for simple questions, up to 3 \
          short paragraphs for complex topics.
        - Include Swift code examples when they help explain a concept, using \
          markdown code blocks.
        - Always relate answers to mobile and iOS development context.
        - For architecture questions, explain trade-offs and when to use each pattern.
        - Never use emojis in responses.
        - If asked something outside system design or software architecture, politely \
          say: "I specialise in system design and mobile architecture. Try asking \
          about patterns like MVVM, caching strategies, or networking layers."
        """

    // MARK: - Prompt Builder

    private func buildPrompt(
        userMessage: String,
        history: [ChatMessage]
    ) -> String {
        let recentHistory = history.suffix(maxHistoryMessages)
        var prompt = ""

        if !recentHistory.isEmpty {
            prompt += "Previous conversation:\n"
            for message in recentHistory {
                let role = message.role == .user ? "Student" : "Tutor"
                prompt += "\(role): \(message.content)\n"
            }
            prompt += "\n"
        }

        prompt += "Student: \(userMessage)"
        return prompt
    }
}

// MARK: - Fallback (All iOS Versions)

enum ChatbotFallback {

    /// Used when query is clearly outside system design (e.g. politics, celebrities).
    private static let offTopicResponse = """
        I specialise in system design and mobile architecture. Try asking about \
        patterns like MVVM, Repository, caching strategies, or networking layers.
        """

    static func findResponse(for query: String) -> String {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return genericResponse }

        let lowered = trimmed.lowercased()

        if isOffTopic(lowered) {
            return offTopicResponse
        }

        for entry in responses {
            if entry.keywords.contains(where: { lowered.contains($0) }) {
                return entry.answer
            }
        }

        return genericResponse
    }

    /// Detects queries outside system design / software architecture.
    private static func isOffTopic(_ lowered: String) -> Bool {
        let offTopicPatterns = [
            "who is", "who was", "who are",
            "what is a person", "president", "trump", "biden", "obama",
            "capital of", "population of", "country",
            "weather", "sports", "movie", "song", "celebrity",
            "recipe", "cooking", "food"
        ]
        return offTopicPatterns.contains { lowered.contains($0) }
    }

    // MARK: - Generic Response

    private static let genericResponse = """
        That is a great question about system design. In mobile architecture, \
        the key principles are separation of concerns, dependency injection, \
        and choosing the right pattern for your app's complexity level. \
        The most common starting point is MVVM with a Repository layer \
        for data access. Try asking about specific patterns like MVVM, \
        Repository, caching strategies, or networking layers.
        """

    // MARK: - Curated Responses

    private struct FallbackEntry {
        let keywords: [String]
        let answer: String
    }

    private static let responses: [FallbackEntry] = [
        FallbackEntry(
            keywords: ["difference between mvvm and mvc", "mvvm vs mvc", "mvc vs mvvm", "difference between mvc and mvvm", "compare mvvm mvc", "mvvm and mvc"],
            answer: """
                MVC: The Controller mediates between Model and View. In UIKit, UIViewController \
                often becomes a "Massive View Controller" because it handles UI logic, business \
                logic, data formatting, and navigation all in one place. The View talks directly \
                to the Controller, which updates the Model and the View.

                MVVM: The ViewModel sits between View and Model. The View observes the ViewModel \
                (via @StateObject or @ObservedObject in SwiftUI) and never touches the Model. \
                The ViewModel transforms Model data for display and exposes @Published properties. \
                Key difference: the ViewModel has no reference to the View — it is independently \
                testable and SwiftUI-agnostic. MVVM avoids the Massive View Controller problem \
                by moving logic out of the view layer. SwiftUI's declarative style fits MVVM \
                naturally; MVC was designed for UIKit's imperative flow.
                """
        ),
        FallbackEntry(
            keywords: ["mvvm", "model-view-viewmodel", "viewmodel", "view model"],
            answer: """
                MVVM (Model-View-ViewModel) separates UI from business logic. \
                The View observes the ViewModel via @StateObject or @ObservedObject \
                in SwiftUI, which transforms Model data for display. The ViewModel \
                never imports SwiftUI — it exposes @Published properties the View \
                binds to. This makes the ViewModel independently testable without \
                any UI framework dependency. In SwiftUI, the View is declarative \
                and rebuilds automatically when ViewModel state changes.
                """
        ),
        FallbackEntry(
            keywords: ["mvc", "model-view-controller"],
            answer: """
                MVC is Apple's traditional pattern where the Controller mediates \
                between Model and View. In UIKit, UIViewController often becomes a \
                "Massive View Controller" because it handles UI logic, business logic, \
                navigation, and data formatting. MVVM and VIPER were created to address \
                this by extracting responsibilities into separate objects. SwiftUI's \
                declarative nature naturally pushes you toward MVVM instead.
                """
        ),
        FallbackEntry(
            keywords: ["repository", "repository pattern", "data layer"],
            answer: """
                The Repository pattern provides a single source of truth by abstracting \
                data sources behind a clean interface. It decides whether to fetch from \
                the network, local database, or cache — the ViewModel doesn't need to \
                know. The ViewModel depends on a RepositoryProtocol, never on concrete \
                network or database types directly. This makes switching data sources \
                or adding caching layers trivial without touching business logic.
                """
        ),
        FallbackEntry(
            keywords: ["network", "api", "networking", "urlsession", "rest"],
            answer: """
                A well-structured network layer separates request building, execution, \
                and response parsing. Use URLSession with async/await for clean async code. \
                Define an APIClientProtocol so ViewModels and Repositories can be tested \
                with mock network responses. Consider adding a NetworkCache layer to avoid \
                redundant requests, and implement retry logic with exponential backoff for \
                transient failures.
                """
        ),
        FallbackEntry(
            keywords: ["cache", "caching", "nscache"],
            answer: """
                Mobile apps typically use a multi-level caching strategy: an in-memory \
                cache (NSCache or a dictionary) for fast access, a disk cache for \
                persistence across launches, and an HTTP cache for network responses. \
                The key decision is cache invalidation — time-based expiry, event-driven \
                invalidation, or LRU eviction. NSCache automatically evicts entries under \
                memory pressure, making it ideal for the in-memory layer.
                """
        ),
        FallbackEntry(
            keywords: ["circuit breaker", "circuitbreaker", "resilience", "fault tolerance"],
            answer: """
                A Circuit Breaker prevents cascading failures by monitoring error rates. \
                It has three states: Closed (normal operation), Open (requests blocked, \
                returns fallback), and Half-Open (allows one test request). When failures \
                exceed a threshold, it opens the circuit and returns a fallback response \
                instead of making more failing requests. After a cooldown period, it \
                allows a test request through to check if the service has recovered.
                """
        ),
        FallbackEntry(
            keywords: ["dependency injection", " di ", "inject", "protocol"],
            answer: """
                Dependency injection means passing dependencies into an object rather \
                than having it create them internally. In Swift, use protocol-typed \
                constructor parameters: init(repository: RepositoryProtocol). This \
                decouples components and makes testing trivial — just pass a mock \
                conforming to the same protocol. In SwiftUI, @EnvironmentObject \
                serves as a form of DI for the view layer, while constructor injection \
                is preferred for ViewModels and services.
                """
        ),
        FallbackEntry(
            keywords: ["clean architecture", "viper", "layers", "onion"],
            answer: """
                Clean Architecture organises code into concentric layers: Entities \
                (domain models), Use Cases (business rules), Interface Adapters \
                (ViewModels, presenters), and Frameworks (UI, database). Dependencies \
                point inward — inner layers never know about outer layers. VIPER is a \
                mobile-specific variant with View, Interactor, Presenter, Entity, and \
                Router. Both patterns excel in large teams but add overhead for smaller \
                projects where MVVM may be sufficient.
                """
        ),
        FallbackEntry(
            keywords: ["swiftui", "state", "@state", "@binding", "@observable", "stateobject"],
            answer: """
                SwiftUI state management has clear ownership rules: @State for \
                view-local values, @StateObject to create and own an ObservableObject, \
                @ObservedObject for passed-in objects you don't own, and \
                @EnvironmentObject for dependency injection across the view hierarchy. \
                In iOS 17+, the @Observable macro simplifies this by making any class \
                observable without ObservableObject conformance, and @Bindable replaces \
                @ObservedObject for these types.
                """
        ),
        FallbackEntry(
            keywords: ["concurrency", "async", "await", "actor", "sendable", "task"],
            answer: """
                Swift's structured concurrency uses async/await for sequential async \
                code, TaskGroup for parallel work, and actors to protect shared mutable \
                state from data races. Mark UI-updating code with @MainActor to ensure \
                it runs on the main thread. Sendable conformance ensures values can \
                safely cross concurrency boundaries. Prefer structured concurrency \
                (async let, TaskGroup) over unstructured Task {} blocks for better \
                cancellation and error propagation.
                """
        ),
        FallbackEntry(
            keywords: ["solid", "design principle", "single responsibility", "open closed"],
            answer: """
                SOLID principles guide maintainable software design. Single \
                Responsibility: each class has one reason to change. Open/Closed: \
                open for extension, closed for modification — use protocols and \
                composition. Liskov Substitution: subtypes must be substitutable for \
                their base types. Interface Segregation: prefer small, focused protocols \
                over large ones. Dependency Inversion: depend on abstractions (protocols), \
                not concrete types. These principles naturally lead to testable, \
                modular mobile architectures.
                """
        ),
        FallbackEntry(
            keywords: ["swiftdata", "core data", "persistence", "database", "storage"],
            answer: """
                SwiftData (iOS 17+) is Apple's modern persistence framework that \
                replaces Core Data's boilerplate with Swift macros. Use @Model to \
                define entities, ModelContainer for the storage stack, and @Query for \
                reactive fetches in SwiftUI views. For complex queries, use \
                FetchDescriptor with predicates and sort descriptors. Keep your \
                SwiftData models in a dedicated layer and access them through a \
                repository or data manager protocol to maintain testability.
                """
        ),
        FallbackEntry(
            keywords: ["instagram", "design an app", "build an app", "how to design", "how to build", "app architecture", "social app"],
            answer: """
                To design an app like Instagram at the system level, start with \
                MVVM and a Repository layer. The feed needs an Image Cache for \
                photos, a Repository that combines network + local cache, and \
                pagination for infinite scroll. Use a Background Worker for \
                prefetching and SwiftData or Core Data for offline support. \
                For real-time features (likes, comments), add a WebSocket or \
                polling layer. Break the architecture into: UI → ViewModel → \
                Repository → API/Cache → Database.
                """
        )
    ]
}
