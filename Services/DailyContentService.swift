import Foundation
import FoundationModels

// MARK: - Stored Models

struct DailyQuote: Codable {
    let text: String
    let attribution: String
    let dateKey: String
}

struct DailyQuestion: Codable {
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let dateKey: String
    var selectedIndex: Int?
}

// MARK: - AI-Generated Types

@available(iOS 26, *)
@Generable
struct GeneratedDailyQuote {
    @Guide(description: "A short, thought-provoking quote about software architecture, system design, or engineering craft. 10-25 words. Not cliché.")
    var text: String

    @Guide(description: "Attribution: a real software engineer, computer scientist, or author. Use their full name.")
    var attribution: String
}

@available(iOS 26, *)
@Generable
struct GeneratedDailyQuestion {
    @Guide(description: "A concise multiple-choice question about iOS/mobile system design, architecture patterns, or software engineering principles. 40-100 characters.")
    var question: String

    @Guide(description: "Exactly 4 answer options, each 20-60 characters, similar in length and all plausible")
    var options: [String]

    @Guide(description: "Integer 0-3 indicating the correct option")
    var correct: Int

    @Guide(description: "1-2 sentence explanation of why the correct answer is right")
    var explanation: String
}

// MARK: - Service

/// Generates and caches daily quote and question using Apple Foundation Models.
/// Content is keyed by calendar day and persisted in UserDefaults.
enum DailyContentService {

    private static let quoteKey = "archsys_daily_quote"
    private static let questionKey = "archsys_daily_question"

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static var todayKey: String {
        dateFormatter.string(from: Date())
    }

    // MARK: - Quote

    static func loadQuote() async -> DailyQuote {
        if let cached = cachedQuote(), cached.dateKey == todayKey {
            return cached
        }
        let generated = await generateQuote()
        persist(quote: generated)
        return generated
    }

    private static func cachedQuote() -> DailyQuote? {
        guard let data = UserDefaults.standard.data(forKey: quoteKey),
              let quote = try? JSONDecoder().decode(DailyQuote.self, from: data)
        else { return nil }
        return quote
    }

    private static func persist(quote: DailyQuote) {
        guard let data = try? JSONEncoder().encode(quote) else { return }
        UserDefaults.standard.set(data, forKey: quoteKey)
    }

    private static func generateQuote() async -> DailyQuote {
        guard #available(iOS 26, *) else { return fallbackQuote() }
        return await generateQuoteWithFoundationModels()
    }

    @available(iOS 26, *)
    private static func generateQuoteWithFoundationModels() async -> DailyQuote {
        guard SystemLanguageModel.default.isAvailable else { return fallbackQuote() }

        do {
            let session = LanguageModelSession(
                instructions: """
                You generate original, non-cliché quotes about software architecture \
                and system design. The quotes should be insightful and specific to \
                engineering craft, not generic motivational platitudes.
                """
            )
            let response = try await session.respond(
                to: "Generate one original quote about software architecture or system design.",
                generating: GeneratedDailyQuote.self
            )
            let content = response.content
            let text = content.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return fallbackQuote() }
            return DailyQuote(text: text, attribution: content.attribution, dateKey: todayKey)
        } catch {
            return fallbackQuote()
        }
    }

    private static func fallbackQuote() -> DailyQuote {
        let quotes: [(String, String)] = [
            ("The best architectures are discovered, not designed.", "Martin Fowler"),
            ("Make the change easy, then make the easy change.", "Kent Beck"),
            ("A system is only as strong as its weakest abstraction.", "Grady Booch"),
            ("Simplicity is prerequisite for reliability.", "Edsger Dijkstra"),
            ("Good architecture makes the system easy to change in all the ways it needs to change.", "Robert C. Martin")
        ]
        let index = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) % quotes.count
        let (text, attr) = quotes[index]
        return DailyQuote(text: text, attribution: attr, dateKey: todayKey)
    }

    // MARK: - Question

    static func loadQuestion() async -> DailyQuestion {
        if let cached = cachedQuestion(), cached.dateKey == todayKey {
            return cached
        }
        let generated = await generateQuestion()
        persist(question: generated)
        return generated
    }

    /// Bypasses cache and generates a fresh question.
    static func loadFreshQuestion() async -> DailyQuestion {
        let generated = await generateQuestion()
        persist(question: generated)
        return generated
    }

    static func saveAnswer(selectedIndex: Int) {
        guard var question = cachedQuestion() else { return }
        question.selectedIndex = selectedIndex
        persist(question: question)
    }

    private static func cachedQuestion() -> DailyQuestion? {
        guard let data = UserDefaults.standard.data(forKey: questionKey),
              let question = try? JSONDecoder().decode(DailyQuestion.self, from: data)
        else { return nil }
        return question
    }

    private static func persist(question: DailyQuestion) {
        guard let data = try? JSONEncoder().encode(question) else { return }
        UserDefaults.standard.set(data, forKey: questionKey)
    }

    private static func generateQuestion() async -> DailyQuestion {
        guard #available(iOS 26, *) else { return fallbackQuestion() }
        return await generateQuestionWithFoundationModels()
    }

    @available(iOS 26, *)
    private static func generateQuestionWithFoundationModels() async -> DailyQuestion {
        guard SystemLanguageModel.default.isAvailable else { return fallbackQuestion() }

        do {
            let session = LanguageModelSession(
                instructions: """
                You generate challenging multiple-choice questions about iOS system design, \
                architecture patterns (MVC, MVVM, VIPER, Clean Architecture), concurrency, \
                caching, networking, and software engineering principles. Questions should \
                test understanding, not memorisation. All 4 options must be plausible.
                """
            )
            let response = try await session.respond(
                to: "Generate one multiple-choice question about iOS or mobile system design.",
                generating: GeneratedDailyQuestion.self
            )
            let content = response.content
            guard content.options.count == 4, (0...3).contains(content.correct) else {
                return fallbackQuestion()
            }
            return DailyQuestion(
                question: content.question,
                options: content.options,
                correctIndex: content.correct,
                explanation: content.explanation,
                dateKey: todayKey
            )
        } catch {
            return fallbackQuestion()
        }
    }

    private static func fallbackQuestion() -> DailyQuestion {
        DailyQuestion(
            question: "Which pattern separates UI state from business logic via an observable object?",
            options: [
                "Model-View-Controller",
                "Model-View-ViewModel",
                "Model-View-Presenter",
                "Entity-Component-System"
            ],
            correctIndex: 1,
            explanation: "MVVM uses an observable ViewModel to hold UI state and mediate between the View and Model layers, enabling reactive updates without the View knowing about the data source.",
            dateKey: todayKey
        )
    }
}
