import Foundation
import SwiftUI


enum AchievementID: String, CaseIterable {
    case firstBlueprint = "first-blueprint"
    case cleanConnections = "clean-connections"
    case speedDemon = "speed-demon"
    case bulletproof = "bulletproof"
    case architectMaster = "architect-master"
    case perfectionist = "perfectionist"
    case patternDetective = "pattern-detective"
    case quickLearner = "quick-learner"
    case precisionBuilder = "precision-builder"
    case flowState = "flow-state"
}

struct Achievement: Identifiable {
    let id: AchievementID
    let title: String
    let description: String
    let sfSymbol: String
    let color: Color

    static let all: [Achievement] = [
        Achievement(id: .firstBlueprint, title: "First Blueprint", description: "Built your first architecture", sfSymbol: "pencil.and.outline", color: .blue),
        Achievement(id: .cleanConnections, title: "Clean Connections", description: "No anti-patterns detected", sfSymbol: "checkmark.circle.fill", color: .green),
        Achievement(id: .speedDemon, title: "Speed Demon", description: "Optimized architecture in Tier 3", sfSymbol: "hare.fill", color: .yellow),
        Achievement(id: .bulletproof, title: "Bulletproof", description: "Handled failures in Tier 4", sfSymbol: "shield.fill", color: .red),
        Achievement(id: .architectMaster, title: "Architect Master", description: "Completed all 5 tiers", sfSymbol: "star.fill", color: .purple),
        Achievement(id: .perfectionist, title: "Perfectionist", description: "Perfect score in all tiers", sfSymbol: "crown.fill", color: .orange),
        Achievement(id: .patternDetective, title: "Pattern Detective", description: "Found and fixed 5 anti-patterns", sfSymbol: "magnifyingglass", color: .cyan),
        Achievement(id: .quickLearner, title: "Quick Learner", description: "Completed without tutorial", sfSymbol: "lightbulb.fill", color: .mint),
        Achievement(id: .precisionBuilder, title: "Precision Builder", description: "Built architecture in under 2 minutes", sfSymbol: "clock.fill", color: .teal),
        Achievement(id: .flowState, title: "Flow State", description: "Ran 10 simulations", sfSymbol: "waveform.path.ecg", color: .pink)
    ]

    static func achievement(for id: AchievementID) -> Achievement {
        guard let found = all.first(where: { $0.id == id }) else {
            assertionFailure("Achievement missing for ID: \(id.rawValue)")
            return all[0]
        }
        return found
    }

    static func achievement(for rawID: String) -> Achievement? {
        guard let id = AchievementID(rawValue: rawID) else { return nil }
        return achievement(for: id)
    }
}
