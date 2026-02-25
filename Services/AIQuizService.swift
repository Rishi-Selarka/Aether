import Foundation
import FoundationModels

/// On-device AI quiz generation using Apple Foundation Models (iOS 26+).
/// Generates dynamic, challenging MCQ questions for each architecture block.
/// Falls back to static shuffled questions when the model is unavailable.
@available(iOS 26, *)
struct AIQuizService {

    // MARK: - Public API

    /// Generates 3 MCQ questions for a specific block type in a problem context.
    /// Returns shuffled static questions if AI generation fails.
    func generateQuestions(
        blockType: NodeType,
        problemTitle: String,
        problemDescription: String,
        tierLevel: String
    ) async -> [QuizQuestion] {
        guard SystemLanguageModel.default.isAvailable else {
            return []
        }

        do {
            let session = LanguageModelSession(
                instructions: """
                You are a strict iOS system design quiz generator for university-level students. \
                Generate challenging multiple-choice questions that test deep understanding, not surface recall. \
                CRITICAL RULES: \
                1. All four options MUST be between 25 and 70 characters long — similar lengths. \
                2. Every distractor must be plausible and technically sound in a different context. \
                3. Questions must require reasoning, not just memorization. \
                4. Vary the correct answer position randomly across A, B, C, D. \
                5. Output valid JSON only, no markdown fences.
                """
            )

            let prompt = buildPrompt(
                blockType: blockType,
                problemTitle: problemTitle,
                problemDescription: problemDescription,
                tierLevel: tierLevel
            )

            let response = try await session.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

            let questions = parseQuestions(json: text, blockType: blockType)
            guard questions.count == 3 else { return [] }
            return questions

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
        Generate exactly 3 challenging multiple-choice questions about the \
        "\(blockType.displayName)" component in this iOS architecture problem:

        Problem: \(problemTitle) (\(tierLevel))
        Context: \(problemDescription)
        Component role: \(roleDescription(for: blockType))

        Return a JSON array of 3 objects. Each object must have:
        - "question": the question text (40-120 characters)
        - "options": array of exactly 4 strings (each 25-70 characters, similar lengths)
        - "correct": integer 0-3 indicating the correct option index (vary this!)
        - "explanation": why the correct answer is right (1-2 sentences)

        Example format:
        [{"question":"...","options":["...","...","...","..."],"correct":2,"explanation":"..."}]
        """
    }

    private func roleDescription(for nodeType: NodeType) -> String {
        switch nodeType {
        case .ui:
            return "Renders views, handles user input, delegates logic to ViewModel"
        case .viewModel:
            return "Holds UI state, transforms data, mediates between View and data layers"
        case .database:
            return "Persists data locally using SwiftData/Core Data/SQLite"
        case .api:
            return "Handles HTTP networking, request encoding, response decoding"
        case .repository:
            return "Abstracts data sources, provides single source of truth"
        case .networkCache:
            return "Caches network responses to reduce redundant API calls"
        case .memoryCache:
            return "In-memory store for fast repeated access to recently used data"
        case .backgroundWorker:
            return "Offloads heavy computation off the main thread using structured concurrency"
        case .imageCache:
            return "Downloads, decodes, and caches images for smooth scrolling"
        case .lazyLoader:
            return "Defers resource loading until content is about to appear on screen"
        case .circuitBreaker:
            return "Prevents cascading failures by stopping calls to a failing service"
        case .retryHandler:
            return "Retries failed operations with configurable backoff strategies"
        case .fallback:
            return "Provides degraded but functional behavior when primary path fails"
        case .healthMonitor:
            return "Tracks system/service health and triggers recovery actions"
        case .mlModel:
            return "Runs Core ML inference on-device for predictions and classification"
        case .websocket:
            return "Maintains persistent bidirectional connection for real-time data"
        case .eventBus:
            return "Decouples publishers and subscribers for reactive data flow"
        case .stateMachine:
            return "Manages valid state transitions and prevents illegal state combinations"
        }
    }

    // MARK: - Parsing

    private func parseQuestions(json: String, blockType: NodeType) -> [QuizQuestion] {
        // Strip markdown fences if present
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return [] }

        var questions: [QuizQuestion] = []

        for (i, obj) in array.prefix(3).enumerated() {
            guard let questionText = obj["question"] as? String,
                  let options = obj["options"] as? [String],
                  let correct = obj["correct"] as? Int,
                  let explanation = obj["explanation"] as? String,
                  options.count == 4,
                  (0 ... 3).contains(correct)
            else { continue }

            let question = QuizQuestion(
                id: "ai_\(blockType.rawValue)_\(i)_\(UUID().uuidString.prefix(6))",
                blockType: blockType,
                questionText: questionText,
                options: options,
                correctIndex: correct,
                explanation: explanation
            )
            questions.append(question)
        }

        return questions
    }
}
