import SwiftUI

enum NodeType: String, Codable, CaseIterable, Identifiable {
    case ui = "ui"
    case viewModel = "viewModel"
    case database = "database"
    case api = "api"
    case repository = "repository"
    case networkCache = "networkCache"
    case memoryCache = "memoryCache"
    case backgroundWorker = "backgroundWorker"
    case imageCache = "imageCache"
    case lazyLoader = "lazyLoader"
    case circuitBreaker = "circuitBreaker"
    case retryHandler = "retryHandler"
    case fallback = "fallback"
    case healthMonitor = "healthMonitor"
    case mlModel = "mlModel"
    case websocket = "websocket"
    case eventBus = "eventBus"
    case stateMachine = "stateMachine"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .ui: return "UI Layer"
        case .viewModel: return "ViewModel"
        case .database: return "Database"
        case .api: return "API Client"
        case .repository: return "Repository"
        case .networkCache: return "Network Cache"
        case .memoryCache: return "Memory Cache"
        case .backgroundWorker: return "Background Worker"
        case .imageCache: return "Image Cache"
        case .lazyLoader: return "Lazy Loader"
        case .circuitBreaker: return "Circuit Breaker"
        case .retryHandler: return "Retry Handler"
        case .fallback: return "Fallback Provider"
        case .healthMonitor: return "Health Monitor"
        case .mlModel: return "ML Model"
        case .websocket: return "WebSocket"
        case .eventBus: return "Event Bus"
        case .stateMachine: return "State Machine"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .ui: return "rectangle.on.rectangle"
        case .viewModel: return "cpu"
        case .database: return "cylinder.fill"
        case .api: return "cloud.fill"
        case .repository: return "folder.fill"
        case .networkCache: return "arrow.clockwise.circle.fill"
        case .memoryCache: return "memorychip"
        case .backgroundWorker: return "gearshape.2.fill"
        case .imageCache: return "photo.stack.fill"
        case .lazyLoader: return "hourglass"
        case .circuitBreaker: return "bolt.shield.fill"
        case .retryHandler: return "arrow.triangle.2.circlepath"
        case .fallback: return "arrow.turn.down.right"
        case .healthMonitor: return "heart.text.square.fill"
        case .mlModel: return "brain.head.profile"
        case .websocket: return "antenna.radiowaves.left.and.right"
        case .eventBus: return "bus.fill"
        case .stateMachine: return "flowchart.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .ui: return .blue
        case .viewModel: return .purple
        case .database: return .green
        case .api: return .orange
        case .repository: return .cyan
        case .networkCache: return .teal
        case .memoryCache: return .mint
        case .backgroundWorker: return .yellow
        case .imageCache: return .indigo
        case .lazyLoader: return .brown
        case .circuitBreaker: return .red
        case .retryHandler: return .pink
        case .fallback: return .orange
        case .healthMonitor: return .green
        case .mlModel: return .purple
        case .websocket: return .blue
        case .eventBus: return .cyan
        case .stateMachine: return .indigo
        }
    }
    
    var allowedConnections: [NodeType] {
        switch self {
        case .ui: return [.viewModel]
        case .viewModel: return [.database, .repository, .api]
        case .database: return []
        case .api: return [.database, .networkCache]
        case .repository: return [.api, .database, .memoryCache]
        case .networkCache: return [.database]
        case .memoryCache: return [.database]
        case .backgroundWorker: return [.database, .api]
        case .imageCache: return [.database]
        case .lazyLoader: return [.database, .api]
        case .circuitBreaker: return [.api, .fallback]
        case .retryHandler: return [.api]
        case .fallback: return [.database, .memoryCache]
        case .healthMonitor: return [.api, .database]
        case .mlModel: return [.database]
        case .websocket: return [.eventBus]
        case .eventBus: return [.viewModel, .database]
        case .stateMachine: return [.viewModel]
        }
    }
    
    var tierLevel: Int {
        switch self {
        case .ui, .viewModel, .database: return 1
        case .api, .repository, .networkCache: return 2
        case .memoryCache, .backgroundWorker, .imageCache, .lazyLoader: return 3
        case .circuitBreaker, .retryHandler, .fallback, .healthMonitor: return 4
        case .mlModel, .websocket, .eventBus, .stateMachine: return 5
        }
    }
}
