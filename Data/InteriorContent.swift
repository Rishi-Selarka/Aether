import Foundation

struct InteriorProblem: Identifiable {
    let id: String
    let title: String
    let description: String
    let keywords: [String]
    /// Correct top-to-bottom block order for the canvas challenge.
    let blocks: [NodeType]
}

enum InteriorContent {
    static func problems(for tierID: Int) -> [InteriorProblem] {
        switch tierID {
        case 1: return tier1Problems
        case 2: return tier2Problems
        case 3: return tier3Problems
        case 4: return tier4Problems
        case 5: return tier5Problems
        default: return []
        }
    }

    // MARK: - Tier 1 (Tokyo — Lake)

    private static let tier1Problems: [InteriorProblem] = [
        InteriorProblem(
            id: "t1_notes",
            title: "Notes App",
            description: "Design the architecture for a personal notes app (like Apple Notes). Users can create, edit, and delete notes. Data is stored entirely on-device.",
            keywords: ["MVVM", "UI → ViewModel → DB", "Local Persistence"],
            blocks: [.ui, .viewModel, .repository, .database]
        ),
        InteriorProblem(
            id: "t1_habit",
            title: "Habit Tracker",
            description: "Architect a daily habit tracker that logs streaks and saves progress offline. Habits are checked off daily and totals persist between app launches.",
            keywords: ["State Management", "SwiftData", "Offline Storage"],
            blocks: [.ui, .viewModel, .backgroundWorker, .database]
        ),
        InteriorProblem(
            id: "t1_todo",
            title: "To-Do List",
            description: "Build the architecture for a task manager with categories and priority flags. No internet required — all state lives locally.",
            keywords: ["MVVM", "Clean Separation", "Value Types"],
            blocks: [.ui, .viewModel, .repository, .database]
        ),
    ]

    // MARK: - Tier 2 (London — River)

    private static let tier2Problems: [InteriorProblem] = [
        InteriorProblem(
            id: "t2_weather",
            title: "Weather App",
            description: "Design the architecture for a weather app that fetches current conditions and a 7-day forecast from a remote API. Handle loading, success, and error states.",
            keywords: ["API Client", "Repository Pattern", "Async/Await"],
            blocks: [.ui, .viewModel, .repository, .api]
        ),
        InteriorProblem(
            id: "t2_news",
            title: "News Reader",
            description: "Architect a news feed app that pulls headlines from an RSS/REST API and caches articles for offline reading.",
            keywords: ["Repository", "Single Source of Truth", "Network Cache"],
            blocks: [.ui, .viewModel, .networkCache, .api]
        ),
        InteriorProblem(
            id: "t2_github",
            title: "GitHub Profile Viewer",
            description: "Build the system design for an app where users search a GitHub username and see their public repos and stats.",
            keywords: ["Async API Calls", "Error Propagation", "ViewModel"],
            blocks: [.ui, .viewModel, .repository, .api]
        ),
    ]

    // MARK: - Tier 3 (Singapore — Sea)

    private static let tier3Problems: [InteriorProblem] = [
        InteriorProblem(
            id: "t3_photo",
            title: "Photo Feed",
            description: "Design an Instagram-style scrollable photo feed. Images must load smoothly without blocking the main thread. Add image caching so scrolling back is instant.",
            keywords: ["Image Cache", "Lazy Loading", "Background Fetch"],
            blocks: [.ui, .viewModel, .imageCache, .lazyLoader, .backgroundWorker, .database]
        ),
        InteriorProblem(
            id: "t3_restaurant",
            title: "Restaurant Finder",
            description: "Architect an app that shows nearby restaurants. Location lookup and data fetch happen in the background; results appear without freezing the UI.",
            keywords: ["Background Worker", "In-Memory Cache", "Concurrency"],
            blocks: [.ui, .viewModel, .memoryCache, .backgroundWorker, .api, .database]
        ),
        InteriorProblem(
            id: "t3_podcast",
            title: "Podcast Player",
            description: "Build the architecture for a podcast app that streams audio and pre-fetches the next episode in the background while the current one plays.",
            keywords: ["Background Processing", "Cache-First", "Streaming"],
            blocks: [.ui, .viewModel, .backgroundWorker, .memoryCache, .api, .database]
        ),
    ]

    // MARK: - Tier 4 (New York — Ocean)

    private static let tier4Problems: [InteriorProblem] = [
        InteriorProblem(
            id: "t4_banking",
            title: "Banking Transfer",
            description: "Design the architecture for a money-transfer feature. If the payment API fails, retry up to 3 times with exponential backoff. If it still fails, queue the transfer for later.",
            keywords: ["Retry Handler", "Circuit Breaker", "Fallback"],
            blocks: [.ui, .viewModel, .circuitBreaker, .retryHandler, .fallback, .api]
        ),
        InteriorProblem(
            id: "t4_rideshare",
            title: "Ride-Sharing Tracker",
            description: "Architect a trip-tracking screen (like Uber) that shows a driver's location in real time. If the network drops, fall back to last-known location and reconnect.",
            keywords: ["Health Monitor", "Retry Logic", "Recovery"],
            blocks: [.ui, .viewModel, .healthMonitor, .circuitBreaker, .retryHandler, .api]
        ),
        InteriorProblem(
            id: "t4_ecommerce",
            title: "E-commerce Checkout",
            description: "Build the system design for a checkout flow. Payment processing must survive transient failures. A fallback should save the order locally if the server is unreachable.",
            keywords: ["Circuit Breaker", "Fallback Provider", "Local Queue"],
            blocks: [.ui, .viewModel, .circuitBreaker, .retryHandler, .fallback, .database]
        ),
    ]

    // MARK: - Tier 5 (San Francisco — Abyss)

    private static let tier5Problems: [InteriorProblem] = [
        InteriorProblem(
            id: "t5_photos",
            title: "Smart Photo Organizer",
            description: "Design the architecture for a photo app that auto-categorizes images using on-device Core ML. New photos are classified in the background and the gallery updates in real time.",
            keywords: ["ML Model", "Event Bus", "State Machine"],
            blocks: [.ui, .viewModel, .mlModel, .eventBus, .stateMachine, .database]
        ),
        InteriorProblem(
            id: "t5_sports",
            title: "Live Sports Score",
            description: "Architect a sports app where scores update the moment they change via WebSocket. Multiple screens all react to the same live feed.",
            keywords: ["WebSocket", "Event Bus", "Reactive ViewModels"],
            blocks: [.ui, .viewModel, .websocket, .eventBus, .stateMachine, .database]
        ),
        InteriorProblem(
            id: "t5_search",
            title: "Predictive Search",
            description: "Build the system design for a search feature that learns from past queries and suggests completions. An ML model ranks results; a State Machine manages the flow.",
            keywords: ["ML Model", "State Machine", "Event Bus"],
            blocks: [.ui, .viewModel, .mlModel, .stateMachine, .eventBus, .database]
        ),
    ]
}
