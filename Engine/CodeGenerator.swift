import Foundation
import SwiftUI

/// Generates Swift code from an architecture graph with pattern detection.
enum ArchitecturePattern: String, CaseIterable {
    case mvvm
    case repository
    case cleanArchitecture
    case eventDriven
    case mlPipeline

    var displayName: String {
        switch self {
        case .mvvm: return "MVVM"
        case .repository: return "Repository Pattern"
        case .cleanArchitecture: return "Clean Architecture"
        case .eventDriven: return "Event-Driven"
        case .mlPipeline: return "ML Pipeline"
        }
    }
}

@MainActor
struct CodeGenerator {

    /// Detects which architecture patterns are present in the graph.
    static func detectPatterns(in graph: ArchitectureGraph) -> [ArchitecturePattern] {
        var patterns: [ArchitecturePattern] = []
        let nodeTypes = Set(graph.allNodes.map { $0.type })

        if nodeTypes.contains(.ui) && nodeTypes.contains(.viewModel) && nodeTypes.contains(.database) {
            patterns.append(.mvvm)
        }

        if nodeTypes.contains(.repository) {
            patterns.append(.repository)
        }

        let layerCount = countAbstractionLayers(in: graph)
        if layerCount >= 3 {
            patterns.append(.cleanArchitecture)
        }

        if nodeTypes.contains(.eventBus) || nodeTypes.contains(.websocket) {
            patterns.append(.eventDriven)
        }

        if nodeTypes.contains(.mlModel) {
            patterns.append(.mlPipeline)
        }

        return patterns
    }

    private static func countAbstractionLayers(in graph: ArchitectureGraph) -> Int {
        let layerTypes: Set<NodeType> = [.ui, .viewModel, .repository, .api, .database]
        let presentTypes = Set(graph.allNodes.map { $0.type })
        return layerTypes.intersection(presentTypes).count
    }

    /// Generates Swift code from the architecture graph.
    static func generateCode(from graph: ArchitectureGraph) -> String {
        var sections: [String] = []
        let patterns = detectPatterns(in: graph)

        sections.append("// Generated from City Architect")
        sections.append("// Detected patterns: \(patterns.map(\.displayName).joined(separator: ", "))")
        sections.append("")

        if patterns.contains(.mvvm) {
            sections.append(generateMVVMSection(graph: graph))
        }
        if patterns.contains(.repository) {
            sections.append(generateRepositorySection(graph: graph))
        }
        if graph.allNodes.contains(where: { $0.type == .database }) {
            sections.append(generateDataModelsSection(graph: graph))
        }
        if graph.allNodes.contains(where: { $0.type == .api }) {
            sections.append(generateAPISection(graph: graph))
        }

        sections.append(generateViewModelsSection(graph: graph))
        sections.append(generateSwiftUISection(graph: graph))

        if patterns.contains(.eventDriven) {
            sections.append(generateEventBusSection(graph: graph))
        }
        if patterns.contains(.mlPipeline) {
            sections.append(generateMLSection(graph: graph))
        }

        return sections.joined(separator: "\n\n")
    }

    private static func generateMVVMSection(graph: ArchitectureGraph) -> String {
        """
        // MARK: - MVVM Structure
        // UI → ViewModel → Data layer separation

        """
    }

    private static func generateRepositorySection(graph: ArchitectureGraph) -> String {
        let repos = graph.allNodes.filter { $0.type == .repository }
        guard !repos.isEmpty else { return "" }

        var code = "// MARK: - Repository Pattern\n"
        for _ in repos {
            let name = "DataRepository"
            code += """
            protocol \(name)Protocol {
                func fetchData() async throws -> [Item]
                func save(_ item: Item) async throws
            }

            final class \(name): \(name)Protocol {
                private let api: APIClient
                private let database: Database

                init(api: APIClient, database: Database) {
                    self.api = api
                    self.database = database
                }

                func fetchData() async throws -> [Item] {
                    try await api.fetch()
                }

                func save(_ item: Item) async throws {
                    try await database.save(item)
                }
            }

            """
            break
        }
        return code
    }

