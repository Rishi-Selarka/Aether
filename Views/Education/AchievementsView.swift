import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var progressList: [CityProgress]

    private var unlockedIDs: Set<String> {
        guard let progress = progressList.first else { return [] }
        return Set(progress.achievements)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 140), spacing: LayoutConstants.spacingM)
                ], spacing: LayoutConstants.spacingM) {
                    ForEach(Achievement.all) { achievement in
                        AchievementCard(
                            achievement: achievement,
                            isUnlocked: unlockedIDs.contains(achievement.id.rawValue)
                        )
                    }
                }
                .padding(LayoutConstants.spacingM)
            }
            .background(Color.archsysBackground)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: LayoutConstants.spacingS) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.color.opacity(0.3) : Color.archsysSurface)
                    .frame(width: 64, height: 64)
                Image(systemName: achievement.sfSymbol)
                    .font(.system(size: 28))
                    .foregroundStyle(isUnlocked ? achievement.color : Color.archsysTextTertiary)
            }
            Text(achievement.title)
                .font(Typography.bodyMedium)
                .foregroundStyle(isUnlocked ? Color.archsysTextPrimary : Color.archsysTextTertiary)
                .multilineTextAlignment(.center)
            Text(achievement.description)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(LayoutConstants.spacingM)
        .frame(maxWidth: .infinity)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
        .opacity(isUnlocked ? 1 : 0.7)
    }
}
