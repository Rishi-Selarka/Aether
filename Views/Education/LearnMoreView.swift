import SwiftUI

struct LearnMoreView: View {
    let nodeType: NodeType
    @Environment(\.dismiss) private var dismiss

    private var content: LearnMoreContent {
        LearnMoreDatabase.content(for: nodeType)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutConstants.spacingL) {
                    headerSection
                    whatItDoesSection
                    whyItMattersSection
                    if let code = content.codeExample {
                        codeExampleSection(code)
                    }
                    if !content.commonMistakes.isEmpty {
                        commonMistakesSection
                    }
                    if !content.relatedTypes.isEmpty {
                        relatedComponentsSection
                    }
                }
                .padding(LayoutConstants.spacingM)
            }
            .background(Color.archsysBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: LayoutConstants.spacingM) {
            Image(systemName: nodeType.sfSymbol)
                .font(.system(size: 48))
                .foregroundStyle(nodeType.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(nodeType.displayName)
                    .font(Typography.headingMedium)
                    .foregroundStyle(Color.archsysTextPrimary)
                Text("Tier \(nodeType.tierLevel) • \(content.category)")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextSecondary)
            }
            Spacer()
        }
        .padding(LayoutConstants.spacingM)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
    }

    private var whatItDoesSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("What It Does")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            Text(content.whatItDoes)
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.archsysTextSecondary)
        }
    }

    private var whyItMattersSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("Why It Matters")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            Text(content.whyItMatters)
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.archsysTextSecondary)
        }
    }

    private func codeExampleSection(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("Code Example")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            Text(code)
                .font(Typography.code)
                .foregroundStyle(Color.archsysTextSecondary)
                .padding(LayoutConstants.spacingM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.archsysSurface)
                .cornerRadius(LayoutConstants.cornerRadiusS)
        }
    }

    private var commonMistakesSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("Common Mistakes")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            ForEach(content.commonMistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: LayoutConstants.spacingS) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(mistake)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.archsysTextSecondary)
                }
            }
        }
    }

    private var relatedComponentsSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("Related Components")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            Text(content.relatedTypes.map { $0.displayName }.joined(separator: ", "))
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.archsysTextSecondary)
        }
    }
}

struct LearnMoreContent {
    let whatItDoes: String
    let whyItMatters: String
    let codeExample: String?
    let commonMistakes: [String]
    let relatedTypes: [NodeType]
    let category: String

    init(whatItDoes: String, whyItMatters: String, codeExample: String? = nil,
         commonMistakes: [String] = [], relatedTypes: [NodeType], category: String) {
        self.whatItDoes = whatItDoes
        self.whyItMatters = whyItMatters
        self.codeExample = codeExample
        self.commonMistakes = commonMistakes
        self.relatedTypes = relatedTypes
        self.category = category
    }
}

