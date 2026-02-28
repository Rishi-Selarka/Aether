import SwiftUI

enum InteriorConstants {
    // Water-level labels per tier
    static let levels: [Int: String] = [
        1: "Pond",
        2: "River",
        3: "Sea",
        4: "Ocean",
        5: "Abyss",
    ]

    // Time limit range (minutes)
    static let timeLimitMin = 3
    static let timeLimitMax = 15
    static let timeLimitDefault = 5

    // Glass card styling
    static let cardCornerRadius: CGFloat = 24
    static let cardBorderOpacity: Double = 0.3
    static let cardBorderWidth: CGFloat = 1
    static let cardPaddingHorizontal: CGFloat = 24
    static let cardPaddingVertical: CGFloat = 20

    // Enter button
    static let enterButtonHeight: CGFloat = 56
    static let enterButtonCornerRadius: CGFloat = 16
    static let enterGradientStart = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let enterGradientEnd = Color(red: 0.1, green: 0.4, blue: 0.85)

    // Fallback gradient backgrounds when images are missing
    static let fallbackGradients: [Int: [Color]] = [
        1: [Color(red: 0.1, green: 0.3, blue: 0.5), Color(red: 0.15, green: 0.5, blue: 0.6)],
        2: [Color(red: 0.08, green: 0.25, blue: 0.5), Color(red: 0.1, green: 0.45, blue: 0.55)],
        3: [Color(red: 0.05, green: 0.2, blue: 0.45), Color(red: 0.08, green: 0.4, blue: 0.5)],
        4: [Color(red: 0.03, green: 0.15, blue: 0.4), Color(red: 0.05, green: 0.35, blue: 0.45)],
        5: [Color(red: 0.02, green: 0.08, blue: 0.25), Color(red: 0.04, green: 0.2, blue: 0.35)],
    ]

    // Asset catalog image names per tier.
    // Tiers 4 and 5 share the same abyss image.
    static let backgroundImages: [Int: String] = [
        1: "interior_pond",
        2: "interior_river",
        3: "interior_gulf",
        4: "interior_abyss",
        5: "interior_abyss",
    ]
}
