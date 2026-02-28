import SwiftUI
import SwiftData

/// Main builder screen: instruction overlay → block ordering → per-block quiz → analysis.
struct BuilderView: View {
    let tierID: Int
    let selectedProblemIndex: Int
    let timeLimitMinutes: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(TierStatsCache.self) private var statsCache

    // MARK: - Problem Data

    private var problem: InteriorProblem? {
        InteriorContent.problems(for: tierID)[safe: selectedProblemIndex]
    }

    private var tierName: String {
        InteriorContent.cityName(for: tierID)
    }

    // MARK: - Canvas State

    @State private var currentOrder: [NodeType] = []
    @State private var showInstructions = true
    @State private var isOrdered = false
    @State private var orderedConfirmed = false
    @State private var canvasId = UUID()

    // MARK: - Quiz State

    @State private var quizSession: QuizSession?
    @State private var completedBlocks: Set<NodeType> = []
    @State private var activeQuizBlock: BlockQuizState?
    @State private var showQuizCard = false
    @State private var isLoadingQuiz = false

    // MARK: - Analysis State

    @State private var showAnalysis = false
    @State private var analysisTexts: [String] = []
    @State private var isGeneratingAnalysis = false

    // MARK: - Timer

    @State private var secondsRemaining: Int = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var timerExpired = false

    // MARK: - Hint

    @State private var showHint = false
    @State private var hintCooldownToast: String?

