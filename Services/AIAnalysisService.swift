import Foundation
import FoundationModels

/// On-device AI analysis using Apple Foundation Models (iOS 26+).
/// Generates personalised 1-2 sentence explanations for each quiz question.
/// Falls back gracefully to the pre-authored `explanation` field when the
/// model is unavailable, warming up, or the device doesn't support it.
@available(iOS 26, *)
struct AIAnalysisService {

    // MARK: - Public API

    /// Generates analysis text for every result in `results`.
    /// Returns a parallel array of explanation strings (same order as input).
    func generateAnalysis(
        problemTitle: String,
        tierLevel: String,
        results: [QuizResult]
    ) async -> [String] {
        // Fast-path: return fallbacks if model unavailable
        guard SystemLanguageModel.default.isAvailable else {
            return results.map { $0.question.explanation }
        }

        var explanations: [String] = []

        for result in results {
            let text = await generateSingleExplanation(
                problemTitle: problemTitle,
                tierLevel: tierLevel,
                result: result
            )
            explanations.append(text)
        }

        return explanations
    }

    // MARK: - Private

    private func generateSingleExplanation(
        problemTitle: String,
        tierLevel: String,
        result: QuizResult
    ) async -> String {
        let prompt = buildPrompt(problemTitle: problemTitle, tierLevel: tierLevel, result: result)

        do {
            let session = LanguageModelSession(
                instructions: "You are a concise iOS system design educator. Explain system design concepts in 1-2 short, clear sentences aimed at a student learning mobile architecture. Be direct and educational."
            )
            let response = try await session.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? result.question.explanation : text
        } catch {
            // Model error or rate limit — use static fallback
            return result.question.explanation
        }
    }

    private func buildPrompt(problemTitle: String, tierLevel: String, result: QuizResult) -> String {
        let userAnswerText = result.userAnswerText
        let correctAnswerText = result.correctAnswerText
        let wasCorrect = result.isCorrect

        return """
        Context: \(problemTitle) (\(tierLevel)), \(result.question.blockType.displayName) component.

        Question: \(result.question.questionText)
        Correct answer: "\(correctAnswerText)"
        Student answered: "\(userAnswerText)" — \(wasCorrect ? "Correct ✓" : "Incorrect ✗")

        \(wasCorrect
          ? "Briefly reinforce why '\(correctAnswerText)' is correct in iOS architecture."
          : "Briefly explain why '\(correctAnswerText)' is correct and why '\(userAnswerText)' is not the right choice for this pattern."
        )
        Keep it to 1-2 sentences only.
        """
    }
}

// MARK: - Availability stub for older OS builds

/// Exists so callers on iOS < 26 compile without errors.
/// The @available guard in BuilderView prevents actual execution on older OS.
struct AIAnalysisServiceStub {
    func generateAnalysis(results: [QuizResult]) async -> [String] {
        results.map { $0.question.explanation }
    }
}
