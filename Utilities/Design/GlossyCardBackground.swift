import SwiftUI

/// Shared glossy card background modifier.
/// Dark mode: pure black base with white sheen.
/// Light mode: pure white base with black sheen.
struct GlossyCardBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.background { glossy }
    }

    private var glossy: some View {
        let isDark = colorScheme == .dark
        let base: Color  = isDark ? .black : .white
        let sheen: Color = isDark ? .white : .black

        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(base)

            // Diagonal sheen
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            sheen.opacity(isDark ? 0.12 : 0.04),
                            sheen.opacity(isDark ? 0.03 : 0.01),
                            .clear,
                            sheen.opacity(isDark ? 0.05 : 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Edge highlight
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            sheen.opacity(isDark ? 0.25 : 0.12),
                            sheen.opacity(isDark ? 0.08 : 0.04),
                            sheen.opacity(isDark ? 0.04 : 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

extension View {
    func glossyCardBackground(cornerRadius: CGFloat = 14) -> some View {
        modifier(GlossyCardBackground(cornerRadius: cornerRadius))
    }
}