    /// Prevents double-counting when onAppear fires again after dismissing AnalysisView (tap Done).
    @State private var hasRecordedAttemptThisSession = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.09, blue: 0.12)
                .ignoresSafeArea()

            if let problem {
                mainContent(problem: problem)

                if showInstructions {
                    InstructionOverlay(problemTitle: problem.title) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showInstructions = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(10)
                }

                if showQuizCard, let activeState = activeQuizBlock {
                    QuizCardView(
                        blockState: activeState,
                        onFinish: { answers in
                            finishBlockQuiz(blockType: activeState.blockType, answers: answers)
                        },
                        onDismiss: {
                            withAnimation { showQuizCard = false }
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    .zIndex(9)
                }

                if isGeneratingAnalysis {
                    analysisLoadingOverlay
                        .zIndex(11)
                }

                if showHint {
                    hintOverlay(blocks: problem.blocks)
                        .zIndex(12)
                }

                if let toast = hintCooldownToast {
                    VStack {
                        Spacer()
                        Text(toast)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                Capsule().fill(.ultraThinMaterial)
                                    .overlay { Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.5) }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 90)
                    }
                    .zIndex(13)
                    .animation(.spring(response: 0.35), value: hintCooldownToast)
                }
            } else {
                Text("Problem not found")
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let problem {
                fixedNavBarContent(problem: problem)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showAnalysis) {
            if let session = quizSession {
                AnalysisView(
                    session: session,
                    analysisTexts: analysisTexts,
                    tierName: tierName,
                    onDone: navigateHome,
                    onReattempt: resetAndDismiss
                )
            }
        }
        .onChange(of: currentOrder) { _, newOrder in
            guard let problem, !isOrdered else { return }
            if newOrder == problem.blocks {
                isOrdered = true
                orderedConfirmed = true
                HapticManager.success()
                loadQuizSession(problem: problem)
            }
        }
        .onAppear { setup() }
        .onDisappear { timerTask?.cancel() }
    }

    // MARK: - Main Content

    @ViewBuilder
    private func mainContent(problem: InteriorProblem) -> some View {
        VStack(spacing: 0) {
            timerBar
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            phaseLabel
            BlockCanvasView(
                correctOrder: problem.blocks,
                currentOrder: $currentOrder,
                completedBlocks: completedBlocks,
                isOrdered: isOrdered,
                isPaused: showQuizCard || showHint,
                onBlockTap: { node in openQuizForBlock(node) }
            )
            .id(canvasId)
            bottomBar
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
    }

    // MARK: - Fixed Nav Bar (top of screen, like Analysis)

    private func fixedNavBarContent(problem: InteriorProblem) -> some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Back")

                Spacer()

                Text(problem.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer()

                hintButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.09, green: 0.09, blue: 0.12))
    }

    // MARK: - Hint Button

    private var secondsElapsed: Int {
        timeLimitMinutes * 60 - secondsRemaining
    }

    private var hintUnlocked: Bool {
        secondsElapsed >= 60
    }

    @ViewBuilder
    private var hintButton: some View {
        if !isOrdered {
            Button {
                if hintUnlocked {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showHint = true
                    }
                    HapticManager.lightImpact()
                } else {
                    let remaining = max(0, 60 - secondsElapsed)
                    hintCooldownToast = "Available in \(remaining)s"
                    HapticManager.error()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(.easeOut(duration: 0.3)) { hintCooldownToast = nil }
                    }
                }
            }             label: {
                Image(systemName: "lightbulb.min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(hintUnlocked ? .yellow : .white.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.glass)
            .accessibilityLabel(hintUnlocked ? "Show solution hint" : "Hint locked, wait \(60 - secondsElapsed) seconds")
            .animation(.easeInOut(duration: 0.5), value: hintUnlocked)
        } else {
            Color.clear.frame(width: 36, height: 36)
        }
    }

    // MARK: - Timer Bar

    private var timerBar: some View {
        let total = timeLimitMinutes * 60
        let fraction = total > 0 ? Double(secondsRemaining) / Double(total) : 1.0
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        let isLow = fraction < 0.25

        return HStack(spacing: 12) {
            Image(systemName: isLow ? "exclamationmark.triangle.fill" : "timer")
                .font(.system(size: 13))
                .foregroundStyle(isLow ? .red : .white.opacity(0.5))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 6)
                    Capsule()
                        .fill(isLow ? Color.red : Color.green)
                        .frame(width: geo.size.width * max(0, fraction), height: 6)
                        .animation(.linear(duration: 1), value: fraction)
                }
                .frame(height: 6)
            }
            .frame(height: 6)

            Text(String(format: "%d:%02d", minutes, seconds))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(isLow ? .red : .white.opacity(0.7))
                .frame(width: 48, alignment: .trailing)
        }
        .frame(height: 24)
    }

    // MARK: - Phase Label

    private var phaseLabel: some View {
        HStack(spacing: 8) {
            if isLoadingQuiz {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.55)
                    .tint(.white.opacity(0.5))
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(isOrdered ? Color.green : Color.white.opacity(0.25))
                    .frame(width: 6, height: 6)
            }
            Text(phaseLabelText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isOrdered ? .green.opacity(0.8) : .white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .animation(.easeInOut(duration: 0.4), value: isOrdered)
        .animation(.easeInOut(duration: 0.3), value: isLoadingQuiz)
    }

    private var phaseLabelText: String {
        if isLoadingQuiz { return "Preparing quiz…" }
        if isOrdered {
            return quizSession?.allBlocksComplete == true
                ? "Ready to analyse"
                : "Tap blocks to begin quiz"
        }
        return "Arrange the architecture according to priority"
    }

    // MARK: - Bottom Bar

    // MARK: - Hint Overlay

    private func hintOverlay(blocks: [NodeType]) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        showHint = false
                    }
                }

            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.yellow)
                    Text("Correct Order")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 0) {
                    ForEach(Array(blocks.enumerated()), id: \.element) { index, block in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: 20)

                            Text(block.displayName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.9))

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)

                        if index < blocks.count - 1 {
                            Rectangle()
                                .fill(.white.opacity(0.08))
                                .frame(height: 1)
                                .padding(.leading, 48)
                        }
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.06))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                        }
                }

                Text("Tap anywhere to dismiss")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 48)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        if let session = quizSession, session.allBlocksComplete {
            Button {
                guard let problem else { return }
                startAnalysis(session: session, problem: problem)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill").font(.system(size: 15))
                    Text("Analyse Results").font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(.glassProminent)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityLabel("Analyse all quiz results")

        } else if isOrdered {
            HStack(spacing: 6) {
                Image(systemName: "info.circle").font(.system(size: 13))
                Text("Complete all block quizzes to continue")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.4))
            .frame(height: 40)
        } else {
            Color.clear.frame(height: 40)
        }
    }

    // MARK: - Loading Overlay

    private var analysisLoadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.3)
                Text("Generating AI analysis…")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        guard problem != nil else { return }
        currentOrder = []          // blocks start unplaced in floating area
        secondsRemaining = timeLimitMinutes * 60
        if !hasRecordedAttemptThisSession {
            hasRecordedAttemptThisSession = true
            recordAttemptEntry()
        }
        startTimer()
    }

    /// Increments attempt count the moment the user enters the builder. Call once per session.
    private func recordAttemptEntry() {
        SwiftDataManager.recordAttemptEntry(tierID: tierID, context: modelContext)
        statsCache.incrementAttempts(tierID: tierID)
    }

    // MARK: - Timer

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while secondsRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                secondsRemaining = max(0, secondsRemaining - 1)
                if secondsRemaining == 0 {
                    handleTimerExpiry()
                }
            }
        }
    }

    private func handleTimerExpiry() {
        guard !timerExpired, let problem else { return }
        timerExpired = true
        HapticManager.error()
        if quizSession == nil {
            quizSession = buildStaticQuizSession(problem: problem)
        }
        guard let session = quizSession else { return }
        startAnalysis(session: session, problem: problem)
    }

    // MARK: - Quiz Logic

    /// Loads quiz session - tries AI generation on iOS 26+, falls back to static.
    private func loadQuizSession(problem: InteriorProblem) {
        if #available(iOS 26, *) {
            isLoadingQuiz = true
            Task { @MainActor in
                let session = await buildAIQuizSession(problem: problem)
                quizSession = session
                isLoadingQuiz = false
            }
        } else {
            quizSession = buildStaticQuizSession(problem: problem)
        }
    }

    private func buildStaticQuizSession(problem: InteriorProblem) -> QuizSession {
        let blockStates = problem.blocks.map { node in
            BlockQuizState(
                blockType: node,
                questions: QuizContent.questions(for: node, problemID: problem.id)
            )
        }
        return QuizSession(problem: problem, blockStates: blockStates)
    }

    @available(iOS 26, *)
    private func buildAIQuizSession(problem: InteriorProblem) async -> QuizSession {
        let service = AIQuizService()
        let nodes = problem.blocks
        let capturedTierName = tierName

        // Generate questions for all blocks in parallel
        let blockStates: [BlockQuizState] = await withTaskGroup(of: (Int, BlockQuizState).self) { group in
            for (i, node) in nodes.enumerated() {
                group.addTask {
                    let aiQuestions = await service.generateQuestions(
                        blockType: node,
                        problemTitle: problem.title,
                        problemDescription: problem.description,
                        tierLevel: capturedTierName
                    )
                    let questions = aiQuestions.count == 3
                        ? aiQuestions
                        : QuizContent.questions(for: node, problemID: problem.id)
                    return (i, BlockQuizState(blockType: node, questions: questions))
                }
            }

            // Reassemble in original block order; fall back to static questions for any missing slot
            var ordered: [BlockQuizState?] = Array(repeating: nil, count: nodes.count)
            for await (i, state) in group {
                ordered[i] = state
            }
            return ordered.enumerated().map { i, state in
                state ?? BlockQuizState(
                    blockType: nodes[i],
                    questions: QuizContent.questions(for: nodes[i], problemID: problem.id)
                )
            }
        }

        return QuizSession(problem: problem, blockStates: blockStates)
    }

    private func openQuizForBlock(_ node: NodeType) {
        guard isOrdered, let session = quizSession else { return }
        guard let state = session.blockStates.first(where: { $0.blockType == node }),
              !state.questions.isEmpty else { return }
        activeQuizBlock = state
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showQuizCard = true
        }
    }

    private func finishBlockQuiz(blockType: NodeType, answers: [String: Int]) {
        guard var session = quizSession else { return }
        if let idx = session.blockStates.firstIndex(where: { $0.blockType == blockType }) {
            session.blockStates[idx].answers = answers
        }
        quizSession = session
        completedBlocks.insert(blockType)
        withAnimation(.spring(response: 0.35)) { showQuizCard = false }
        HapticManager.mediumImpact()
    }

    // MARK: - Analysis

    private func startAnalysis(session: QuizSession, problem: InteriorProblem) {
        timerTask?.cancel()
        isGeneratingAnalysis = true

        Task { @MainActor in
            let results = session.results()
            let texts: [String]

            if #available(iOS 26, *) {
                let service = AIAnalysisService()
                texts = await service.generateAnalysis(
                    problemTitle: problem.title,
                    tierLevel: tierName,
                    results: results
                )
            } else {
                texts = results.map { $0.question.explanation }
            }

            saveAttempt(session: session)

            analysisTexts = texts
            quizSession = session
            isGeneratingAnalysis = false
            showAnalysis = true
        }
    }

    private func saveAttempt(session: QuizSession) {
        guard problem != nil else { return }

        // Update tier stats (attempt already counted on entry)
        if session.passed {
            SwiftDataManager.recordPass(tierID: tierID, problemIndex: selectedProblemIndex, score: session.scorePercent, context: modelContext)
        } else {
            SwiftDataManager.recordFailedScore(tierID: tierID, problemIndex: selectedProblemIndex, score: session.scorePercent, context: modelContext)
        }
        statsCache.updateBestScore(tierID: tierID, problemIndex: selectedProblemIndex, score: session.scorePercent)
    }

    // MARK: - Navigation

    /// Called by AnalysisView's Done button (after AnalysisView already popped itself).
    /// Dismisses BuilderView back to InteriorView.
    private func navigateHome() {
        dismiss()
    }

    /// Called by AnalysisView's Reattempt button (after AnalysisView already popped itself).
    /// Resets all quiz state so the user can retry the same problem.
    private func resetAndDismiss() {
        showAnalysis = false
        isOrdered = false
        orderedConfirmed = false
        quizSession = nil
        completedBlocks = []
        activeQuizBlock = nil
        showQuizCard = false
        analysisTexts = []
        isGeneratingAnalysis = false
        timerExpired = false
        showHint = false
        hintCooldownToast = nil
        hasRecordedAttemptThisSession = false  // Reattempt = new attempt, count again
        canvasId = UUID()         // force-recreate BlockCanvasView with fresh slots
        setup()
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
