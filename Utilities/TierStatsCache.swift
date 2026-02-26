import Foundation

/// In-memory cache for StatsCardView. Bypasses SwiftData fetch so metrics update
/// immediately when saves happen (avoids ModelContext/Query refresh issues in Playgrounds).
@Observable
final class TierStatsCache {
    /// attemptsCount per tier ID
    private(set) var attemptsByTier: [Int: Int] = [:]
    /// problemIndex -> best score (percent)
    private(set) var bestScoresByTier: [Int: [Int: Double]] = [:]
    /// problemIndex -> (score, date) for "Best Today" filtering
    private(set) var bestScoresWithDateByTier: [Int: [Int: ScoreRecord]] = [:]

    // MARK: - Display Values (computed)

    var citiesPassed: String {
        let count = bestScoresByTier.values.flatMap { $0.values }.filter { $0 >= 75 }.count
        return "\(min(count, 15))/15"
    }

    var totalAttempts: String {
        "\(attemptsByTier.values.reduce(0, +))"
    }

    /// Best score achieved today across all problems. Short label: "Best Today".
    var bestScoreToday: String {
        let calendar = Calendar.current
        let todayScores = bestScoresWithDateByTier.values.flatMap { $0.values }
            .filter { calendar.isDateInToday($0.date) }
            .map(\.score)
        let best = todayScores.max() ?? 0
        guard best > 0 else { return "-" }
        return "\(Int(best))%"
    }

    // MARK: - Updates (call after SwiftData save)

    func incrementAttempts(tierID: Int) {
        attemptsByTier[tierID, default: 0] += 1
    }

    func updateBestScore(tierID: Int, problemIndex: Int, score: Double) {
        var tierScores = bestScoresByTier[tierID] ?? [:]
        let current = tierScores[problemIndex] ?? 0
        if score > current {
            tierScores[problemIndex] = score
            bestScoresByTier[tierID] = tierScores
        }
        var tierWithDate = bestScoresWithDateByTier[tierID] ?? [:]
        if score > (tierWithDate[problemIndex]?.score ?? 0) {
            tierWithDate[problemIndex] = ScoreRecord(score: score, date: Date())
            bestScoresWithDateByTier[tierID] = tierWithDate
        }
    }

    /// Hydrate from SwiftData on launch. Call once after initializeIfNeeded.
    func hydrate(
        attemptsByTier: [Int: Int],
        bestScoresByTier: [Int: [Int: Double]],
        bestScoresWithDateByTier: [Int: [Int: ScoreRecord]] = [:]
    ) {
        self.attemptsByTier = attemptsByTier
        self.bestScoresByTier = bestScoresByTier
        self.bestScoresWithDateByTier = bestScoresWithDateByTier
    }
}
