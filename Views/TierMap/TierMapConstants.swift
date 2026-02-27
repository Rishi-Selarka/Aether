import SwiftUI

enum TierMapConstants {
    static let canvasHeight: CGFloat = 1400

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
        1: (0.25, 200),
        2: (0.70, 380),
        3: (0.35, 680),
        4: (0.75, 980),
        5: (0.45, 1280)
    ]

    // Muted blueprint-compatible status colors
    static let completedColor = Color(red: 56 / 255, green: 166 / 255, blue: 92 / 255)
    static let unlockedColor = Color(red: 64 / 255, green: 133 / 255, blue: 217 / 255)

    // Per-city skyline tint - applied as a color overlay on the shared skyline image
    static let cityTints: [Int: Color] = [
        1: Color(red: 163 / 255, green: 148 / 255, blue: 128 / 255), // Tokyo - burnished gold
        2: Color(red: 112 / 255, green: 128 / 255, blue: 144 / 255), // London - slate blue
        3: Color(red: 143 / 255, green: 110 / 255, blue: 102 / 255), // Singapore - rosewood
        4: Color(red: 130 / 255, green: 155 / 255, blue: 140 / 255), // New York - hunter sage
        5: Color(red: 148 / 255, green: 122 / 255, blue: 140 / 255)  // San Francisco - dusty plum
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
