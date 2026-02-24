import Foundation
import SwiftData

@Model
final class CityProgress {
    var currentTierID: Int
    var unlockedTierIDs: [Int]
    var completedTierIDs: [Int]
    var achievements: [String]
    var simulationRunCount: Int
    var lastPlayedDate: Date
    
    @Relationship(deleteRule: .cascade)
    var tiers: [Tier]
    
    init(currentTierID: Int = 1) {
        self.currentTierID = currentTierID
        self.unlockedTierIDs = [1]
        self.completedTierIDs = []
        self.achievements = []
        self.simulationRunCount = 0
        self.lastPlayedDate = Date()
        self.tiers = []
    }
}
