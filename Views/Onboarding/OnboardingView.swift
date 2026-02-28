import SwiftUI

// MARK: - Flow Controller

struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Phase = .splash

    private enum Phase { case splash, slides }

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashPhaseView {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.55)) {
                        phase = .slides
                    }
                }
                .transition(.opacity)
                .zIndex(0)
            case .slides:
                OnboardingSlidesView(onComplete: onComplete)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Splash Phase

private struct SplashPhaseView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startTime: Date?
    @State private var titleOpacity: Double = 0.0
    @State private var network = SplashNetwork.generate()
    @State private var didComplete = false

    var body: some View {
        SplashViewContent(startTime: $startTime, titleOpacity: $titleOpacity, network: network)
            .ignoresSafeArea()
            .onAppear {
                startTime = .now
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    let anim: Animation? = reduceMotion ? nil : .easeOut(duration: 0.8)
                    withAnimation(anim) { titleOpacity = 1.0 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
                    guard !didComplete else { return }
                    didComplete = true
                    onComplete()
                }
            }
    }
}

// MARK: - Splash Content

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

// MARK: - Page Model

private struct OnboardingPage: Sendable {
    let imageName: String
    let tag: String
    let headline: String
    let body: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        imageName: "onboarding_cities",
        tag: "EXPLORE",
        headline: "The Abyss\nof Cities",
        body: "Journey through iconic cities — each one a deeper plunge into architectural complexity. Unlock tiers. Conquer challenges."
    ),
    OnboardingPage(
        imageName: "onboarding_canvas",
        tag: "ARCHITECT",
        headline: "Build on\nthe Canvas",
        body: "Drag blocks, forge connections, validate your design against real patterns. Think and build like a software architect."
    ),
    OnboardingPage(
        imageName: "onboarding_challenge",
        tag: "MASTER",
        headline: "A Challenge\nEvery Day",
        body: "A fresh architecture puzzle awaits each morning. Build your streak, sharpen your instincts, rise above the abyss."
    ),
]

// MARK: - Slides Container

private struct OnboardingSlidesView: View {
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentPage = 0
    @State private var contentVisible = false
    @State private var animationTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                imageCarousel(size: geo.size)
                    .ignoresSafeArea()

                gradientScrim
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                bottomContent(geo: geo)
                    .allowsHitTesting(false)

                actionButton
                    .padding(.horizontal, 30)
                    .padding(.bottom, max(geo.safeAreaInsets.bottom, 20) + 8)
            }
        }
        .ignoresSafeArea()
        .onAppear { animateContent() }
        .onChange(of: currentPage) { _, _ in animateContent() }
    }

    // MARK: Image Carousel

    private func imageCarousel(size: CGSize) -> some View {
        let topCrop: CGFloat = 60
        return TabView(selection: $currentPage) {
            ForEach(onboardingPages.indices, id: \.self) { index in
                Image(onboardingPages[index].imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height + topCrop)
                    .frame(width: size.width, height: size.height, alignment: .bottom)
                    .clipped()
                    .ignoresSafeArea()
                    .tag(index)
                    .accessibilityLabel(onboardingPages[index].headline)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    // MARK: Gradient

    private var gradientScrim: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black.opacity(0.10), location: 0.30),
                .init(color: .black.opacity(0.65), location: 0.60),
                .init(color: .black.opacity(0.96), location: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Bottom Content

    private func bottomContent(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                tagLabel
                    .padding(.bottom, 8)
                headlineText
                    .padding(.bottom, 14)
                bodyText
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)

            pageIndicator
                .padding(.bottom, 22)

            Color.clear
                .frame(height: 52 + max(geo.safeAreaInsets.bottom, 20) + 8)
        }
        .opacity(contentVisible ? 1 : 0)
        .offset(y: contentVisible ? 0 : 16)
    }

    // MARK: Text Components

    private var tagLabel: some View {
        Text(onboardingPages[currentPage].tag)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.50))
            .tracking(3.5)
    }

    private var headlineText: some View {
        Text(onboardingPages[currentPage].headline)
            .font(.system(size: 38, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var bodyText: some View {
        Text(onboardingPages[currentPage].body)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.white.opacity(0.68))
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 7) {
            ForEach(onboardingPages.indices, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.28))
                    .frame(width: currentPage == index ? 24 : 7, height: 7)
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.7),
                        value: currentPage
                    )
            }
        }
    }

    // MARK: Action Button

    private var actionButton: some View {
        let isLast = currentPage == onboardingPages.count - 1
        return Button {
            HapticManager.mediumImpact()
            if isLast {
                onComplete()
            } else {
                let anim: Animation? = reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.78)
                withAnimation(anim) { currentPage += 1 }
            }
        } label: {
            HStack(spacing: 8) {
                Text(isLast ? "Enter the Abyss" : "Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                if !isLast {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white.opacity(0.80))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.glass(.clear))
        .animation(reduceMotion ? nil : .spring(response: 0.35), value: isLast)
        .accessibilityLabel(isLast ? "Enter the Abyss" : "Continue to next page")
    }

    // MARK: Helpers

    private func animateContent() {
        animationTask?.cancel()
        if reduceMotion {
            contentVisible = true
            return
        }
        contentVisible = false
        animationTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.42)) {
                contentVisible = true
            }
        }
    }
}
