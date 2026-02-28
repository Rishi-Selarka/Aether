import SwiftUI

/// Accessibility helpers for reduce motion, high contrast, and touch targets.
enum AccessibilityManager {
    
    /// Returns animation to use: nil or .identity when reduce motion is enabled.
    static func preferredAnimation(
        default defaultAnimation: Animation? = .default,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : defaultAnimation
    }
    
    /// Returns transition to use: .opacity when reduce motion, otherwise the provided one.
    static func preferredTransition(
        default defaultTransition: AnyTransition = .opacity,
        reduceMotion: Bool
    ) -> AnyTransition {
        reduceMotion ? .opacity : defaultTransition
    }
    
    /// Minimum touch target size per Apple HIG (44x44 pt).
    static let minimumTouchTarget: CGFloat = 44
}

// MARK: - View Extensions for Accessibility

struct MinTouchTargetModifier: ViewModifier {
    @ScaledMetric(relativeTo: .body) private var minSize: CGFloat = 44

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .frame(minWidth: max(minSize, AccessibilityManager.minimumTouchTarget),
                   minHeight: max(minSize, AccessibilityManager.minimumTouchTarget))
    }
}

extension View {
    /// Ensures minimum 44x44 pt touch target (scales with Dynamic Type).
    func aetherMinTouchTarget() -> some View {
        modifier(MinTouchTargetModifier())
    }
}
