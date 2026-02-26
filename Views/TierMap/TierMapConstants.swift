import SwiftUI

enum TierMapConstants {
    static let canvasHeight: CGFloat = 1600

    // City names derived from tier ID - no SwiftData migration needed
    static let cityNames: [Int: String] = [
        1: "Tokyo",
        2: "London",
        3: "Singapore",
        4: "New York",
        5: "San Francisco"
    ]

    // SF Symbol icons per tier
    static let cityIcons: [Int: String] = [
        1: "building.2.fill",
        2: "network",
        3: "bolt.fill",
        4: "shield.fill",
        5: "brain.head.profile"
    ]

    // City positions on canvas: (xFraction of width, absolute Y)
    static let positions: [Int: (xFraction: CGFloat, y: CGFloat)] = [
        1: (0.25, 280),
        2: (0.70, 530),
        3: (0.35, 830),
        4: (0.75, 1130),
        5: (0.45, 1430)
    ]

    // Muted blueprint-compatible status colors
    static let completedColor = Color(red: 56 / 255, green: 166 / 255, blue: 92 / 255)
    static let unlockedColor = Color(red: 64 / 255, green: 133 / 255, blue: 217 / 255)

    // Per-city skyline tint - applied as a color overlay on the shared skyline image
    static let cityTints: [Int: Color] = [
        1: Color(red: 0.98, green: 0.28, blue: 0.56),  // Tokyo - sakura neon
        2: Color(red: 0.16, green: 0.44, blue: 0.80),  // London - Thames blue
        3: Color(red: 0.00, green: 0.74, blue: 0.68),  // Singapore - Marina Bay teal
        4: Color(red: 0.96, green: 0.62, blue: 0.05),  // New York - Empire amber
        5: Color(red: 0.94, green: 0.32, blue: 0.12)   // San Francisco - Golden Gate
    ]

    // Card dimensions
    static let cardWidth: CGFloat = 148
    static let cardHeight: CGFloat = 180
    static let cardImageHeight: CGFloat = 95
    static let cardCornerRadius: CGFloat = 16

    // Marker sizing
    static let outerDiameter: CGFloat = 72
    static let innerDiameter: CGFloat = 64
    static let iconSize: CGFloat = 28
    static let stemHeight: CGFloat = 20
    static let badgeSize: CGFloat = 24

    // Route styling
    static let routeDash: [CGFloat] = [8, 6]
    static let routeLineWidth: CGFloat = 2
}
