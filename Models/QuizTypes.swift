import Foundation

// MARK: - Quiz Question

struct QuizQuestion: Identifiable {
    let id: String
    let blockType: NodeType
    let questionText: String
    let options: [String]
    let correctIndex: Int
    /// Fallback explanation shown when AI is unavailable.
    let explanation: String

    /// Returns a copy with options in a random order and correctIndex updated to match.
    func withShuffledOptions() -> QuizQuestion {
        var indices = Array(options.indices)
        indices.shuffle()
        let shuffledOptions = indices.map { options[$0] }
        let newCorrectIndex = indices.firstIndex(of: correctIndex) ?? correctIndex
        return QuizQuestion(
            id: id,
            blockType: blockType,
            questionText: questionText,
            options: shuffledOptions,
            correctIndex: newCorrectIndex,
            explanation: explanation
        )
    }
}

// MARK: - Quiz Answer

struct QuizAnswer {
    let questionID: String
    let selectedIndex: Int?   // nil when question was not answered (e.g. timer expiry)
    let isCorrect: Bool
}

// MARK: - Quiz Result

struct QuizResult {
    let question: QuizQuestion
    let answer: QuizAnswer
    /// AI-generated or fallback explanation populated during analysis.
    var analysisText: String

    var isCorrect: Bool { answer.isCorrect }
    var wasAnswered: Bool { answer.selectedIndex != nil }
    var userAnswerText: String {
        guard let idx = answer.selectedIndex, idx < question.options.count else { return "–" }
        return question.options[idx]
    }
    var correctAnswerText: String {
        guard question.correctIndex < question.options.count else { return "–" }
        return question.options[question.correctIndex]
    }
}

// MARK: - Block Quiz State

/// Tracks quiz progress for a single block on the canvas.
struct BlockQuizState {
    let blockType: NodeType
    let questions: [QuizQuestion]
    var answers: [String: Int] = [:]   // questionID → selectedIndex
    var isComplete: Bool { answers.count == questions.count }

    var correctCount: Int {
        questions.filter { q in
            answers[q.id] == q.correctIndex
        }.count
    }
}

// MARK: - Overall Quiz Session

struct QuizSession {
    let problem: InteriorProblem
    var blockStates: [BlockQuizState]

    var allBlocksComplete: Bool {
        blockStates.allSatisfy { $0.isComplete }
    }

    var totalQuestions: Int {
        blockStates.reduce(0) { $0 + $1.questions.count }
    }

    var totalCorrect: Int {
        blockStates.reduce(0) { $0 + $1.correctCount }
    }

    var scorePercent: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalQuestions) * 100
    }

    var passed: Bool { scorePercent >= 75 }

    func results() -> [QuizResult] {
        blockStates.flatMap { state in
            state.questions.map { question in
                let selectedIndex = state.answers[question.id]
                let answer = QuizAnswer(
                    questionID: question.id,
                    selectedIndex: selectedIndex,
                    isCorrect: selectedIndex != nil && selectedIndex == question.correctIndex
                )
                return QuizResult(
                    question: question,
                    answer: answer,
                    analysisText: question.explanation
                )
            }
        }
    }
}
