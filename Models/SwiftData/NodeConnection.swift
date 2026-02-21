import Foundation
import SwiftData

@Model
final class NodeConnection {
    @Attribute(.unique) var id: String
    var sourceNodeID: String
    var targetNodeID: String
    var tierID: Int
    var createdAt: Date
    
    init(id: String = UUID().uuidString, sourceNodeID: String, targetNodeID: String, tierID: Int) {
        self.id = id
        self.sourceNodeID = sourceNodeID
        self.targetNodeID = targetNodeID
        self.tierID = tierID
        self.createdAt = Date()
    }
}