    private static func generateDataModelsSection(graph: ArchitectureGraph) -> String {
        let hasDB = graph.allNodes.contains { $0.type == .database }
        guard hasDB else { return "" }

        return """
        // MARK: - Data Models

        struct Item: Identifiable, Codable {
            let id: UUID
            var title: String
        }
        """
    }

    private static func generateAPISection(graph: ArchitectureGraph) -> String {
        guard graph.allNodes.contains(where: { $0.type == .api }) else { return "" }

        return """
        // MARK: - API Client

        final class APIClient {
            func fetch() async throws -> [Item] {
                let url = URL(string: "https://api.example.com/items")!
                let (data, _) = try await URLSession.shared.data(from: url)
                return try JSONDecoder().decode([Item].self, from: data)
            }
        }
        """
    }

    private static func generateViewModelsSection(graph: ArchitectureGraph) -> String {
        guard graph.allNodes.contains(where: { $0.type == .viewModel }) else { return "" }

        return """
        // MARK: - ViewModel

        @Observable
        final class ContentViewModel {
            var items: [Item] = []
            var isLoading = false

            func load() async {
                isLoading = true
                defer { isLoading = false }
                // Fetch from repository or database
            }
        }
        """
    }

    private static func generateSwiftUISection(graph: ArchitectureGraph) -> String {
        return """
        // MARK: - SwiftUI View

        struct ContentView: View {
            @State private var viewModel = ContentViewModel()

            var body: some View {
                List(viewModel.items) { item in
                    Text(item.title)
                }
                .task { await viewModel.load() }
            }
        }
        """
    }

    private static func generateEventBusSection(graph: ArchitectureGraph) -> String {
        guard graph.allNodes.contains(where: { $0.type == .eventBus }) else { return "" }

        return """
        // MARK: - Event Bus

        @Observable
        final class EventBus {
            static let shared = EventBus()
            var events: [AppEvent] = []

            func publish(_ event: AppEvent) {
                events.append(event)
            }
        }

        enum AppEvent {
            case dataUpdated
        }
        """
    }

    private static func generateMLSection(graph: ArchitectureGraph) -> String {
        guard graph.allNodes.contains(where: { $0.type == .mlModel }) else { return "" }

        return """
        // MARK: - ML Model

        import CoreML

        final class MLInferenceService {
            func classify(image: CGImage) async throws -> String {
                // ML inference logic
                return "result"
            }
        }
        """
    }

    /// Returns ranges for syntax highlighting (line index -> array of (range, token type)).
    static func highlightedRanges(for code: String) -> [Int: [(Range<String.Index>, CodeToken)]] {
        var result: [Int: [(Range<String.Index>, CodeToken)]] = [:]
        let lines = code.components(separatedBy: "\n")

        let keywords: Set<String> = [
            "struct", "class", "enum", "protocol", "func", "var", "let",
            "async", "throws", "try", "await", "return", "if", "else",
            "import", "private", "final", "static", "init"
        ]

        for (lineIndex, line) in lines.enumerated() {
            var tokens: [(Range<String.Index>, CodeToken)] = []

            for word in keywords {
                var searchStart = line.startIndex
                while let range = line.range(of: word, range: searchStart..<line.endIndex) {
                    let isWordBoundary: (Character) -> Bool = { $0.isLetter || $0 == "_" }
                    let before = range.lowerBound == line.startIndex ? true : !isWordBoundary(line[line.index(before: range.lowerBound)])
                    let after = range.upperBound == line.endIndex ? true : !isWordBoundary(line[range.upperBound])
                    if before && after {
                        tokens.append((range, .keyword))
                    }
                    searchStart = range.upperBound
                }
            }

            if let commentStart = line.range(of: "//")?.lowerBound {
                let commentRange = commentStart..<line.endIndex
                tokens.append((commentRange, .comment))
            }

            if !tokens.isEmpty {
                result[lineIndex] = tokens
            }
        }
        return result
    }
}

enum CodeToken {
    case keyword
    case comment
    case typeName
    case string
}
