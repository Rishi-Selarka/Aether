import Foundation
import SwiftUI

enum OperationType: String, Codable, CaseIterable, Sendable {
    case read
    case write
    case sync

    var displayName: String {
        switch self {
        case .read: return "Read"
        case .write: return "Write"
        case .sync: return "Sync"
        }
    }

    var particleColor: Color {
        switch self {
        case .read: return .blue
        case .write: return .teal
        case .sync: return .purple
        }
    }
}

enum ParticleType: String, Codable, Sendable {
    case primary
    case secondary
    case ambient

    var size: CGFloat {
        switch self {
        case .primary: return 12
        case .secondary: return 6
        case .ambient: return 4
        }
    }
}

struct SimulationConfig: Sendable {
    var operationType: OperationType
    var networkLatency: TimeInterval
    var failureMode: Bool
    var cacheEnabled: Bool
    var playbackSpeed: Double

    static let `default` = SimulationConfig(
        operationType: .read,
        networkLatency: 0.5,
        failureMode: false,
        cacheEnabled: true,
        playbackSpeed: 1.0
    )
}

struct SimulationEvent: Identifiable, Sendable {
    let id: String
    let timestamp: TimeInterval
    let operation: OperationType
    let sourceNodeID: String
    let targetNodeID: String?
    let message: String

    init(timestamp: TimeInterval, operation: OperationType,
         sourceNodeID: String, targetNodeID: String? = nil, message: String) {
        self.id = UUID().uuidString
        self.timestamp = timestamp
        self.operation = operation
        self.sourceNodeID = sourceNodeID
        self.targetNodeID = targetNodeID
        self.message = message
    }
}

struct SimulationMetrics: Sendable {
    var operationsCount: Int = 0
    var totalLatency: TimeInterval = 0
    var cacheHits: Int = 0
    var failures: Int = 0
    var retries: Int = 0

    var successRate: Double {
        guard operationsCount > 0 else { return 0 }
        return Double(operationsCount - failures) / Double(operationsCount)
    }
}

struct Particle: Identifiable, Sendable {
    let id: String
    let type: ParticleType
    var position: CGPoint
    let sourceNodeID: String
    let targetNodeID: String
    var progress: Double
    var trailHistory: [CGPoint]
    var opacity: Double

    init(type: ParticleType, sourceNodeID: String, targetNodeID: String,
         startPosition: CGPoint) {
        self.id = UUID().uuidString
        self.type = type
        self.position = startPosition
        self.sourceNodeID = sourceNodeID
        self.targetNodeID = targetNodeID
        self.progress = 0
        self.trailHistory = []
        self.opacity = 1.0
    }
}
