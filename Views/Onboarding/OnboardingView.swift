import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startTime: Date?
    @State private var titleOpacity: Double = 0.0
    @State private var network = SplashNetwork.generate()
    @State private var hasCompleted = false

    private let fadeEnd = 3.6
    private let autoAdvanceDelay = 5.2

    var body: some View {
        SplashViewContent(
            startTime: $startTime,
            titleOpacity: $titleOpacity,
            network: network
        )
        .ignoresSafeArea()
        .onAppear {
            startTime = .now
            // Show text while network is still ~30% visible (dissolve runs 2.2→3.6)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                let animation: Animation? = reduceMotion ? nil : .easeOut(duration: 0.8)
                withAnimation(animation) {
                    titleOpacity = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + autoAdvanceDelay) {
                guard !hasCompleted else { return }
                hasCompleted = true
                onComplete()
            }
        }
    }
}

/// Reusable splash content for OnboardingView (logic extracted from SplashView).
struct SplashViewContent: View {
    @Binding var startTime: Date?
    @Binding var titleOpacity: Double
    let network: SplashNetwork

    @Environment(\.colorScheme) private var colorScheme

    private var edgeWhiteLevel: Double { colorScheme == .dark ? 0.40 : 0.55 }
    private var dotWhiteLevel: Double { colorScheme == .dark ? 0.75 : 0.25 }
    private var titleColor: Color { colorScheme == .dark ? Color(white: 0.95) : Color(white: 0.05) }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cx = size.width / 2
            let cy = size.height / 2

            ZStack {
                Color.aetherBackground.ignoresSafeArea()

                TimelineView(.animation) { timeline in
                    let t = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0
                    let edgeLevel = edgeWhiteLevel
                    let dotLevel = dotWhiteLevel
                    let subtitleFull = "The Abyss of Cities"
                    let subtitleStart = 3.3
                    let subtitleChars = t >= subtitleStart
                        ? min(Int((t - subtitleStart) / 0.065), subtitleFull.count)
                        : 0

                    ZStack {
                        Canvas { gfx, canvasSize in
                            SplashView.drawNetworkStatic(
                                gfx, t: t, size: canvasSize, cx: cx, cy: cy,
                                network: network,
                                edgeWhiteLevel: edgeLevel,
                                dotWhiteLevel: dotLevel
                            )
                        }
                        .frame(width: size.width, height: size.height)
                        .allowsHitTesting(false)

                        VStack(spacing: 10) {
                            Text("Aether")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .tracking(6)
                                .foregroundColor(titleColor)
                                .opacity(titleOpacity)

                            Text(String(subtitleFull.prefix(subtitleChars)))
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(titleColor.opacity(0.55))
                                .opacity(subtitleChars > 0 ? 1.0 : 0.0)
                        }
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
        }
    }
}
