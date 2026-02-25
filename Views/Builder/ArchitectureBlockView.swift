import SwiftUI

/// A single draggable architecture block — 2.5D glass card with icon glow halo.
struct ArchitectureBlockView: View {
    let nodeType: NodeType
    let isDragging: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Glowing icon
            ZStack {
                // Outer glow halo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                nodeType.accentColor.opacity(0.35),
                                nodeType.accentColor.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 6,
                            endRadius: 28
                        )
                    )
                    .frame(width: 56, height: 56)

                // Inner disc
                Circle()
                    .fill(nodeType.accentColor.opacity(0.2))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Circle()
                            .strokeBorder(nodeType.accentColor.opacity(0.4), lineWidth: 1)
                    }

                Image(systemName: nodeType.sfSymbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(nodeType.accentColor)
            }

            // Name only — no tier hint
            Text(nodeType.displayName)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            // Drag grip dots
            VStack(spacing: 3) {
                ForEach(0 ..< 3, id: \.self) { _ in
                    HStack(spacing: 3) {
                        Circle().frame(width: 3, height: 3)
                        Circle().frame(width: 3, height: 3)
                    }
                }
            }
            .foregroundStyle(.white.opacity(isDragging ? 0.5 : 0.2))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(height: 72)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                // Glass fill
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .opacity(isDragging ? 0.9 : 0.6)

                // Accent edge glow when dragging
                RoundedRectangle(cornerRadius: 18)
                    .fill(nodeType.accentColor.opacity(isDragging ? 0.08 : 0.0))

                // Border
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isDragging
                            ? nodeType.accentColor.opacity(0.6)
                            : .white.opacity(0.12),
                        lineWidth: isDragging ? 1.5 : 0.8
                    )
            }
        }
        .scaleEffect(isDragging ? 1.04 : 1.0)
        .shadow(
            color: isDragging ? nodeType.accentColor.opacity(0.4) : .black.opacity(0.2),
            radius: isDragging ? 16 : 6,
            y: isDragging ? 0 : 4
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .accessibilityLabel(nodeType.displayName)
        .accessibilityAddTraits(.allowsDirectInteraction)
    }
}