enum LearnMoreDatabase {
    static func content(for type: NodeType) -> LearnMoreContent {
        switch type {
        case .ui:
            return LearnMoreContent(
                whatItDoes: "The UI Layer displays data and captures user input. It should only communicate with ViewModels.",
                whyItMatters: "Keeping UI separate makes it testable and easy to change design without touching business logic.",
                codeExample: "struct ContentView: View {\n    var body: some View {\n        List(items) { item in\n            Text(item.name)\n        }\n    }\n}",
                commonMistakes: ["Talking directly to Database or API", "Putting business logic in views"],
                relatedTypes: [.viewModel],
                category: "Display"
            )
        case .viewModel:
            return LearnMoreContent(
                whatItDoes: "Prepares data for the UI and handles user actions. Bridges the UI and data layer.",
                whyItMatters: "ViewModels keep views simple and enable unit testing without UI.",
                codeExample: "@Observable\nclass FeedViewModel {\n    var items: [Item] = []\n    func load() async { }\n}",
                commonMistakes: ["Putting UI code in ViewModel", "Too much logic in one ViewModel"],
                relatedTypes: [.ui, .database, .repository],
                category: "Logic"
            )
        case .database:
            return LearnMoreContent(
                whatItDoes: "Local persistence using SwiftData, Core Data, or SQLite. Stores data for offline access.",
                whyItMatters: "Apps need to work offline. Database enables fast local reads and writes.",
                codeExample: "@Model\nclass Item {\n    var id: UUID\n    var title: String\n}",
                commonMistakes: ["UI accessing Database directly", "Blocking main thread"],
                relatedTypes: [.repository, .viewModel],
                category: "Persistence"
            )
        case .api:
            return LearnMoreContent(
                whatItDoes: "Fetches data from remote servers via HTTP. Handles requests, JSON parsing, and errors.",
                whyItMatters: "Most apps need network data. A dedicated API layer keeps networking code isolated.",
                codeExample: "let (data, _) = try await\n    URLSession.shared.data(from: url)",
                commonMistakes: ["No error handling", "Blocking UI thread"],
                relatedTypes: [.repository, .networkCache],
                category: "Network"
            )
        case .repository:
            return LearnMoreContent(
                whatItDoes: "Single source of truth for data. Decides whether to use cache, API, or local storage.",
                whyItMatters: "Abstractions let you swap implementations. Switch from API to mock for testing.",
                codeExample: "protocol UserRepository {\n    func fetch() async throws -> [User]\n}",
                commonMistakes: ["Skipping abstraction", "Repository doing too much"],
                relatedTypes: [.api, .database, .viewModel],
                category: "Abstraction"
            )
        case .networkCache:
            return LearnMoreContent(
                whatItDoes: "Caches API responses to reduce network calls and speed up repeated fetches.",
                whyItMatters: "Network is slow. Caching makes apps feel instant on repeat visits.",
                commonMistakes: ["No cache invalidation", "Stale data"],
                relatedTypes: [.api, .repository],
                category: "Performance"
            )
        case .memoryCache:
            return LearnMoreContent(
                whatItDoes: "In-memory cache for fast access. Good for frequently used data.",
                whyItMatters: "Memory access is faster than disk or network. Use for hot data.",
                commonMistakes: ["Unbounded growth", "Not clearing on memory warning"],
                relatedTypes: [.database, .repository],
                category: "Performance"
            )
        case .backgroundWorker:
            return LearnMoreContent(
                whatItDoes: "Runs heavy tasks off the main thread. Keeps UI responsive.",
                whyItMatters: "Main thread must stay free for UI. Heavy work blocks animations.",
                codeExample: "Task.detached(priority: .userInitiated) {\n    await processImages()\n}",
                commonMistakes: ["Updating UI from background", "Too many concurrent tasks"],
                relatedTypes: [.database, .api],
                category: "Performance"
            )
        case .imageCache:
            return LearnMoreContent(
                whatItDoes: "Caches images in memory and optionally on disk.",
                whyItMatters: "Image loading is expensive. Cache avoids repeated downloads.",
                commonMistakes: ["No memory limits", "Blocking main thread"],
                relatedTypes: [.database],
                category: "Performance"
            )
        case .lazyLoader:
            return LearnMoreContent(
                whatItDoes: "Loads data only when needed. Saves memory and startup time.",
                whyItMatters: "Loading everything up front is slow. Lazy loading improves perceived performance.",
                commonMistakes: ["Loading too early", "N+1 query problem"],
                relatedTypes: [.database, .api],
                category: "Performance"
            )
        case .circuitBreaker:
            return LearnMoreContent(
                whatItDoes: "Stops calling a failing service. Prevents cascade failures.",
                whyItMatters: "Repeated calls to a down service waste resources. Circuit breaker fails fast.",
                codeExample: "if circuit.isOpen {\n    return fallbackValue\n}",
                commonMistakes: ["Never closing circuit", "Wrong threshold"],
                relatedTypes: [.api, .fallback],
                category: "Resilience"
            )
        case .retryHandler:
            return LearnMoreContent(
                whatItDoes: "Retries failed requests with exponential backoff.",
                whyItMatters: "Transient failures are common. Retries often succeed.",
                commonMistakes: ["Retrying indefinitely", "No max attempts"],
                relatedTypes: [.api],
                category: "Resilience"
            )
        case .fallback:
            return LearnMoreContent(
                whatItDoes: "Provides alternative data when primary source fails.",
                whyItMatters: "Users prefer cached data over errors. Graceful degradation improves UX.",
                commonMistakes: ["Stale fallback data", "No fallback for critical path"],
                relatedTypes: [.database, .memoryCache],
                category: "Resilience"
            )
        case .healthMonitor:
            return LearnMoreContent(
                whatItDoes: "Tracks service health and reports issues.",
                whyItMatters: "Proactive monitoring helps detect and fix issues before users complain.",
                commonMistakes: ["Ignoring health signals", "No alerting"],
                relatedTypes: [.api, .database],
                category: "Resilience"
            )
        case .mlModel:
            return LearnMoreContent(
                whatItDoes: "Runs machine learning inference locally or remotely.",
                whyItMatters: "ML enables features like image recognition, translation, and recommendations.",
                codeExample: "let result = try await\n    mlModel.prediction(input: image)",
                commonMistakes: ["Blocking main thread", "No model versioning"],
                relatedTypes: [.database],
                category: "Intelligence"
            )
        case .websocket:
            return LearnMoreContent(
                whatItDoes: "Real-time bidirectional communication. Keeps connection open.",
                whyItMatters: "Chat, live updates, and collaboration need real-time data.",
                commonMistakes: ["Not handling reconnection", "Sending too frequently"],
                relatedTypes: [.eventBus],
                category: "Real-time"
            )
        case .eventBus:
            return LearnMoreContent(
                whatItDoes: "Broadcasts events to subscribers. Decouples components.",
                whyItMatters: "Components can react without knowing each other. Loose coupling.",
                codeExample: "EventBus.shared.publish(.dataUpdated)",
                commonMistakes: ["Overuse leads to spaghetti", "No typed events"],
                relatedTypes: [.viewModel, .websocket],
                category: "Messaging"
            )
        case .stateMachine:
            return LearnMoreContent(
                whatItDoes: "Manages discrete states and valid transitions.",
                whyItMatters: "Complex flows (checkout, onboarding) need clear state rules.",
                commonMistakes: ["Invalid transitions", "Missing states"],
                relatedTypes: [.viewModel],
                category: "Flow"
            )
        }
    }
}
