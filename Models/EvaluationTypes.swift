import Foundation

enum AntiPatternType: String, Codable, CaseIterable, Sendable {
    case directUIDatabase
    case missingAbstraction
    case circularDependency
    case highCoupling
    case noErrorHandling

    var displayName: String {
        switch self {
        case .directUIDatabase: return "Direct UI-Database Coupling"
        case .missingAbstraction: return "Missing Abstraction Layer"
        case .circularDependency: return "Circular Dependency"
        case .highCoupling: return "High Coupling"
        case .noErrorHandling: return "No Error Handling"
        }
    }
}

enum Severity: String, Codable, Sendable, Comparable {
    case info
    case warning
    case critical

    private var sortOrder: Int {
        switch self {
        case .info: return 0
        case .warning: return 1
        case .critical: return 2
        }
    }

    static func < (lhs: Severity, rhs: Severity) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

enum FeedbackType: String, Codable, Sendable {
    case praise
    case suggestion
    case warning
    case error
}

struct AntiPattern: Identifiable, Sendable {
    let id: String
    let type: AntiPatternType
    let severity: Severity
    let involvedNodeIDs: [String]
    let title: String
    let explanation: String
    let suggestion: String

    init(type: AntiPatternType, severity: Severity, involvedNodeIDs: [String],
         title: String, explanation: String, suggestion: String) {
        self.id = UUID().uuidString
        self.type = type
        self.severity = severity
        self.involvedNodeIDs = involvedNodeIDs
        self.title = title
        self.explanation = explanation
        self.suggestion = suggestion
    }
}

struct Feedback: Identifiable, Sendable {
    let id: String
    let type: FeedbackType
    let message: String
    let relatedNodeIDs: [String]

    init(type: FeedbackType, message: String, relatedNodeIDs: [String] = []) {
        self.id = UUID().uuidString
        self.type = type
        self.message = message
        self.relatedNodeIDs = relatedNodeIDs
    }
}

struct EvaluationResult: Sendable {
    let overallScore: Double
    let modularity: Double
    let performance: Double
    let scalability: Double
    let resilience: Double
    let antiPatterns: [AntiPattern]
    let feedback: [Feedback]
    let timestamp: Date

    init(overallScore: Double, modularity: Double, performance: Double,
         scalability: Double, resilience: Double,
         antiPatterns: [AntiPattern], feedback: [Feedback]) {
        self.overallScore = overallScore
        self.modularity = modularity
        self.performance = performance
        self.scalability = scalability
        self.resilience = resilience
        self.antiPatterns = antiPatterns
        self.feedback = feedback
        self.timestamp = Date()
    }
}
