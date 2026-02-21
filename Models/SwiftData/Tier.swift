import Foundation
import SwiftData

@Model
final class Tier {
    @Attribute(.unique) var id: Int
    var name: String
    var unlocked: Bool
    var completed: Bool
    var score: Double
    var bestTime: TimeInterval?
    var attemptsCount: Int
    
    @Relationship(deleteRule: .cascade)
    var architectures: [Architecture]
    
    init(id: Int, name: String, unlocked: Bool = false) {
        self.id = id
        self.name = name
        self.unlocked = unlocked
        self.completed = false
        self.score = 0
        self.bestTime = nil
        self.attemptsCount = 0
        self.architectures = []
    }
}
