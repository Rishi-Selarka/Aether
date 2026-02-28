import SwiftUI

enum LayoutConstants {
    static let spacingXS: CGFloat = 8
    static let spacingS: CGFloat = 16
    static let spacingM: CGFloat = 24
    static let spacingL: CGFloat = 32
    static let spacingXL: CGFloat = 40
    static let spacingXXL: CGFloat = 48
    
    static let cornerRadiusS: CGFloat = 12
    static let cornerRadiusM: CGFloat = 16
    static let cornerRadiusL: CGFloat = 20
    
    static let nodeSize: CGFloat = 100
    static let nodeIconSize: CGFloat = 32
    
    static let gridSize: CGFloat = 8
    
    // Responsive layout — iPad uses more screen, caps max width for readability
    static let contentMaxWidthCompact: CGFloat = 600   // iPhone: use full width
    static let contentMaxWidthRegular: CGFloat = 840  // iPad: readable max, use ~80% of typical iPad
    static let horizontalPaddingCompact: CGFloat = 20
    static let horizontalPaddingRegular: CGFloat = 48 // iPad: more breathing room
}

// MARK: - Responsive Values

enum ResponsiveLayout {
    /// Block canvas box size: larger on iPad for better use of space.
    static func blockBoxSize(horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        horizontalSizeClass == .regular ? 130 : 110
    }

    /// Horizontal padding for main content.
    static func contentPadding(horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        horizontalSizeClass == .regular ? LayoutConstants.horizontalPaddingRegular : LayoutConstants.horizontalPaddingCompact
    }

    /// Max width for modal/overlay content to avoid over-stretching on iPad.
    static func overlayMaxWidth(geometryWidth: CGFloat) -> CGFloat {
        min(geometryWidth - 64, 560)
    }
}
