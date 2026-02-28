import SwiftUI
import SwiftData

struct InteriorView: View {
    let tierID: Int

    @State private var currentProblemIndex = 0
    @State private var timeLimitMinutes = InteriorConstants.timeLimitDefault
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tier.id) private var tiers: [Tier]

    private var level: String {
        InteriorConstants.levels[tierID] ?? "Unknown"
    }

    private var problems: [InteriorProblem] {
        InteriorContent.problems(for: tierID)
    }

    /// Best score for the currently visible problem, or nil if never attempted.
    private var currentProblemBestScore: Double? {
        guard let tier = tiers.first(where: { $0.id == tierID }) else { return nil }
        return tier.problemBestScores[currentProblemIndex]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background image - full screen
                backgroundImage(size: geo.size)

                // Content layered on top
                VStack(spacing: 0) {
                    // Title zone: fixed height, title below the navigation bar.
                    titleSection
                        .padding(.top, geo.safeAreaInsets.top + 16)
                        .frame(height: geo.safeAreaInsets.top + 120)

                    // Equal spacers around card group → card stays centered
                    // in the space below the title zone
                    Spacer()

                    cardSection

                    pageIndicator
                        .padding(.top, 16)

                    VStack(spacing: 12) {
                        enterButton

                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text("Exceed the time limit and you're drowned")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(Color.red)
                        .shadow(color: .black.opacity(0.3), radius: 2)

                        if let best = currentProblemBestScore {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 12))
                                Text("Best Score: \(Int(best))%")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.3), radius: 2)
                            .transition(.opacity)
                        }
                    }
                    .padding(.top, 24)
                    .animation(.easeInOut(duration: 0.25), value: currentProblemIndex)

                    Spacer()
                }
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }

    // MARK: - Background

    private func backgroundImage(size: CGSize) -> some View {
        Image(InteriorConstants.backgroundImages[tierID] ?? "interior_pond")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipped()
            .ignoresSafeArea()
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Interior \(level)")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Card Section (Swipeable)

    private var cardSection: some View {
        TabView(selection: $currentProblemIndex) {
            ForEach(Array(problems.enumerated()), id: \.element.id) { index, problem in
                InteriorGlassCard(
                    problem: problem,
                    timeLimitMinutes: $timeLimitMinutes
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 380)
        .animation(.easeInOut(duration: 0.3), value: currentProblemIndex)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< problems.count, id: \.self) { index in
                Circle()
                    .fill(index == currentProblemIndex ? .white : .white.opacity(0.35))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel("Problem \(currentProblemIndex + 1) of \(problems.count)")
    }

    // MARK: - Enter Button

    private var enterButton: some View {
        NavigationLink {
            BuilderView(
                tierID: tierID,
                selectedProblemIndex: currentProblemIndex,
                timeLimitMinutes: timeLimitMinutes
            )
        } label: {
            HStack(spacing: 8) {
                Text("Enter")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: InteriorConstants.enterButtonHeight)
        }
        .buttonStyle(.glass(.clear))
        .simultaneousGesture(TapGesture().onEnded {
            HapticManager.mediumImpact()
        })
        .accessibilityLabel("Enter builder")
        .accessibilityHint("Start building the \(problems[safe: currentProblemIndex]?.title ?? "selected") architecture")
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back to cities")
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
