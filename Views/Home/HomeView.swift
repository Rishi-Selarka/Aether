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
            VStack(spacing: 24) {
                // Top bar – settings aligned trailing
                GlassEffectContainer(spacing: 12) {
                    HStack {
                        Spacer()
                        settingsButton
                    }
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
                    },
                    onRefresh: {
                        Task {
                            question = nil
                            let fresh = await DailyContentService.loadFreshQuestion()
                            question = fresh
                        }
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
        .background {
            ZStack(alignment: .bottom) {
                Color.archsysBackground

                // Light blue sky gradient rising from the bottom
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.75, blue: 0.95).opacity(0.25),
                        Color(red: 0.60, green: 0.80, blue: 1.0).opacity(0.10),
                        Color.clear
                    ],
                    startPoint: .bottom,
                    endPoint: .init(x: 0.5, y: 0.55)
                )
            }
            .ignoresSafeArea()
        }
        .overlay(alignment: .center) {
            EmptyView() // reserve for future overlays
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onReset: onReset)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
                .presentationCornerRadius(30)
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
        }
        .buttonStyle(.glass)
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
