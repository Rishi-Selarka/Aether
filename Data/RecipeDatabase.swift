import Foundation

enum RecipeDatabase {
    static let allRecipes: [ArchitectureRecipe] = [
        ArchitectureRecipe(
            name: "Simple CRUD App",
            description: "Basic create, read, update, delete. UI talks to ViewModel, ViewModel to Database.",
            difficulty: .beginner,
            tierLevel: 1,
            nodes: [.ui, .viewModel, .database],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .database)
            ],
            realWorldApps: ["Notes", "Todo apps"],
            hints: ["Start with UI, add ViewModel, then Database"]
        ),
        ArchitectureRecipe(
            name: "Weather App",
            description: "Fetches weather from API. Repository abstracts the data source.",
            difficulty: .beginner,
            tierLevel: 2,
            nodes: [.ui, .viewModel, .repository, .api],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .repository),
                RecipeConnection(source: .repository, target: .api)
            ],
            realWorldApps: ["Weather apps"],
            hints: ["Repository sits between ViewModel and API"]
        ),
        ArchitectureRecipe(
            name: "Instagram Feed Clone",
            description: "Social feed with caching. Network Cache speeds up image loading.",
            difficulty: .intermediate,
            tierLevel: 2,
            nodes: [.ui, .viewModel, .repository, .api, .networkCache],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .repository),
                RecipeConnection(source: .repository, target: .api),
                RecipeConnection(source: .repository, target: .networkCache),
                RecipeConnection(source: .api, target: .networkCache)
            ],
            realWorldApps: ["Instagram", "Twitter"],
            hints: ["Add Network Cache between Repository and API"]
        ),
        ArchitectureRecipe(
            name: "Photo Editor App",
            description: "Uses Memory Cache and Repository for performance. Caches processed images.",
            difficulty: .intermediate,
            tierLevel: 3,
            nodes: [.ui, .viewModel, .repository, .memoryCache, .database],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .repository),
                RecipeConnection(source: .repository, target: .memoryCache),
                RecipeConnection(source: .repository, target: .database),
                RecipeConnection(source: .memoryCache, target: .database)
            ],
            realWorldApps: ["Photos", "Procreate"],
            hints: ["Repository with Memory Cache for fast repeated access"]
        ),
        ArchitectureRecipe(
            name: "E-commerce Checkout",
            description: "Payment flow with resilience. Circuit Breaker and Fallback handle failures.",
            difficulty: .advanced,
            tierLevel: 4,
            nodes: [.ui, .viewModel, .circuitBreaker, .api, .fallback, .database],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .circuitBreaker),
                RecipeConnection(source: .circuitBreaker, target: .api),
                RecipeConnection(source: .circuitBreaker, target: .fallback),
                RecipeConnection(source: .fallback, target: .database)
            ],
            realWorldApps: ["Amazon", "Stripe checkout"],
            hints: ["Circuit Breaker protects API, Fallback provides offline option"]
        ),
        ArchitectureRecipe(
            name: "ML Photo Search",
            description: "Search photos using ML. ML Model runs inference; Memory Cache speeds results.",
            difficulty: .advanced,
            tierLevel: 5,
            nodes: [.ui, .viewModel, .mlModel, .memoryCache, .database],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .mlModel),
                RecipeConnection(source: .viewModel, target: .memoryCache),
                RecipeConnection(source: .mlModel, target: .database),
                RecipeConnection(source: .memoryCache, target: .database)
            ],
            realWorldApps: ["Google Photos", "Pinterest Lens"],
            hints: ["ML Model for search, Memory Cache for recent results"]
        ),
        ArchitectureRecipe(
            name: "Real-time Chat",
            description: "Live messaging. WebSocket pushes to Event Bus; ViewModel subscribes for UI updates.",
            difficulty: .advanced,
            tierLevel: 5,
            nodes: [.ui, .viewModel, .api, .websocket, .eventBus, .database],
            connections: [
                RecipeConnection(source: .ui, target: .viewModel),
                RecipeConnection(source: .viewModel, target: .api),
                RecipeConnection(source: .websocket, target: .eventBus),
                RecipeConnection(source: .eventBus, target: .viewModel),
                RecipeConnection(source: .eventBus, target: .database)
            ],
            realWorldApps: ["iMessage", "Slack"],
            hints: ["WebSocket pushes to Event Bus; ViewModel receives from Event Bus"]
        )
    ]

    static func recipes(for tier: Int) -> [ArchitectureRecipe] {
        allRecipes.filter { $0.tierLevel <= tier }
    }
}
