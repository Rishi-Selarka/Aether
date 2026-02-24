import SwiftUI

struct NodeView: View {
    let node: GraphNode
    let isSelected: Bool
    let isConnectionTarget: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onLearnMore: () -> Void
    let onDragEnd: (CGSize) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @State private var dragOffset: CGSize = .zero

    private var nodeType: NodeType {
        node.type
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: nodeType.sfSymbol)
                .font(.system(size: LayoutConstants.nodeIconSize, weight: .medium))
                .foregroundStyle(nodeType.accentColor)
            
            Text(nodeType.displayName)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: LayoutConstants.nodeSize, height: LayoutConstants.nodeSize)
        .padding(LayoutConstants.spacingXS)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusM)
                .fill(Color.archsysSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusM)
                .stroke(borderColor, lineWidth: colorSchemeContrast == .increased ? (isSelected ? 3 : 2) : (isSelected ? 2 : 1))
        )
        .archsysShadow(.medium)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .offset(dragOffset)
        .animation(reduceMotion ? nil : .spring(response: 0.3), value: isSelected)
        .gesture(
            DragGesture()
                .onChanged { dragOffset = $0.translation }
                .onEnded { value in
                    onDragEnd(value.translation)
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            HapticManager.selection()
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            HapticManager.mediumImpact()
            onLongPress()
        }
        .accessibilityLabel("\(nodeType.displayName) node")
        .accessibilityHint(isSelected ? "Selected. Double tap to deselect or connect." : "Double tap to select. Long press to connect.")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .contextMenu {
            Button {
                HapticManager.lightImpact()
                onLearnMore()
            } label: {
                Label("Learn More", systemImage: "book.fill")
            }
            Button {
                HapticManager.lightImpact()
                onLongPress()
            } label: {
                Label("Connect", systemImage: "arrow.triangle.branch")
            }
        }
    }
    
    private var borderColor: Color {
        let base: Color
        if isSelected { base = nodeType.accentColor }
        else if isConnectionTarget { base = nodeType.accentColor.opacity(0.6) }
        else { base = Color.archsysBorder(for: colorSchemeContrast) }
        return base
    }
}
