import Foundation

@MainActor
struct EvaluationEngine {

    static func evaluate(graph: ArchitectureGraph) -> EvaluationResult {
        let antiPatterns = graph.detectAntiPatterns()
        let metrics = graph.calculateMetrics()

        let modularity = scoreModularity(graph: graph, antiPatterns: antiPatterns)
        let performance = scorePerformance(graph: graph)
        let scalability = scoreScalability(graph: graph, metrics: metrics)
        let resilience = scoreResilience(graph: graph, antiPatterns: antiPatterns)

        let overall = (modularity + performance + scalability + resilience) / 4
        let feedback = buildFeedback(graph: graph, antiPatterns: antiPatterns, modularity: modularity, performance: performance, scalability: scalability, resilience: resilience)

        return EvaluationResult(
            overallScore: overall,
            modularity: modularity,
            performance: performance,
            scalability: scalability,
            resilience: resilience,
            antiPatterns: antiPatterns,
            feedback: feedback
        )
    }

    private static func scoreModularity(graph: ArchitectureGraph, antiPatterns: [AntiPattern]) -> Double {
        var score: Double = 100
        for ap in antiPatterns {
            switch ap.type {
            case .directUIDatabase: score -= 30
            case .missingAbstraction: score -= 15
            case .circularDependency: score -= 25
            case .highCoupling: score -= 10
            case .noErrorHandling: score -= 5
            }
        }
        return max(0, min(100, score))
    }

    private static func scorePerformance(graph: ArchitectureGraph) -> Double {
        let nodes = graph.allNodes
        let hasCache = nodes.contains { [.memoryCache, .networkCache, .imageCache].contains($0.type) }
        let hasBackground = nodes.contains { [.backgroundWorker, .lazyLoader].contains($0.type) }
        var score: Double = 60
        if hasCache { score += 20 }
        if hasBackground { score += 20 }
        return min(100, score)
    }

    private static func scoreScalability(graph: ArchitectureGraph, metrics: GraphMetrics) -> Double {
        var score: Double = 70
        let hasRepository = graph.allNodes.contains { $0.type == .repository }
        if hasRepository { score += 15 }
        if metrics.density < 0.5 { score += 15 }
        return min(100, score)
    }

    private static func scoreResilience(graph: ArchitectureGraph, antiPatterns: [AntiPattern]) -> Double {
        let hasAPI = graph.allNodes.contains { $0.type == .api }
        guard hasAPI else { return 80 }

        let hasResilience = graph.allNodes.contains { [.circuitBreaker, .retryHandler, .fallback].contains($0.type) }
        let hasNoErrorHandling = antiPatterns.contains { $0.type == .noErrorHandling }
        if hasResilience { return 95 }
        if hasNoErrorHandling { return 50 }
        return 70
    }

    private static func buildFeedback(graph: ArchitectureGraph, antiPatterns: [AntiPattern],
                                     modularity: Double, performance: Double, scalability: Double, resilience: Double) -> [Feedback] {
        var feedback: [Feedback] = []

        if modularity >= 90 {
            feedback.append(Feedback(type: .praise, message: "Excellent layer separation and modularity.", relatedNodeIDs: []))
        }
        if performance >= 85 {
            feedback.append(Feedback(type: .praise, message: "Good use of caching and background processing.", relatedNodeIDs: []))
        }
        if scalability >= 85 {
            feedback.append(Feedback(type: .praise, message: "Architecture supports growth and change.", relatedNodeIDs: []))
        }
        if resilience >= 90 {
            feedback.append(Feedback(type: .praise, message: "Robust error handling in place.", relatedNodeIDs: []))
        }

        for ap in antiPatterns {
            feedback.append(Feedback(
                type: ap.severity == .critical ? .error : .warning,
                message: ap.title,
                relatedNodeIDs: ap.involvedNodeIDs
            ))
        }

        if performance < 70 {
            feedback.append(Feedback(type: .suggestion, message: "Consider adding caching or background workers for better performance."))
        }
        if !graph.allNodes.contains(where: { $0.type == .repository }) && graph.allNodes.contains(where: { $0.type == .api }) {
            feedback.append(Feedback(type: .suggestion, message: "Add a Repository layer to abstract data access."))
        }

        return feedback
    }
}
