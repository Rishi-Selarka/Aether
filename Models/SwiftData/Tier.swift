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
    /// Number of times this tier has been passed (score ≥ 75%).
    var passCount: Int
    /// Best score per problem index (0, 1, 2). Key = problem index, Value = best score %.
    var problemBestScores: [Int: Double]

    init(id: Int, name: String, unlocked: Bool = false) {
        self.id = id
        self.name = name
        self.unlocked = unlocked
        self.completed = false
        self.score = 0
        self.bestTime = nil
        self.attemptsCount = 0
        self.passCount = 0
        self.problemBestScores = [:]
    }
}
