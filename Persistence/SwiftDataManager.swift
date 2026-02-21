import Foundation
import SwiftData

@MainActor
enum SwiftDataManager {
    
    static func initializeIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<CityProgress>()
        
        guard (try? context.fetch(descriptor).first) == nil else {
            return
        }
        
        let progress = CityProgress()
        context.insert(progress)
        
        let tiers = [
            Tier(id: 1, name: "Local Data Village", unlocked: true),
            Tier(id: 2, name: "Connected Town", unlocked: false),
            Tier(id: 3, name: "Performance Peak", unlocked: false),
            Tier(id: 4, name: "Resilient Fortress", unlocked: false),
            Tier(id: 5, name: "Smart City", unlocked: false)
        ]
        
        for tier in tiers {
            context.insert(tier)
            progress.tiers.append(tier)
        }
        
        try? context.save()
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
}
