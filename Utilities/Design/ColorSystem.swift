import SwiftUI

extension Color {
    static let archsysBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark ? .black : .white
    })
    static let archsysSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.11, alpha: 1)
            : UIColor(white: 0.94, alpha: 1)
    })
    static let archsysSurfaceElevated = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.17, alpha: 1)
            : UIColor(white: 0.88, alpha: 1)
    })
    static let archsysBorder = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.22, alpha: 1)
            : UIColor(white: 0.78, alpha: 1)
    })
    static let archsysTextPrimary = Color(UIColor { t in
        t.userInterfaceStyle == .dark ? .white : .black
    })
    static let archsysTextSecondary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.6, alpha: 1)
            : UIColor(white: 0.35, alpha: 1)
    })
    static let archsysTextTertiary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.39, alpha: 1)
            : UIColor(white: 0.55, alpha: 1)
    })

    /// High contrast border (stronger visibility when Increase Contrast is on).
    static func archsysBorder(for colorSchemeContrast: ColorSchemeContrast) -> Color {
        colorSchemeContrast == .increased
            ? Color(UIColor { t in
                t.userInterfaceStyle == .dark
                    ? UIColor(white: 0.45, alpha: 1)
                    : UIColor(white: 0.55, alpha: 1)
            })
            : Color.archsysBorder
    }

    // MARK: - Home Screen

    static let homeAccent = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 1)
            : UIColor(red: 0.20, green: 0.42, blue: 0.75, alpha: 1)
    })

    static let homeAccentMuted = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.25)
            : UIColor(red: 0.20, green: 0.42, blue: 0.75, alpha: 0.12)
    })

    /// Success/correct state (e.g. quiz correct answer).
    static let archsysSuccess = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1)
            : UIColor(red: 0.15, green: 0.5, blue: 0.25, alpha: 1)
    })

    /// Error/incorrect state (e.g. quiz wrong answer).
    static let archsysError = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
            : UIColor(red: 0.75, green: 0.2, blue: 0.2, alpha: 1)
    })
}
