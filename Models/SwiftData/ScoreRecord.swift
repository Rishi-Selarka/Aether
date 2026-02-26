import Foundation

/// Score with date for "Best Today" filtering. Codable for JSON persistence.
struct ScoreRecord: Codable {
    let score: Double
    let date: Date
}
