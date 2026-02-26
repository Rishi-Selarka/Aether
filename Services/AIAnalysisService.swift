import Foundation
import FoundationModels

// MARK: - Structured output type

@available(iOS 26, *)
@Generable
struct GeneratedAnalysis {
    @Guide(description: "1-2 sentence educational explanation, direct and concise")
    var text: String
}

// MARK: - Service

/// On-device AI analysis using Apple Foundation Models (iOS 26+).
/// Generates personalised explanations for each quiz result using structured output.
/// All results are generated concurrently. Falls back gracefully to the pre-authored
/// `explanation` field when the model is unavailable or an individual call fails.
@available(iOS 26, *)
struct AIAnalysisService {

    // MARK: - Public API

    func generateAnalysis(
        problemTitle: String,
        tierLevel: String,
        results: [QuizResult]
    ) async -> [String] {
        guard SystemLanguageModel.default.isAvailable else {
            return results.map { $0.question.explanation }
        }

        return await withTaskGroup(of: (Int, String).self) { group in
            for (index, result) in results.enumerated() {
                group.addTask {
                    let text = await Self.generateSingleExplanation(
                        problemTitle: problemTitle,
                        tierLevel: tierLevel,
                        result: result
                    )
                    return (index, text)
                }
            }

            var explanations = Array(repeating: "", count: results.count)
            for await (index, text) in group {
                explanations[index] = text
            }
            return explanations
        }
    }

    // MARK: - Private

    private static func generateSingleExplanation(
        problemTitle: String,
        tierLevel: String,
        result: QuizResult
    ) async -> String {
        let prompt = buildPrompt(problemTitle: problemTitle, tierLevel: tierLevel, result: result)

        do {
            let session = LanguageModelSession(
                instructions: "You are a concise iOS system design educator. Explain concepts in 1-2 short sentences aimed at a student learning mobile architecture. Be direct and educational."
            )
            let response = try await session.respond(to: prompt, generating: GeneratedAnalysis.self)
            let text = response.content.text.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? result.question.explanation : text
        } catch {
            return result.question.explanation
        }
    }

    private static func buildPrompt(
        problemTitle: String,
        tierLevel: String,
        result: QuizResult
    ) -> String {
        let wasCorrect = result.isCorrect
        return """
        Context: \(problemTitle) (\(tierLevel)), \(result.question.blockType.displayName) component.

        Question: \(result.question.questionText)
        Correct answer: "\(result.correctAnswerText)"
        Student answered: "\(result.userAnswerText)" — \(wasCorrect ? "Correct" : "Incorrect")

        \(wasCorrect
          ? "Reinforce why '\(result.correctAnswerText)' is correct in iOS architecture."
          : "Explain why '\(result.correctAnswerText)' is correct and why '\(result.userAnswerText)' is not the right choice."
        )
        """
    }
}
