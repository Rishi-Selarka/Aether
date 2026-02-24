import Foundation
import SwiftData

@MainActor
enum ProgressTracker {

    static func unlockFirstBlueprintIfNeeded(graph: ArchitectureGraph, context: ModelContext) {
        let hasStructure = graph.allNodes.count >= 2 && !graph.allConnections.isEmpty
        guard hasStructure else { return }
        SwiftDataManager.unlockAchievement(AchievementID.firstBlueprint.rawValue, context: context)
    }

    static func unlockCleanConnectionsIfNeeded(antiPatternCount: Int, context: ModelContext) {
        guard antiPatternCount == 0 else { return }
        SwiftDataManager.unlockAchievement(AchievementID.cleanConnections.rawValue, context: context)
    }

    static func unlockFlowStateIfNeeded(context: ModelContext) {
        guard let progress = SwiftDataManager.fetchProgress(context: context) else { return }
        progress.simulationRunCount += 1
        if progress.simulationRunCount >= 10 {
            SwiftDataManager.unlockAchievement(AchievementID.flowState.rawValue, context: context)
        }
        try? context.save()
    }

    static func unlockArchitectMasterIfNeeded(completedTierIDs: [Int], context: ModelContext) {
        guard completedTierIDs.contains(5) else { return }
        SwiftDataManager.unlockAchievement(AchievementID.architectMaster.rawValue, context: context)
    }

    static func unlockSpeedDemonIfNeeded(tierID: Int, performance: Double, context: ModelContext) {
        guard tierID == 3, performance >= 80 else { return }
        SwiftDataManager.unlockAchievement(AchievementID.speedDemon.rawValue, context: context)
    }

    static func unlockBulletproofIfNeeded(tierID: Int, resilience: Double, context: ModelContext) {
        guard tierID == 4, resilience >= 80 else { return }
        SwiftDataManager.unlockAchievement(AchievementID.bulletproof.rawValue, context: context)
    }
}
