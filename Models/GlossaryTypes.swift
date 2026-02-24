import Foundation

enum GlossaryCategory: String, Codable, CaseIterable, Sendable {
    case architecturePatterns
    case components
    case concepts
    case antiPatterns

    var displayName: String {
        switch self {
        case .architecturePatterns: return "Architecture Patterns"
        case .components: return "Components"
        case .concepts: return "Concepts"
        case .antiPatterns: return "Anti-Patterns"
        }
    }
}

struct GlossaryTerm: Identifiable, Sendable {
    let id: String
    let term: String
    let definition: String
    let category: GlossaryCategory
    let relatedNodeTypes: [NodeType]
    let codeExample: String?
    let realWorldApps: [String]
    let sfSymbol: String

    init(id: String? = nil, term: String, definition: String, category: GlossaryCategory,
         relatedNodeTypes: [NodeType] = [], codeExample: String? = nil,
         realWorldApps: [String] = [], sfSymbol: String = "book.fill") {
        self.id = id ?? term.lowercased().replacingOccurrences(of: " ", with: "-")
        self.term = term
        self.definition = definition
        self.category = category
        self.relatedNodeTypes = relatedNodeTypes
        self.codeExample = codeExample
        self.realWorldApps = realWorldApps
        self.sfSymbol = sfSymbol
    }
}
