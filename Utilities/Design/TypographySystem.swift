import SwiftUI

enum Typography {
    // Display — SF Pro Rounded Bold (Dynamic Type compatible via scaled metrics)
    static let displayLarge: Font = .system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium: Font = .system(size: 36, weight: .bold, design: .rounded)
    static let displaySmall: Font = .system(size: 28, weight: .bold, design: .rounded)

    // Heading — SF Pro Semibold
    static let headingLarge: Font = .system(size: 24, weight: .semibold)
    static let headingMedium: Font = .system(size: 20, weight: .semibold)
    static let headingSmall: Font = .system(size: 18, weight: .semibold)

    // Body — SF Pro Regular
    static let bodyLarge: Font = .system(size: 17)
    static let bodyMedium: Font = .system(size: 15)
    static let bodySmall: Font = .system(size: 13)

    // Code — SF Mono
    static let code: Font = .system(size: 14, design: .monospaced)
}
