import Foundation
import SwiftUI

@MainActor
@Observable
final class SimulationEngine {
    let graph: ArchitectureGraph
    var config: SimulationConfig
    
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var path: [String] = []
    private(set) var events: [SimulationEvent] = []
    private(set) var particles: [Particle] = []
    private(set) var metrics = SimulationMetrics()
    private(set) var processingNodeIDs: Set<String> = []
    
    init(graph: ArchitectureGraph, config: SimulationConfig = .default) {
        self.graph = graph
        self.config = config
    }
    
    /// Find a path from a root node (e.g. UI) to a leaf (e.g. Database)
    func findRunnablePath() -> [String]? {
        let roots = graph.rootNodeIDs()
        let leaves = graph.leafNodeIDs()
        guard !roots.isEmpty, !leaves.isEmpty else { return nil }

        for rootID in roots {
            for leafID in leaves where rootID != leafID {
                if let p = graph.findPath(from: rootID, to: leafID), p.count >= 2 {
                    return p
                }
            }
        }
        return nil
    }
    
    func run() async {
        guard let p = findRunnablePath(), !p.isEmpty else { return }
        path = p
        isRunning = true
        isPaused = false
        events = []
        particles = []
        metrics = SimulationMetrics()
        
        let operation = config.operationType
        
        for i in 0..<(path.count - 1) {
            let sourceID = path[i]
            let targetID = path[i + 1]
            
            processingNodeIDs = [sourceID]
            
            let event = SimulationEvent(
                timestamp: Double(i) * config.networkLatency,
                operation: operation,
                sourceNodeID: sourceID,
                targetNodeID: targetID,
                message: "\(operation.displayName) from \(sourceID.prefix(8)) to \(targetID.prefix(8))"
            )
            events.append(event)
            metrics.operationsCount += 1
            metrics.totalLatency += config.networkLatency
            
            if config.failureMode && Double.random(in: 0...1) < 0.2 {
                metrics.failures += 1
            } else if config.cacheEnabled && path.contains(where: { id in
                let cacheTypes: [NodeType] = [.memoryCache, .networkCache, .imageCache]
                return graph.node(for: id).map { cacheTypes.contains($0.type) } ?? false
            }) {
                metrics.cacheHits += 1
            }
            
            if let source = graph.node(for: sourceID), graph.node(for: targetID) != nil {
                let particle = Particle(
                    type: .primary,
                    sourceNodeID: sourceID,
                    targetNodeID: targetID,
                    startPosition: CGPoint(x: source.x, y: source.y)
                )
                particles.append(particle)
                let particleIndex = particles.count - 1
                let stepCount = 20
                let stepDuration = config.networkLatency / Double(stepCount) / config.playbackSpeed
                for step in 1...stepCount {
                    try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                    if particleIndex < particles.count {
                        particles[particleIndex].progress = Double(step) / Double(stepCount)
                    }
                }
            } else {
                try? await Task.sleep(nanoseconds: UInt64(config.networkLatency * 1_000_000_000 / config.playbackSpeed))
            }
        }
        
        processingNodeIDs = []
        isRunning = false
    }
    
    func stop() {
        isRunning = false
        isPaused = false
    }
    
}
