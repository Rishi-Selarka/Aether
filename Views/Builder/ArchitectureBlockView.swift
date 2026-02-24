import SwiftUI

/// A single draggable architecture block tile.
struct ArchitectureBlockView: View {
    let nodeType: NodeType
    let index: Int
    let isCorrectlyPlaced: Bool
    let isDragging: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Index badge
            Text("\(index + 1)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 24)

            // Icon
            ZStack {
                Circle()
                    .fill(nodeType.accentColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: nodeType.sfSymbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(nodeType.accentColor)
            }

            // Name
            VStack(alignment: .leading, spacing: 3) {
                Text(nodeType.displayName)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tier \(nodeType.tierLevel) component")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Correct placement indicator
            if isCorrectlyPlaced {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(isDragging ? 0.12 : 0.07))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isCorrectlyPlaced
                                ? Color.green.opacity(0.6)
                                : (isDragging ? nodeType.accentColor.opacity(0.6) : Color.white.opacity(0.12)),
                            lineWidth: isCorrectlyPlaced ? 1.5 : 1
                        )
                }
        }
        .scaleEffect(isDragging ? 1.03 : 1.0)
        .shadow(color: isDragging ? nodeType.accentColor.opacity(0.3) : .clear, radius: 12)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isCorrectlyPlaced)
        .accessibilityLabel("\(nodeType.displayName), position \(index + 1)")
        .accessibilityAddTraits(.allowsDirectInteraction)
    }
}
