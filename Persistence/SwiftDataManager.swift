import Foundation
import SwiftData

@MainActor
enum SwiftDataManager {
    
    static func initializeIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<CityProgress>()
        
        if (try? context.fetch(descriptor).first) == nil {
            let progress = CityProgress()
            context.insert(progress)

            let tiers = [
                Tier(id: 1, name: "Local Data Village", unlocked: true),
                Tier(id: 2, name: "Connected Town", unlocked: true),
                Tier(id: 3, name: "Performance Peak", unlocked: true),
                Tier(id: 4, name: "Resilient Fortress", unlocked: true),
                Tier(id: 5, name: "Smart City", unlocked: true)
            ]

            for tier in tiers {
                context.insert(tier)
                progress.tiers.append(tier)
            }

            try? context.save()
        } else {
            ensureAllTiersUnlocked(context: context)
        }
    }

    /// Ensures all tiers are unlocked for free exploration (migration for existing installs).
    static func ensureAllTiersUnlocked(context: ModelContext) {
        let descriptor = FetchDescriptor<Tier>()
        guard let tiers = try? context.fetch(descriptor) else { return }
        var changed = false
        for tier in tiers where !tier.unlocked {
            tier.unlocked = true
            changed = true
        }
        if changed { try? context.save() }
    }
    
    static func fetchProgress(context: ModelContext) -> CityProgress? {
        let descriptor = FetchDescriptor<CityProgress>()
        return try? context.fetch(descriptor).first
    }
    
    static func fetchTier(id: Int, context: ModelContext) -> Tier? {
        var descriptor = FetchDescriptor<Tier>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
    
    static func unlockTier(id: Int, context: ModelContext) {
        guard let progress = fetchProgress(context: context),
              let tier = fetchTier(id: id, context: context) else { return }
        
        tier.unlocked = true
        if !progress.unlockedTierIDs.contains(id) {
            progress.unlockedTierIDs.append(id)
        }
        try? context.save()
    }
    
    static func completeTier(id: Int, score: Double, time: TimeInterval?, context: ModelContext) {
        guard let progress = fetchProgress(context: context),
              let tier = fetchTier(id: id, context: context) else { return }
        
        tier.completed = true
        tier.score = max(tier.score, score)
        
        if let time {
            tier.bestTime = tier.bestTime.map { min($0, time) } ?? time
        }
        
        if !progress.completedTierIDs.contains(id) {
            progress.completedTierIDs.append(id)
        }
        
        if id < 5 {
            unlockTier(id: id + 1, context: context)
        }
        
        try? context.save()
    }
    
    static func unlockAchievement(_ achievement: String, context: ModelContext) {
        guard let progress = fetchProgress(context: context),
              !progress.achievements.contains(achievement) else { return }
        
        progress.achievements.append(achievement)
        try? context.save()
    }
    
    /// Demo mode: reset all progress and reinitialize fresh state.
    static func resetAll(context: ModelContext) {
        let progressDescriptor = FetchDescriptor<CityProgress>()
        let tierDescriptor = FetchDescriptor<Tier>()
        let attemptDescriptor = FetchDescriptor<QuizAttempt>()
        guard let progressList = try? context.fetch(progressDescriptor),
              let tierList = try? context.fetch(tierDescriptor) else { return }
        let attemptList = (try? context.fetch(attemptDescriptor)) ?? []
        for p in progressList { context.delete(p) }
        for t in tierList { context.delete(t) }
        for a in attemptList { context.delete(a) }
        try? context.save()
        initializeIfNeeded(context: context)
    }

    // MARK: - Quiz Attempt Recording

    /// Records a passing quiz attempt: increments passCount, marks tier completed.
    static func recordPass(tierID: Int, score: Double = 0, context: ModelContext) {
        guard let tier = fetchTier(id: tierID, context: context) else { return }
        tier.passCount += 1
        tier.attemptsCount += 1
        tier.completed = true
        if score > tier.score { tier.score = score }
        if let progress = fetchProgress(context: context),
           !progress.completedTierIDs.contains(tierID) {
            progress.completedTierIDs.append(tierID)
        }
        try? context.save()
    }

    /// Records a failed quiz attempt: increments attemptsCount only.
    static func recordAttempt(tierID: Int, score: Double = 0, context: ModelContext) {
        guard let tier = fetchTier(id: tierID, context: context) else { return }
        tier.attemptsCount += 1
        if score > tier.score { tier.score = score }
        try? context.save()
    }

    /// Fetches all quiz attempts, sorted by most recent first.
    static func fetchAllAttempts(context: ModelContext) -> [QuizAttempt] {
        let descriptor = FetchDescriptor<QuizAttempt>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetches quiz attempts for a specific tier, sorted by most recent first.
    static func fetchAttempts(tierID: Int, context: ModelContext) -> [QuizAttempt] {
        let descriptor = FetchDescriptor<QuizAttempt>(
            predicate: #Predicate { $0.tierID == tierID },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
