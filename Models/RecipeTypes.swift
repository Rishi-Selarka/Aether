import Foundation

enum Difficulty: String, Codable, CaseIterable, Sendable, Comparable {
    case beginner
    case intermediate
    case advanced

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        }
    }

    static func < (lhs: Difficulty, rhs: Difficulty) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

struct RecipeConnection: Sendable {
    let source: NodeType
    let target: NodeType
}

struct ArchitectureRecipe: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let difficulty: Difficulty
    let tierLevel: Int
    let nodes: [NodeType]
    let connections: [RecipeConnection]
    let realWorldApps: [String]
    let hints: [String]

    init(name: String, description: String, difficulty: Difficulty,
         tierLevel: Int, nodes: [NodeType], connections: [RecipeConnection],
         realWorldApps: [String] = [], hints: [String] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.tierLevel = tierLevel
        self.nodes = nodes
        self.connections = connections
        self.realWorldApps = realWorldApps
        self.hints = hints
    }
}
