import Foundation
import FoundationModels

// MARK: - Structured output types

/// One AI-generated MCQ question.
@available(iOS 26, *)
@Generable
struct GeneratedQuizQuestion {
    @Guide(description: "Quiz question text (40-120 characters)")
    var question: String

    @Guide(description: "Exactly 4 answer options, each 25-70 characters with similar lengths")
    var options: [String]

    @Guide(description: "Integer 0-3 indicating which option is correct - vary this across questions")
    var correct: Int

    @Guide(description: "1-2 sentence explanation of why the correct answer is right")
    var explanation: String
}

/// Container for the full set of 3 questions per block.
@available(iOS 26, *)
@Generable
struct GeneratedQuizSet {
    @Guide(description: "Exactly 3 multiple-choice questions of escalating difficulty")
    var questions: [GeneratedQuizQuestion]
}

// MARK: - Service

/// On-device AI quiz generation using Apple Foundation Models (iOS 26+).
/// Generates dynamic MCQ questions for each architecture block using structured output.
/// Returns an empty array on failure - caller falls back to static questions.
@available(iOS 26, *)
struct AIQuizService {

    // MARK: - Public API

    func generateQuestions(
        blockType: NodeType,
        problemTitle: String,
        problemDescription: String,
        tierLevel: String
    ) async -> [QuizQuestion] {
        guard SystemLanguageModel.default.isAvailable else { return [] }

        do {
            let session = LanguageModelSession(
                instructions: """
                You are an iOS system design quiz generator for university-level students. \
                Generate challenging multiple-choice questions that test deep understanding, not surface recall. \
                All four options must be plausible, technically sound, and similar in length. \
                Vary the correct answer position across questions. \
                Questions should require reasoning, not just memorisation.
                """
            )

            let prompt = buildPrompt(
                blockType: blockType,
                problemTitle: problemTitle,
                problemDescription: problemDescription,
                tierLevel: tierLevel
            )

            let response = try await session.respond(to: prompt, generating: GeneratedQuizSet.self)
            let generated = response.content.questions
            guard generated.count == 3 else { return [] }

            return generated.enumerated().compactMap { i, q in
                guard q.options.count == 4, (0 ... 3).contains(q.correct) else { return nil }
                return QuizQuestion(
                    id: "ai_\(blockType.rawValue)_\(i)_\(UUID().uuidString.prefix(6))",
                    blockType: blockType,
                    questionText: q.question,
                    options: q.options,
                    correctIndex: q.correct,
                    explanation: q.explanation
                )
            }
        } catch {
            return []
        }
    }

    // MARK: - Prompt

    private func buildPrompt(
        blockType: NodeType,
        problemTitle: String,
        problemDescription: String,
        tierLevel: String
    ) -> String {
        """
        Generate 3 challenging multiple-choice questions about the \
        "\(blockType.displayName)" component in this iOS architecture problem:

        Problem: \(problemTitle) (\(tierLevel))
        Context: \(problemDescription)
        Component role: \(blockType.architectureRole)

        Each question must have exactly 4 options with similar lengths, \
        and the correct answer position must vary across the 3 questions.
        """
    }
}
