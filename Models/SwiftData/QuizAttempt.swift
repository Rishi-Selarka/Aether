import Foundation
import SwiftData

@Model
final class QuizAttempt {
    var tierID: Int
    var problemIndex: Int
    var problemTitle: String
    var score: Double           // 0–100
    var passed: Bool            // score >= 75
    var totalQuestions: Int
    var correctAnswers: Int
    var timestamp: Date
    var analysisJSON: String    // Serialized AI analysis for replay

    init(
        tierID: Int,
        problemIndex: Int,
        problemTitle: String,
        score: Double,
        passed: Bool,
        totalQuestions: Int,
        correctAnswers: Int,
        analysisJSON: String = ""
    ) {
        self.tierID = tierID
        self.problemIndex = problemIndex
        self.problemTitle = problemTitle
        self.score = score
        self.passed = passed
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timestamp = Date()
        self.analysisJSON = analysisJSON
    }
}
