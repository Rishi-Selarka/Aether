import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showOnboarding = true

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(onComplete: { dismissOnboarding() })
                    .transition(.opacity)
            } else {
                MainContentView()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            SwiftDataManager.initializeIfNeeded(context: modelContext)
        }
    }

    private func dismissOnboarding() {
        let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.8)
        withAnimation(animation) {
            showOnboarding = false
        }
    }
}

struct MainContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var tierStatsCache = TierStatsCache()

    var body: some View {
        NavigationStack {
            TierMapView()
        }
        .environment(tierStatsCache)
        .onAppear {
            hydrateStatsCache()
        }
    }

    private func hydrateStatsCache() {
        let descriptor = FetchDescriptor<Tier>(sortBy: [SortDescriptor(\.id)])
        guard let tiers = try? modelContext.fetch(descriptor) else { return }
        var attempts: [Int: Int] = [:]
        var scores: [Int: [Int: Double]] = [:]
        var scoresWithDate: [Int: [Int: ScoreRecord]] = [:]
        for tier in tiers {
            attempts[tier.id] = tier.attemptsCount
            scores[tier.id] = tier.problemBestScores
            scoresWithDate[tier.id] = tier.problemBestScoresWithDate()
        }
        tierStatsCache.hydrate(
            attemptsByTier: attempts,
            bestScoresByTier: scores,
            bestScoresWithDateByTier: scoresWithDate
        )
    }
}
