import Foundation
import SwiftData

// MARK: - Value Types

struct GraphNode: Identifiable, Sendable {
    let id: String
    let type: NodeType
    var x: Double
    var y: Double
}

struct GraphEdge: Identifiable, Sendable {
    var id: String { "\(sourceID)->\(targetID)" }
    let sourceID: String
    let targetID: String
}

struct GraphMetrics: Sendable {
    let nodeCount: Int
    let edgeCount: Int
    let density: Double
    let averageDegree: Double
}

// MARK: - Protocol

@MainActor
protocol ArchitectureGraphProtocol {
    // Nodes
    func addNode(id: String, type: NodeType, x: Double, y: Double)
    func removeNode(id: String)
    func node(for id: String) -> GraphNode?
    var allNodes: [GraphNode] { get }

    // Connections
    func createConnection(sourceID: String, targetID: String) -> Bool
    func deleteConnection(sourceID: String, targetID: String)
    func validateConnection(sourceType: NodeType, targetType: NodeType) -> Bool
    var allConnections: [GraphEdge] { get }

    // Analysis
    func detectAntiPatterns() -> [AntiPattern]
    func detectCycles() -> [[String]]
    func findPath(from sourceID: String, to targetID: String) -> [String]?
    func calculateMetrics() -> GraphMetrics
}

// MARK: - Implementation

@MainActor
@Observable
final class ArchitectureGraph: ArchitectureGraphProtocol {

    private(set) var nodes: [String: GraphNode] = [:]
    private(set) var adjacency: [String: Set<String>] = [:]

    var allNodes: [GraphNode] { Array(nodes.values) }

    var allConnections: [GraphEdge] {
        adjacency.flatMap { sourceID, targets in
            targets.map { GraphEdge(sourceID: sourceID, targetID: $0) }
        }
    }

    // MARK: - Node Operations

    func addNode(id: String, type: NodeType, x: Double, y: Double) {
        nodes[id] = GraphNode(id: id, type: type, x: x, y: y)
        if adjacency[id] == nil { adjacency[id] = [] }
    }

    func removeNode(id: String) {
        nodes.removeValue(forKey: id)
        adjacency.removeValue(forKey: id)
        for key in adjacency.keys {
            adjacency[key]?.remove(id)
        }
    }

    func updateNodePosition(id: String, x: Double, y: Double) {
        guard var existing = nodes[id] else { return }
        existing.x = x
        existing.y = y
        nodes[id] = existing
    }

    func node(for id: String) -> GraphNode? { nodes[id] }

    func clear() {
        nodes.removeAll()
        adjacency.removeAll()
    }

    // MARK: - Connection Operations

    func validateConnection(sourceType: NodeType, targetType: NodeType) -> Bool {
        sourceType.allowedConnections.contains(targetType)
    }

    func createConnection(sourceID: String, targetID: String) -> Bool {
        guard let source = nodes[sourceID],
              let target = nodes[targetID],
              sourceID != targetID,
              validateConnection(sourceType: source.type, targetType: target.type),
              !(adjacency[sourceID]?.contains(targetID) ?? false)
        else { return false }

        adjacency[sourceID, default: []].insert(targetID)
        return true
    }

    func deleteConnection(sourceID: String, targetID: String) {
        adjacency[sourceID]?.remove(targetID)
    }

    // MARK: - Anti-Pattern Detection

    func detectAntiPatterns() -> [AntiPattern] {
        var results: [AntiPattern] = []
        results.append(contentsOf: detectDirectUIDatabase())
        results.append(contentsOf: detectMissingAbstraction())
        results.append(contentsOf: detectCircularDependencies())
        results.append(contentsOf: detectHighCoupling())
        results.append(contentsOf: detectNoErrorHandling())
        return results
    }

    private func detectDirectUIDatabase() -> [AntiPattern] {
        var patterns: [AntiPattern] = []
        for (sourceID, targets) in adjacency {
            guard let source = nodes[sourceID], source.type == .ui else { continue }
            for targetID in targets {
                guard let target = nodes[targetID], target.type == .database else { continue }
                patterns.append(AntiPattern(
                    type: .directUIDatabase,
                    severity: .critical,
                    involvedNodeIDs: [sourceID, targetID],
                    title: "UI directly accesses Database",
                    explanation: "The UI layer should never talk directly to the database. This breaks separation of concerns and makes the code untestable.",
                    suggestion: "Add a ViewModel between the UI and Database to manage data flow."
                ))
            }
        }
        return patterns
    }

    private func detectMissingAbstraction() -> [AntiPattern] {
        var patterns: [AntiPattern] = []
        let hasRepository = nodes.values.contains { $0.type == .repository }

        for (sourceID, targets) in adjacency {
            guard let source = nodes[sourceID], source.type == .viewModel else { continue }
            for targetID in targets {
                guard let target = nodes[targetID], target.type == .database else { continue }
                if !hasRepository {
                    patterns.append(AntiPattern(
                        type: .missingAbstraction,
                        severity: .warning,
                        involvedNodeIDs: [sourceID, targetID],
                        title: "ViewModel accesses Database directly",
                        explanation: "Without a Repository layer, your ViewModel is tightly coupled to the data source. Swapping databases later becomes very difficult.",
                        suggestion: "Add a Repository between the ViewModel and Database to abstract data access."
                    ))
                }
            }
        }
        return patterns
    }

    private func detectCircularDependencies() -> [AntiPattern] {
        let cycles = detectCycles()
        return cycles.map { cycle in
            AntiPattern(
                type: .circularDependency,
                severity: .critical,
                involvedNodeIDs: cycle,
                title: "Circular dependency detected",
                explanation: "Components form a loop: \(cycleDescription(cycle)). This makes initialization order undefined and creates tight coupling.",
                suggestion: "Break the cycle by introducing a protocol or event-based communication."
            )
        }
    }

