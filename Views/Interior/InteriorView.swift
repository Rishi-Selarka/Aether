import SwiftUI

struct InteriorView: View {
    let tierID: Int

    @State private var currentProblemIndex = 0
    @State private var timeLimitMinutes = InteriorConstants.timeLimitDefault
    @Environment(\.dismiss) private var dismiss

    private var level: String {
        InteriorConstants.levels[tierID] ?? "Unknown"
    }

    private var problems: [InteriorProblem] {
        InteriorContent.problems(for: tierID)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background image - full screen
                backgroundImage(size: geo.size)

                // Content layered on top
                VStack(spacing: 0) {
                    // Title zone: fixed height, title slightly below top
                    titleSection
                        .padding(.top, 170)
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
                    }
                    .padding(.top, 24)

                    Spacer()
                }
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
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
            Text("Enter")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: InteriorConstants.enterButtonHeight)
                .background {
                    RoundedRectangle(cornerRadius: InteriorConstants.enterButtonCornerRadius)
                        .fill(.black.opacity(0.25))
                        .background {
                            RoundedRectangle(cornerRadius: InteriorConstants.enterButtonCornerRadius)
                                .fill(.ultraThinMaterial)
                                .opacity(0.5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: InteriorConstants.enterButtonCornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: InteriorConstants.enterButtonCornerRadius)
                                .strokeBorder(.white.opacity(0.2), lineWidth: InteriorConstants.cardBorderWidth)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
                }
        }
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
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel("Back to map")
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
