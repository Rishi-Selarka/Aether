import SwiftUI

/// A square blueprint-style architecture node box.
/// Resembles a schematic component from a system-design diagram.
struct ArchitectureBlockView: View {
    let nodeType: NodeType
    let isDragging: Bool
    var isLocked: Bool = false
    var boxSize: CGFloat = 110

    var body: some View {
        VStack(spacing: 6) {
            // Icon area
            ZStack {
                // Blueprint grid background
                RoundedRectangle(cornerRadius: 6)
                    .fill(nodeType.accentColor.opacity(isDragging ? 0.12 : 0.06))
                    .frame(width: 44, height: 44)

                // Port notch (top) - schematic in-port
                RoundedRectangle(cornerRadius: 1)
                    .fill(nodeType.accentColor.opacity(0.5))
                    .frame(width: 8, height: 3)
                    .offset(y: -20.5)

                Image(systemName: nodeType.sfSymbol)
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundStyle(nodeType.accentColor)
            }

            // Component name
            Text(nodeType.displayName)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Out-port notch (bottom)
            RoundedRectangle(cornerRadius: 1)
                .fill(nodeType.accentColor.opacity(0.4))
                .frame(width: 8, height: 3)
        }
        .frame(width: boxSize, height: boxSize)
        .background {
            ZStack {
                // Dark schematic fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 0.10))

                // Blueprint border - double stroke
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isDragging
                            ? nodeType.accentColor.opacity(0.7)
                            : Color(white: 0.22),
                        lineWidth: isDragging ? 1.8 : 1
                    )

                // Inner thin border for depth
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isDragging
                            ? nodeType.accentColor.opacity(0.15)
                            : Color(white: 0.15),
                        lineWidth: 0.5
                    )
                    .padding(3)

                // Lock overlay when quiz not accessible
                if isLocked {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.15))
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // Corner bracket - schematic feel
            CornerBracket()
                .stroke(Color(white: 0.25), lineWidth: 0.8)
                .frame(width: 10, height: 10)
                .offset(x: -6, y: 6)
        }
        .scaleEffect(isDragging ? 1.06 : 1.0)
        .shadow(
            color: isDragging ? nodeType.accentColor.opacity(0.35) : .black.opacity(0.4),
            radius: isDragging ? 14 : 4,
            y: isDragging ? 0 : 3
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isDragging)
        .accessibilityLabel(nodeType.displayName)
        .accessibilityAddTraits(.allowsDirectInteraction)
    }
}

// MARK: - Corner Bracket Shape

/// Tiny L-shaped bracket drawn in the top-right corner of each node box.
private struct CornerBracket: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
    }
}
