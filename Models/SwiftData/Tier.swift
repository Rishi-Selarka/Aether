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
    /// Best score per problem with date. Stored as JSON Data for SwiftData persistence.
    /// Enables "Best Today" (scores achieved today) and all-time best.
    var problemBestScoresData: Data?

    init(id: Int, name: String, unlocked: Bool = false) {
        self.id = id
        self.name = name
        self.unlocked = unlocked
        self.completed = false
        self.score = 0
        self.bestTime = nil
        self.attemptsCount = 0
        self.passCount = 0
        self.problemBestScoresData = Tier.encodeScoresWithDate([Int: ScoreRecord]())
    }
}

// MARK: - problemBestScores Access

extension Tier {

    /// All-time best score per problem index (for Passed count, InteriorView).
    var problemBestScores: [Int: Double] {
        get {
            let withDate = Tier.decodeScoresWithDate(problemBestScoresData ?? Data())
            return Dictionary(uniqueKeysWithValues: withDate.map { ($0.key, $0.value.score) })
        }
        set {
            let existing = Tier.decodeScoresWithDate(problemBestScoresData ?? Data())
            // Start with all existing records so partial updates don't wipe unrelated keys.
            var updated = existing
            for (k, score) in newValue {
                let oldRecord = existing[k]
                let date: Date
                if let old = oldRecord, abs(old.score - score) < 0.01 {
                    date = old.date
                } else {
                    date = Date()
                }
                updated[k] = ScoreRecord(score: score, date: date)
            }
            problemBestScoresData = Tier.encodeScoresWithDate(updated)
        }
    }

    /// (problemIndex, score, date) for "Best Today" filtering.
    func problemBestScoresWithDate() -> [Int: ScoreRecord] {
        Tier.decodeScoresWithDate(problemBestScoresData ?? Data())
    }

    private static func encodeScoresWithDate(_ dict: [Int: ScoreRecord]) -> Data {
        let stringKeyed = Dictionary(uniqueKeysWithValues: dict.map { ("\($0.key)", $0.value) })
        return (try? JSONEncoder().encode(stringKeyed)) ?? Data()
    }

    private static func decodeScoresWithDate(_ data: Data) -> [Int: ScoreRecord] {
        guard !data.isEmpty else { return [:] }
        guard let stringKeyed = try? JSONDecoder().decode([String: ScoreRecord].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: stringKeyed.compactMap { key, value in
            guard let k = Int(key) else { return nil }
            return (k, value)
        })
    }
}