    private func cycleDescription(_ cycle: [String]) -> String {
        let names = cycle.compactMap { nodes[$0]?.type.displayName }
        return names.joined(separator: " → ")
    }

    private func detectHighCoupling() -> [AntiPattern] {
        var patterns: [AntiPattern] = []
        let couplingThreshold = 4

        for (nodeID, node) in nodes {
            let outDegree = adjacency[nodeID]?.count ?? 0
            var inDegree = 0
            for targets in adjacency.values {
                if targets.contains(nodeID) { inDegree += 1 }
            }
            let totalDegree = outDegree + inDegree

            if totalDegree > couplingThreshold {
                patterns.append(AntiPattern(
                    type: .highCoupling,
                    severity: .warning,
                    involvedNodeIDs: [nodeID],
                    title: "\(node.type.displayName) has too many connections",
                    explanation: "This component has \(totalDegree) connections. High coupling makes it hard to change one component without affecting many others.",
                    suggestion: "Consider splitting responsibilities or introducing an intermediary component."
                ))
            }
        }
        return patterns
    }

    private func detectNoErrorHandling() -> [AntiPattern] {
        let hasAPI = nodes.values.contains { $0.type == .api }
        guard hasAPI else { return [] }

        let resilienceTypes: Set<NodeType> = [.circuitBreaker, .retryHandler, .fallback]
        let hasResilience = nodes.values.contains { resilienceTypes.contains($0.type) }

        if !hasResilience {
            let apiNodeIDs = nodes.values.filter { $0.type == .api }.map(\.id)
            return [AntiPattern(
                type: .noErrorHandling,
                severity: .warning,
                involvedNodeIDs: apiNodeIDs,
                title: "No error handling for API calls",
                explanation: "Network calls can fail. Without error handling components, your app will crash or show blank screens when the network is unavailable.",
                suggestion: "Add a Circuit Breaker, Retry Handler, or Fallback Provider to handle API failures gracefully."
            )]
        }
        return []
    }

    // MARK: - Graph Algorithms

    func rootNodeIDs() -> [String] {
        allNodes.filter { node in
            !allConnections.contains { $0.targetID == node.id }
        }.map(\.id)
    }

    func leafNodeIDs() -> [String] {
        allNodes.filter { node in
            (adjacency[node.id] ?? []).isEmpty
        }.map(\.id)
    }

    func findPath(from sourceID: String, to targetID: String) -> [String]? {
        guard nodes[sourceID] != nil, nodes[targetID] != nil else { return nil }
        if sourceID == targetID { return [sourceID] }

        var visited: Set<String> = [sourceID]
        var queue: [(nodeID: String, path: [String])] = [(sourceID, [sourceID])]
        var head = 0

        while head < queue.count {
            let (current, path) = queue[head]
            head += 1

            for neighbor in adjacency[current] ?? [] {
                if neighbor == targetID {
                    return path + [neighbor]
                }
                if !visited.contains(neighbor) {
                    visited.insert(neighbor)
                    queue.append((neighbor, path + [neighbor]))
                }
            }
        }
        return nil
    }

    func detectCycles() -> [[String]] {
        var cycles: [[String]] = []
        var visited: Set<String> = []
        var inStack: Set<String> = []
        var stack: [String] = []

        func dfs(_ nodeID: String) {
            visited.insert(nodeID)
            inStack.insert(nodeID)
            stack.append(nodeID)

            for neighbor in adjacency[nodeID] ?? [] {
                if !visited.contains(neighbor) {
                    dfs(neighbor)
                } else if inStack.contains(neighbor) {
                    if let startIdx = stack.firstIndex(of: neighbor) {
                        let cycle = Array(stack[startIdx...])
                        cycles.append(cycle)
                    }
                }
            }

            stack.removeLast()
            inStack.remove(nodeID)
        }

        for nodeID in nodes.keys where !visited.contains(nodeID) {
            dfs(nodeID)
        }
        return cycles
    }

    func calculateMetrics() -> GraphMetrics {
        let n = nodes.count
        let e = adjacency.values.reduce(0) { $0 + $1.count }
        let maxEdges = n > 1 ? n * (n - 1) : 1
        return GraphMetrics(
            nodeCount: n,
            edgeCount: e,
            density: Double(e) / Double(maxEdges),
            averageDegree: n > 0 ? Double(2 * e) / Double(n) : 0
        )
    }

    // MARK: - SwiftData Bridge

    func loadFromArchitecture(_ architecture: Architecture) {
        clear()
        for archNode in architecture.nodes {
            guard let type = NodeType(rawValue: archNode.nodeTypeRawValue) else { continue }
            addNode(id: archNode.id, type: type, x: archNode.positionX, y: archNode.positionY)
        }
        for conn in architecture.connections {
            adjacency[conn.sourceNodeID, default: []].insert(conn.targetNodeID)
        }
    }

    func syncToArchitecture(_ architecture: Architecture, context: ModelContext) {
        architecture.nodes.removeAll()
        architecture.connections.removeAll()

        for node in nodes.values {
            let archNode = ArchitectureNode(
                id: node.id,
                nodeTypeRawValue: node.type.rawValue,
                positionX: node.x,
                positionY: node.y,
                tierID: architecture.tierID
            )
            architecture.nodes.append(archNode)
        }

        for (sourceID, targets) in adjacency {
            for targetID in targets {
                let conn = NodeConnection(
                    sourceNodeID: sourceID,
                    targetNodeID: targetID,
                    tierID: architecture.tierID
                )
                architecture.connections.append(conn)
            }
        }

        try? context.save()
    }
}
