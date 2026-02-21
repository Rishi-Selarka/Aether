import Foundation
import SwiftData

@Model
final class ArchitectureNode {
    @Attribute(.unique) var id: String
    var nodeTypeRawValue: String
    var positionX: Double
    var positionY: Double
    var tierID: Int
    var createdAt: Date
    
    init(id: String = UUID().uuidString, nodeTypeRawValue: String, positionX: Double, positionY: Double, tierID: Int) {
        self.id = id
        self.nodeTypeRawValue = nodeTypeRawValue
        self.positionX = positionX
        self.positionY = positionY
        self.tierID = tierID
        self.createdAt = Date()
    }
}
