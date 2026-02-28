import SwiftUI

enum ShadowStyle {
    case low
    case medium
    case high

    var color: Color { Color.black.opacity(0.25) }

    var radius: CGFloat {
        switch self {
        case .low: return 4
        case .medium: return 8
        case .high: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .low: return 2
        case .medium: return 4
        case .high: return 8
        }
    }
}

extension View {
    func aetherShadow(_ style: ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: 0, y: style.y)
    }
}
