import UIKit

/// Centralized haptic feedback and VoiceOver announcements.
@MainActor
enum HapticManager {

    /// Success feedback (e.g. connection created, evaluation complete)
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// Error feedback (e.g. invalid connection, validation failed)
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    /// Selection feedback (e.g. tab bar, picker, segmented control)
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    /// Impact feedback - light (e.g. node tap, button tap)
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    /// Light impact for subtle interactions (button taps, selections)
    static func lightImpact() {
        impact(style: .light)
    }
    
    /// Medium impact for more significant actions (drop, connect)
    static func mediumImpact() {
        impact(style: .medium)
    }

    /// Posts a VoiceOver announcement for state changes.
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}
