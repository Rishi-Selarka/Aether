import SwiftUI

/// Full-screen analysis shown after completing all block quizzes.
/// Section 1 (fixed, top 35%): Export/Done buttons + score ring + status + concepts.
/// Section 2 (scrollable, bottom 65%): Per-question result cards + reattempt button.
struct AnalysisView: View {
    let session: QuizSession
    let analysisTexts: [String]
    let tierName: String
    let onDone: () -> Void
    let onReattempt: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    @State private var waterLevel: CGFloat = 0
    @State private var showDrownedText = false
    @State private var particleOpacity: Double = 0
    @State private var isExporting = false

    private let results: [QuizResult]

    init(
        session: QuizSession,
        analysisTexts: [String],
        tierName: String,
        onDone: @escaping () -> Void,
        onReattempt: @escaping () -> Void
    ) {
        self.session = session
        self.analysisTexts = analysisTexts
        self.tierName = tierName
        self.onDone = onDone
        self.onReattempt = onReattempt
        self.results = session.results()
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                // Drowning water — fades out as content appears
                if !session.passed {
                    drowningWaterOverlay
                        .opacity(showContent ? 0 : 1)
                        .animation(.easeOut(duration: 0.6), value: showContent)
                }

                // Success glow
                if session.passed {
                    successGlowOverlay
                }

                // Main layout
                VStack(spacing: 0) {
                    section1
                        .frame(height: geo.size.height * 0.35)
                    section2
                }
                .opacity(showContent ? 1 : 0)

                // Drowned text — also fades out as content appears
                if !session.passed && showDrownedText && !showContent {
                    drownedOverlay
                }
            }
        }
        .navigationBarHidden(true)
        .environment(\.colorScheme, .dark)
        .onAppear { runEntranceAnimation() }
    }

    // MARK: - Section 1: Fixed Header (35% of screen)

    private var section1: some View {
        VStack(spacing: 0) {
            // Buttons: Export (leading) | Done (trailing)
            HStack(spacing: 12) {
                Button {
                    isExporting = true
                    Task {
                        await ArchitectureExportService.exportAndShare(
                            session: session,
                            tierName: tierName,
                            onComplete: { isExporting = false }
                        )
                    }
                } label: {
                    HStack(spacing: 6) {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text("Export")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background { Capsule().fill(.white.opacity(0.12)) }
                }
                .disabled(isExporting)
                .accessibilityLabel("Export architecture analysis as PDF")

                Spacer()

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onDone()
                    }
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background { Capsule().fill(.white.opacity(0.12)) }
                }
                .accessibilityLabel("Done - return to city map")
            }
            .padding(.top, 54)
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            // Score ring (left) + status & concepts (right)
            HStack(alignment: .center, spacing: 20) {
                scoreRing
                    .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 10) {
                    passFailBadge
                    conceptChips
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            Divider()
                .opacity(0.15)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
        }
    }

    // MARK: - Score Ring

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.1), lineWidth: 10)

            Circle()
                .trim(from: 0, to: showContent ? CGFloat(session.scorePercent / 100) : 0)
                .stroke(
                    LinearGradient(
                        colors: session.passed ? [.green, .mint] : [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2).delay(0.3), value: showContent)

            VStack(spacing: 2) {
                Text("\(Int(session.scorePercent))%")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("\(session.totalCorrect)/\(session.totalQuestions)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Pass/Fail Badge

    private var passFailBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: session.passed ? "checkmark.shield.fill" : "drop.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(session.passed ? .green : .blue)

            Text(session.passed ? "Survived \(tierName)" : "Drowned")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(session.passed ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                .overlay {
                    Capsule()
                        .strokeBorder(
                            session.passed
                                ? Color.green.opacity(0.5)
                                : Color.blue.opacity(0.5),
                            lineWidth: 1
                        )
                }
        }
    }

    // MARK: - Concept Chips

    private var conceptChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(session.problem.blocks, id: \.rawValue) { node in
                    HStack(spacing: 4) {
                        Image(systemName: node.sfSymbol)
                            .font(.system(size: 9))
                            .foregroundStyle(node.accentColor)
                        Text(node.displayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.08), in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                    }
                }
            }
        }
    }

    // MARK: - Section 2: Scrollable Content

    private var section2: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(
                    Array(results.enumerated()),
                    id: \.element.question.id
                ) { i, result in
                    resultCard(
                        result: result,
                        analysisText: analysisTexts[safe: i]
                            ?? result.question.explanation
                    )
                }

                reattemptButton
                    .padding(.top, 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Result Card

    private func resultCard(result: QuizResult, analysisText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: result.question.blockType.sfSymbol)
                    .font(.system(size: 13))
                    .foregroundStyle(result.question.blockType.accentColor)
                    .frame(width: 20)

                Text(result.question.questionText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)

                Spacer()

                Image(systemName: result.isCorrect
                    ? "checkmark.circle.fill"
                    : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(result.isCorrect ? .green : .red)
            }

            VStack(alignment: .leading, spacing: 6) {
                if !result.isCorrect && result.wasAnswered {
                    answerRow(
                        label: "Your answer",
                        text: result.userAnswerText,
                        isCorrect: false
                    )
                }
                answerRow(
                    label: "Correct answer",
                    text: result.correctAnswerText,
                    isCorrect: true
                )
            }

            Text(analysisText)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .glossyCardBackground(cornerRadius: 14)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    result.isCorrect
                        ? Color.green.opacity(0.3)
                        : Color.red.opacity(0.25),
                    lineWidth: 1
                )
        }
    }

    private func answerRow(label: String, text: String, isCorrect: Bool) -> some View {
        HStack(spacing: 6) {
            Text(label + ":")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isCorrect ? .green.opacity(0.9) : .red.opacity(0.9))
        }
    }

    // MARK: - Reattempt Button

    private var reattemptButton: some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onReattempt()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                Text("Reattempt")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.07))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    }
            }
        }
        .accessibilityLabel("Reattempt this challenge")
    }

    // MARK: - Drowning Effect

    private var drowningWaterOverlay: some View {
        GeometryReader { _ in
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    drawWater(ctx: ctx, size: size, time: t)
                }
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
    }

    private func drawWater(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height
        let riseY = h * (1 - waterLevel)

        var path = Path()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: riseY))

        let waveHeight: CGFloat = 14
        let period: CGFloat = w / 1.5
        var x: CGFloat = 0
        while x <= w {
            let y = riseY + sin((x / period) * .pi * 2 + time * 2.5) * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
            x += 4
        }
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()

        ctx.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.0, green: 0.3, blue: 0.7).opacity(0.45),
                    Color(red: 0.0, green: 0.1, blue: 0.4).opacity(0.55)
                ]),
                startPoint: CGPoint(x: 0, y: riseY),
                endPoint: CGPoint(x: 0, y: h)
            )
        )
    }

    private var drownedOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: 48))
                .foregroundStyle(.cyan.opacity(0.8))
            Text("Drowned")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Score below 75% — the city drowned")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.6))
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    // MARK: - Success Glow

    private var successGlowOverlay: some View {
        ZStack {
            RadialGradient(
                colors: [.yellow.opacity(0.12), .orange.opacity(0.06), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            Canvas { ctx, size in
                for i in 0 ..< 30 {
                    let angle = Double(i) / 30.0 * .pi * 2
                    let radius = Double.random(in: 80 ... 220)
                    let x = size.width / 2 + cos(angle) * radius
                    let y = size.height * 0.25 + sin(angle) * radius * 0.6
                    let r = Double.random(in: 2 ... 5)
                    var path = Path()
                    path.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
                    ctx.fill(
                        path,
                        with: .color(.yellow.opacity(Double.random(in: 0.3 ... 0.8)))
                    )
                }
            }
            .opacity(particleOpacity)
            .ignoresSafeArea()
        }
    }

    // MARK: - Entrance Animation

    private func runEntranceAnimation() {
        if session.passed {
            HapticManager.success()
            SoundManager.playSuccessSound()
            withAnimation(.easeOut(duration: 0.6)) { showContent = true }
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) { particleOpacity = 1.0 }
        } else {
            HapticManager.error()
            SoundManager.playDrownSound()
            // Water rises, drowned text appears, then both fade as content comes in
            withAnimation(.easeIn(duration: 1.8)) { waterLevel = 0.35 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.4)) { showDrownedText = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeOut(duration: 0.6)) { showContent = true }
            }
        }
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
