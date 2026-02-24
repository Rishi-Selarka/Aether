import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class BuilderViewModel {
    let tier: Tier
    var architecture: Architecture
    let graph: ArchitectureGraph
    let simulationEngine: SimulationEngine

    var selectedNodeID: String?
    var connectionFromID: String?
    var dragNodeType: NodeType?

    var simConfig: SimulationConfig {
        get { simulationEngine.config }
        set { simulationEngine.config = newValue }
    }

    var availableNodeTypes: [NodeType] {
        NodeType.allCases.filter { $0.tierLevel <= tier.id }
    }
    
    init(tier: Tier, architecture: Architecture, graph: ArchitectureGraph) {
        self.tier = tier
        self.architecture = architecture
        self.graph = graph
        self.simulationEngine = SimulationEngine(graph: graph)
    }
    
    func loadFromArchitecture() {
        graph.loadFromArchitecture(architecture)
    }
    
    func syncToSwiftData(context: ModelContext) {
        graph.syncToArchitecture(architecture, context: context)
    }
    
    func addNode(type: NodeType, at position: CGPoint) {
        let id = UUID().uuidString
        graph.addNode(id: id, type: type, x: position.x, y: position.y)
    }
    
    func removeNode(id: String) {
        graph.removeNode(id: id)
    }
    
    func updateNodePosition(id: String, x: Double, y: Double) {
        graph.updateNodePosition(id: id, x: x, y: y)
    }
    
    func tryCreateConnection(from sourceID: String, to targetID: String) -> Bool {
        graph.createConnection(sourceID: sourceID, targetID: targetID)
    }
    
    func canConnect(from sourceID: String, to targetID: String) -> Bool {
        guard let source = graph.node(for: sourceID),
              let target = graph.node(for: targetID) else { return false }
        return graph.validateConnection(sourceType: source.type, targetType: target.type)
    }
    
    func reset() {
        graph.clear()
    }

    func loadRecipe(_ recipe: ArchitectureRecipe) {
        graph.clear()
        let canvasSize = CGSize(width: 2000, height: 2000)
        let nodeCount = recipe.nodes.count
        let spacing: CGFloat = 180
        let startX = (canvasSize.width - CGFloat(nodeCount - 1) * spacing) / 2
        let centerY = canvasSize.height / 2

        var typeToID: [NodeType: String] = [:]
        for (index, nodeType) in recipe.nodes.enumerated() {
            let id = UUID().uuidString
            let x = startX + CGFloat(index) * spacing
            graph.addNode(id: id, type: nodeType, x: x, y: centerY)
            typeToID[nodeType] = id
        }

        for conn in recipe.connections {
            if let sourceID = typeToID[conn.source], let targetID = typeToID[conn.target] {
                _ = graph.createConnection(sourceID: sourceID, targetID: targetID)
            }
        }
    }
}
