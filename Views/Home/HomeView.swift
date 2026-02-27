import SwiftUI

/// Home screen — scrollable when content exceeds viewport.
/// Shows stats, daily challenge, and Dare to Dive CTA with quote.
struct HomeView: View {
    @Environment(TierStatsCache.self) private var statsCache
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showSettings = false

    // Daily content
    @State private var quote: DailyQuote?
    @State private var question: DailyQuestion?

    let onDareToDive: () -> Void
    var onReset: (() -> Void)? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                // Settings row – right-aligned
                HStack {
                    Spacer()
                    settingsButton
                }

                // Metrics card
                StatsCardView()

                // Dare to Dive CTA with GIF
                DareToDiveCard(onTap: onDareToDive)

                // Daily Challenge
                QuestionOfTheDayCard(
                    question: question,
                    onAnswer: { index in
                        DailyContentService.saveAnswer(selectedIndex: index)
                    }
                )

                // Quote — plain text, no card, no author
                if let quoteText = quote?.text, !quoteText.isEmpty {
                    Text(quoteText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.archsysTextTertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.archsysBackground)
        .overlay(alignment: .center) {
            EmptyView() // reserve for future overlays
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onReset: onReset)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(32)
        }
        .task {
            await loadDailyContent()
        }
    }

    // MARK: - Settings

    private var settingsButton: some View {
        Button {
            HapticManager.lightImpact()
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.archsysTextSecondary)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                }
        }
        .accessibilityLabel("Settings")
        .accessibilityHint("Open settings")
    }

    // MARK: - Data Loading

    private func loadDailyContent() async {
        async let q = DailyContentService.loadQuote()
        async let qn = DailyContentService.loadQuestion()
        let (loadedQuote, loadedQuestion) = await (q, qn)
        quote = loadedQuote
        question = loadedQuestion
    }
}
