import SwiftUI

/// Glass overlay card for answering 3 MCQ questions about a single block.
struct QuizCardView: View {
    let blockState: BlockQuizState
    /// Called with updated answers dictionary when user taps Finish.
    let onFinish: ([String: Int]) -> Void
    let onDismiss: () -> Void

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [String: Int]
    @State private var showAnswerFeedback = false

    init(blockState: BlockQuizState, onFinish: @escaping ([String: Int]) -> Void, onDismiss: @escaping () -> Void) {
        self.blockState = blockState
        self.onFinish = onFinish
        self.onDismiss = onDismiss
        // Pre-populate with already-answered questions if re-entering
        _selectedAnswers = State(initialValue: blockState.answers)
    }

    private var currentQuestion: QuizQuestion {
        blockState.questions[currentQuestionIndex]
    }

    private var selectedIndexForCurrent: Int? {
        selectedAnswers[currentQuestion.id]
    }

    private var isLastQuestion: Bool {
        currentQuestionIndex == blockState.questions.count - 1
    }

    private var canFinish: Bool {
        isLastQuestion && selectedAnswers.count == blockState.questions.count
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                cardContent
            }
            .background {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.5), radius: 50)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            cardHeader

            Divider().opacity(0.3)

            // Progress indicator
            questionProgress

            // Question text
            Text(currentQuestion.questionText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)

            // Options
            optionsList

            Spacer(minLength: 8)

            // Navigation
            navigationRow
        }
        .padding(24)
    }

    // MARK: - Header

    private var cardHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(blockState.blockType.accentColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: blockState.blockType.sfSymbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(blockState.blockType.accentColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(blockState.blockType.displayName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Quiz")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close quiz")
        }
    }

    // MARK: - Progress

    private var questionProgress: some View {
        HStack(spacing: 6) {
            ForEach(0 ..< blockState.questions.count, id: \.self) { i in
                Capsule()
                    .fill(
                        i == currentQuestionIndex
                            ? blockState.blockType.accentColor
                            : (selectedAnswers[blockState.questions[i].id] != nil
                               ? Color.white.opacity(0.5)
                               : Color.white.opacity(0.15))
                    )
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.2), value: currentQuestionIndex)
            }
        }
        .accessibilityLabel("Question \(currentQuestionIndex + 1) of \(blockState.questions.count)")
    }

    // MARK: - Options

    private var optionsList: some View {
        VStack(spacing: 10) {
            ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { idx, option in
                optionButton(index: idx, text: option)
            }
        }
    }

    private func optionButton(index: Int, text: String) -> some View {
        let isSelected = selectedIndexForCurrent == index

        return Button {
            selectOption(index: index)
        } label: {
            HStack(spacing: 12) {
                Text(["A", "B", "C", "D"][safe: index] ?? "")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? blockState.blockType.accentColor : .white.opacity(0.5))
                    .frame(width: 26, height: 26)
                    .background {
                        Circle()
                            .fill(isSelected
                                  ? blockState.blockType.accentColor.opacity(0.2)
                                  : Color.white.opacity(0.08))
                    }

                Text(text)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                          ? blockState.blockType.accentColor.opacity(0.15)
                          : Color.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isSelected
                                    ? blockState.blockType.accentColor.opacity(0.6)
                                    : Color.white.opacity(0.08),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Option \(["A","B","C","D"][safe: index] ?? ""): \(text)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Navigation Row

    private var navigationRow: some View {
        HStack {
            Button {
                guard currentQuestionIndex > 0 else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentQuestionIndex -= 1
                }
                HapticManager.lightImpact()
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(currentQuestionIndex > 0 ? .white.opacity(0.7) : .white.opacity(0.2))
            }
            .buttonStyle(.plain)
            .disabled(currentQuestionIndex == 0)
            .accessibilityLabel("Previous question")

            Spacer()

            if canFinish {
                Button {
                    HapticManager.success()
                    onFinish(selectedAnswers)
                } label: {
                    Text("Finish")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background {
                            Capsule()
                                .fill(blockState.blockType.accentColor.opacity(0.8))
                                .overlay {
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                }
                        }
                }
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Finish quiz for \(blockState.blockType.displayName)")
            }

            Spacer()

            Button {
                guard !isLastQuestion else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentQuestionIndex += 1
                }
                HapticManager.lightImpact()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(!isLastQuestion ? .white.opacity(0.7) : .white.opacity(0.2))
            }
            .buttonStyle(.plain)
            .disabled(isLastQuestion)
            .accessibilityLabel("Next question")
        }
    }

    // MARK: - Actions

    private func selectOption(index: Int) {
        let qid = currentQuestion.id
        guard selectedAnswers[qid] != index else { return }
        selectedAnswers[qid] = index
        HapticManager.selection()
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
