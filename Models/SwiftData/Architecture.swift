import Foundation
import SwiftData

@Model
final class Architecture {
    @Attribute(.unique) var id: String
    var createdAt: Date
    var modifiedAt: Date
    var isActive: Bool
    var tierID: Int
    
    @Relationship(deleteRule: .cascade)
    var nodes: [ArchitectureNode]
    
    @Relationship(deleteRule: .cascade)
    var connections: [NodeConnection]
    
    init(id: String = UUID().uuidString, tierID: Int) {
        self.id = id
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isActive = true
        self.tierID = tierID
        self.nodes = []
        self.connections = []
    }
}
