import SwiftUI

struct ComponentToolbarView: View {
    let nodeTypes: [NodeType]
    let onSelect: (NodeType) -> Void
    let onDragStart: (NodeType) -> Void
    let onDragEnd: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LayoutConstants.spacingS) {
                ForEach(nodeTypes) { type in
                    ComponentToolbarCell(
                        nodeType: type,
                        onTap: { onSelect(type) },
                        onDragStart: { onDragStart(type) },
                        onDragEnd: onDragEnd
                    )
                }
            }
            .padding(.horizontal, LayoutConstants.spacingM)
        }
        .frame(height: 100)
        .background(Color.archsysSurface)
    }
}

struct ComponentToolbarCell: View {
    let nodeType: NodeType
    let onTap: () -> Void
    let onDragStart: () -> Void
    let onDragEnd: () -> Void

    @State private var hasTriggeredDragHaptic = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: nodeType.sfSymbol)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(nodeType.accentColor)
            Text(nodeType.displayName)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextSecondary)
                .lineLimit(1)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusS)
                .fill(Color.archsysSurfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusS)
                .stroke(Color.archsysBorder, lineWidth: 1)
        )
        .onTapGesture {
            HapticManager.lightImpact()
            onTap()
        }
        .draggable(nodeType.rawValue)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { _ in
                    if !hasTriggeredDragHaptic {
                        HapticManager.lightImpact()
                        hasTriggeredDragHaptic = true
                    }
                    onDragStart()
                }
                .onEnded { _ in
                    hasTriggeredDragHaptic = false
                    onDragEnd()
                }
        )
        .accessibilityLabel("Add \(nodeType.displayName)")
        .accessibilityHint("Double tap to add, or drag onto canvas")
    }
}
