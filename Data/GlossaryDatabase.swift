import Foundation
import SwiftUI

enum GlossaryDatabase {
    static let allTerms: [GlossaryTerm] = [
        // Architecture Patterns (7)
        GlossaryTerm(term: "MVVM", definition: "Model-View-ViewModel separates UI from business logic. The View displays data, the ViewModel prepares it, and the Model holds the data.", category: .architecturePatterns, relatedNodeTypes: [.ui, .viewModel, .database], codeExample: "@Observable\nclass ViewModel {\n    var items: [Item] = []\n}", realWorldApps: ["Instagram", "Twitter"], sfSymbol: "rectangle.stack"),
        GlossaryTerm(term: "Repository Pattern", definition: "Abstracts data sources. The app talks to a Repository interface; the Repository decides whether to fetch from API, cache, or local DB.", category: .architecturePatterns, relatedNodeTypes: [.repository, .api, .database], codeExample: "protocol UserRepository {\n    func fetchUsers() async throws -> [User]\n}", realWorldApps: ["Netflix", "Spotify"], sfSymbol: "folder.fill"),
        GlossaryTerm(term: "Clean Architecture", definition: "Layers of abstractions with dependencies pointing inward. Business rules don't depend on UI, database, or frameworks. Domain → UseCases → Repositories.", category: .architecturePatterns, relatedNodeTypes: [.repository, .viewModel], codeExample: "Domain → UseCases → Repositories", realWorldApps: ["Banking apps"], sfSymbol: "square.stack.3d.up"),
        GlossaryTerm(term: "MVC", definition: "Model-View-Controller: Model holds data, View displays it, Controller handles user input. Simpler than MVVM but can lead to massive view controllers.", category: .architecturePatterns, relatedNodeTypes: [.ui, .database], realWorldApps: ["Legacy iOS apps"], sfSymbol: "square.grid.2x2"),
        GlossaryTerm(term: "Event-Driven", definition: "Components communicate via events rather than direct calls. An Event Bus or similar broadcasts events; subscribers react.", category: .architecturePatterns, relatedNodeTypes: [.eventBus, .websocket], codeExample: "EventBus.shared.publish(.dataUpdated)", realWorldApps: ["Real-time chat apps"], sfSymbol: "bus.fill"),
        GlossaryTerm(term: "Dependency Injection", definition: "Passing dependencies from outside rather than creating them inside. Makes code testable and flexible.", category: .architecturePatterns, relatedNodeTypes: [.viewModel, .repository], codeExample: "init(repository: UserRepository)", realWorldApps: ["Enterprise apps"], sfSymbol: "arrow.triangle.branch"),

        // Components (18 - one per NodeType)
        GlossaryTerm(term: "UI Layer", definition: "Presents data to the user and captures input. Should only talk to ViewModels, never to Database or API directly.", category: .components, relatedNodeTypes: [.ui], codeExample: "struct ContentView: View", realWorldApps: ["Every app"], sfSymbol: "rectangle.on.rectangle"),
        GlossaryTerm(term: "ViewModel", definition: "Prepares data for the UI and handles user actions. Bridges UI and data layer.", category: .components, relatedNodeTypes: [.viewModel], codeExample: "@Observable class FeedViewModel", realWorldApps: ["Twitter", "Instagram"], sfSymbol: "cpu"),
        GlossaryTerm(term: "Database", definition: "Local persistence. SwiftData, Core Data, or SQLite. Stores data for offline use.", category: .components, relatedNodeTypes: [.database], codeExample: "@Model class Item", realWorldApps: ["Notes", "Calendar"], sfSymbol: "cylinder.fill"),
        GlossaryTerm(term: "API Client", definition: "Fetches data from remote servers. Handles HTTP, JSON, and network errors.", category: .components, relatedNodeTypes: [.api], codeExample: "URLSession.shared.data(from: url)", realWorldApps: ["Weather apps", "News apps"], sfSymbol: "cloud.fill"),
        GlossaryTerm(term: "Repository", definition: "Single source of truth for data. Decides whether to use cache, API, or local storage.", category: .components, relatedNodeTypes: [.repository], codeExample: "class UserRepository", realWorldApps: ["Netflix", "Spotify"], sfSymbol: "folder.fill"),
        GlossaryTerm(term: "Network Cache", definition: "Caches API responses. Reduces network calls and speeds up repeated fetches.", category: .components, relatedNodeTypes: [.networkCache], realWorldApps: ["Browsers", "Social apps"], sfSymbol: "arrow.clockwise.circle.fill"),
        GlossaryTerm(term: "Memory Cache", definition: "In-memory cache for fast access. Good for frequently used data.", category: .components, relatedNodeTypes: [.memoryCache], realWorldApps: ["Image viewers"], sfSymbol: "memorychip"),
        GlossaryTerm(term: "Background Worker", definition: "Runs heavy tasks off the main thread. Keeps UI responsive.", category: .components, relatedNodeTypes: [.backgroundWorker], codeExample: "Task.detached { }", realWorldApps: ["Photo apps"], sfSymbol: "gearshape.2.fill"),
        GlossaryTerm(term: "Image Cache", definition: "Caches images in memory and disk. Essential for image-heavy apps.", category: .components, relatedNodeTypes: [.imageCache], realWorldApps: ["Instagram", "Pinterest"], sfSymbol: "photo.stack.fill"),
        GlossaryTerm(term: "Lazy Loader", definition: "Loads data only when needed. Saves memory and startup time.", category: .components, relatedNodeTypes: [.lazyLoader], realWorldApps: ["Long lists"], sfSymbol: "hourglass"),
        GlossaryTerm(term: "Circuit Breaker", definition: "Stops calling a failing service. Prevents cascade failures.", category: .components, relatedNodeTypes: [.circuitBreaker], realWorldApps: ["Microservices"], sfSymbol: "bolt.shield.fill"),
        GlossaryTerm(term: "Retry Handler", definition: "Retries failed requests with backoff. Handles transient failures.", category: .components, relatedNodeTypes: [.retryHandler], realWorldApps: ["Payment apps"], sfSymbol: "arrow.triangle.2.circlepath"),
        GlossaryTerm(term: "Fallback Provider", definition: "Provides alternative data when primary source fails.", category: .components, relatedNodeTypes: [.fallback], realWorldApps: ["E-commerce"], sfSymbol: "arrow.turn.down.right"),
        GlossaryTerm(term: "Health Monitor", definition: "Tracks service health and reports issues.", category: .components, relatedNodeTypes: [.healthMonitor], realWorldApps: ["Monitoring systems"], sfSymbol: "heart.text.square.fill"),
        GlossaryTerm(term: "ML Model", definition: "Machine learning inference. Runs predictions locally or remotely.", category: .components, relatedNodeTypes: [.mlModel], realWorldApps: ["Camera apps", "Translate"], sfSymbol: "brain.head.profile"),
        GlossaryTerm(term: "WebSocket", definition: "Real-time bidirectional communication. For live updates.", category: .components, relatedNodeTypes: [.websocket], realWorldApps: ["Chat apps", "Trading"], sfSymbol: "antenna.radiowaves.left.and.right"),
        GlossaryTerm(term: "Event Bus", definition: "Broadcasts events to subscribers. Decouples components.", category: .components, relatedNodeTypes: [.eventBus], realWorldApps: ["Complex apps"], sfSymbol: "bus.fill"),
        GlossaryTerm(term: "State Machine", definition: "Manages discrete states and transitions. Ensures valid flows.", category: .components, relatedNodeTypes: [.stateMachine], realWorldApps: ["Checkout flows"], sfSymbol: "flowchart.fill"),

        // Concepts (10)
        GlossaryTerm(term: "Separation of Concerns", definition: "Each component has one job. UI doesn't fetch data; ViewModel doesn't draw.", category: .concepts, realWorldApps: ["All well-designed apps"], sfSymbol: "square.split.2x2"),
        GlossaryTerm(term: "Abstraction", definition: "Hiding implementation details. Depend on interfaces, not concrete types.", category: .concepts, realWorldApps: ["Every layered app"], sfSymbol: "rectangle.compress.vertical"),
        GlossaryTerm(term: "Coupling", definition: "How much components depend on each other. Low coupling = easy to change.", category: .concepts, realWorldApps: ["Maintainable codebases"], sfSymbol: "link"),
        GlossaryTerm(term: "Cohesion", definition: "How related the parts of a component are. High cohesion = single responsibility.", category: .concepts, sfSymbol: "square.grid.3x3"),
        GlossaryTerm(term: "Async/Await", definition: "Modern Swift concurrency. Avoids callback hell and keeps code readable.", category: .concepts, codeExample: "let data = try await fetch()", realWorldApps: ["All iOS 15+ apps"], sfSymbol: "clock.arrow.circlepath"),
        GlossaryTerm(term: "Offline-First", definition: "App works without network. Sync when connected.", category: .concepts, relatedNodeTypes: [.database, .repository], realWorldApps: ["Notes", "Gmail"], sfSymbol: "wifi.slash"),
        GlossaryTerm(term: "Caching Strategy", definition: "When and what to cache. Memory vs disk, TTL, invalidation.", category: .concepts, relatedNodeTypes: [.memoryCache, .networkCache], realWorldApps: ["Social feeds"], sfSymbol: "arrow.2.circlepath"),
        GlossaryTerm(term: "Error Handling", definition: "Graceful handling of failures. User sees helpful messages, not crashes.", category: .concepts, relatedNodeTypes: [.circuitBreaker, .retryHandler], realWorldApps: ["Payment apps"], sfSymbol: "exclamationmark.triangle.fill"),
        GlossaryTerm(term: "Single Source of Truth", definition: "One place holds the authoritative data. Others derive from it.", category: .concepts, relatedNodeTypes: [.repository], realWorldApps: ["State management"], sfSymbol: "1.circle.fill"),
        GlossaryTerm(term: "Reactive Programming", definition: "Data flows as streams. Components react to changes automatically.", category: .concepts, relatedNodeTypes: [.eventBus], realWorldApps: ["Real-time dashboards"], sfSymbol: "waveform"),

        // Anti-Patterns (5)
        GlossaryTerm(term: "Direct UI-Database Coupling", definition: "UI talks directly to Database. Breaks separation, hard to test.", category: .antiPatterns, relatedNodeTypes: [.ui, .database], realWorldApps: ["Avoid!"], sfSymbol: "xmark.circle.fill"),
        GlossaryTerm(term: "God Object", definition: "One class does everything. Becomes unmaintainable.", category: .antiPatterns, sfSymbol: "person.fill.xmark"),
        GlossaryTerm(term: "Circular Dependencies", definition: "A depends on B, B depends on A. Causes init order issues.", category: .antiPatterns, realWorldApps: ["Avoid!"], sfSymbol: "arrow.triangle.2.circlepath.circle"),
        GlossaryTerm(term: "High Coupling", definition: "Too many connections between components. Changing one breaks many.", category: .antiPatterns, sfSymbol: "link.badge.plus"),
        GlossaryTerm(term: "No Error Handling", definition: "Network or DB fails and app crashes. Always handle failures.", category: .antiPatterns, relatedNodeTypes: [.api], realWorldApps: ["Avoid!"], sfSymbol: "exclamationmark.octagon.fill")
    ]

    static func search(_ query: String) -> [GlossaryTerm] {
        let lower = query.lowercased()
        if lower.isEmpty { return allTerms }
        return allTerms.filter {
            $0.term.lowercased().contains(lower) || $0.definition.lowercased().contains(lower)
        }
    }

    static func terms(for category: GlossaryCategory) -> [GlossaryTerm] {
        allTerms.filter { $0.category == category }
    }

    static func term(for id: String) -> GlossaryTerm? {
        allTerms.first { $0.id == id }
    }
}
