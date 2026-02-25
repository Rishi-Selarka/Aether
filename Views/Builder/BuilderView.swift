import SwiftUI
import SwiftData

/// Main builder screen: instruction overlay → block ordering → per-block quiz → analysis.
struct BuilderView: View {
    let tierID: Int
    let selectedProblemIndex: Int
    let timeLimitMinutes: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Problem Data

    private var problem: InteriorProblem? {
        InteriorContent.problems(for: tierID)[safe: selectedProblemIndex]
    }

    private var tierName: String {
        switch tierID {
        case 1: return "Tokyo"
        case 2: return "London"
        case 3: return "Singapore"
        case 4: return "New York"
        case 5: return "San Francisco"
        default: return "City"
        }
    }

    // MARK: - Canvas State

    @State private var currentOrder: [NodeType] = []
    @State private var showInstructions = true
    @State private var isOrdered = false
    @State private var orderedConfirmed = false

    // MARK: - Quiz State

    @State private var quizSession: QuizSession?
    @State private var completedBlocks: Set<NodeType> = []
    @State private var activeQuizBlock: BlockQuizState?
    @State private var showQuizCard = false

    // MARK: - Analysis State

    @State private var showAnalysis = false
    @State private var analysisTexts: [String] = []
    @State private var isGeneratingAnalysis = false

    // MARK: - Timer

    @State private var secondsRemaining: Int = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var timerExpired = false

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
            } else {
                Text("Problem not found")
                    .foregroundStyle(.white.opacity(0.5))
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
                quizSession = buildQuizSession(problem: problem)
            }
        }
        .onAppear { setup() }
        .onDisappear { timerTask?.cancel() }
    }

    // MARK: - Main Content

    @ViewBuilder
    private func mainContent(problem: InteriorProblem) -> some View {
        VStack(spacing: 0) {
            navigationBar(problem: problem)
            timerBar
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            phaseLabel
            BlockCanvasView(
                correctOrder: problem.blocks,
                currentOrder: $currentOrder,
                completedBlocks: completedBlocks,
                isOrdered: isOrdered,
                onBlockTap: { node in openQuizForBlock(node) }
            )
            bottomBar
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
    }

    // MARK: - Navigation Bar

    private func navigationBar(problem: InteriorProblem) -> some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")

            Spacer()

            Text(problem.title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 12)
        .padding(.top, 56)
        .padding(.bottom, 8)
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
            Image(systemName: isOrdered
                  ? "checkmark.circle.fill"
                  : "arrow.up.arrow.down.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(isOrdered ? .green : .white.opacity(0.5))
            Text(phaseLabelText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private var phaseLabelText: String {
        if isOrdered {
            return quizSession?.allBlocksComplete == true
                ? "Tap 'Analyse' when ready"
                : "Tap each block to answer its quiz"
        }
        return "Drag blocks into the correct order"
    }

    // MARK: - Bottom Bar

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
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.blue.opacity(0.7))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        }
                }
            }
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
        guard let problem else { return }
        currentOrder = problem.blocks.shuffled()
        secondsRemaining = timeLimitMinutes * 60
        startTimer()
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
        let session = quizSession ?? buildQuizSession(problem: problem)
        quizSession = session
        startAnalysis(session: session, problem: problem)
    }

    // MARK: - Quiz Logic

    private func buildQuizSession(problem: InteriorProblem) -> QuizSession {
        let blockStates = problem.blocks.map { node in
            BlockQuizState(
                blockType: node,
                questions: QuizContent.questions(for: node, problemID: problem.id)
            )
        }
        return QuizSession(problem: problem, blockStates: blockStates)
    }

    private func openQuizForBlock(_ node: NodeType) {
        guard isOrdered, let session = quizSession else { return }
        guard let state = session.blockStates.first(where: { $0.blockType == node }) else { return }
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
        guard let problem else { return }

        // 1. Insert the quiz attempt record
        let attempt = QuizAttempt(
            tierID: tierID,
            problemIndex: selectedProblemIndex,
            problemTitle: problem.title,
            score: session.scorePercent,
            passed: session.passed,
            totalQuestions: session.totalQuestions,
            correctAnswers: session.totalCorrect,
            analysisJSON: ""
        )
        modelContext.insert(attempt)

        // 2. Update tier stats inline (single save for all changes)
        let fetchTierID = tierID
        var descriptor = FetchDescriptor<Tier>(predicate: #Predicate { $0.id == fetchTierID })
        descriptor.fetchLimit = 1
        if let tier = try? modelContext.fetch(descriptor).first {
            tier.attemptsCount += 1
            if session.passed {
                tier.passCount += 1
                tier.completed = true
                if session.scorePercent > tier.score { tier.score = session.scorePercent }
                if let progress = try? modelContext.fetch(FetchDescriptor<CityProgress>()).first,
                   !progress.completedTierIDs.contains(fetchTierID) {
                    progress.completedTierIDs.append(fetchTierID)
                }
            } else {
                if session.scorePercent > tier.score { tier.score = session.scorePercent }
            }
        }

        // 3. Single save for attempt + tier updates
        do {
            try modelContext.save()
        } catch {
            // Autosave will pick it up on next cycle
        }
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
        setup()
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
