import SwiftUI

/// Scrollable vertical canvas showing draggable architecture blocks.
/// Drag-to-reorder swap logic uses geometry-based hit detection.
struct BlockCanvasView: View {
    let correctOrder: [NodeType]
    /// Blocks in current user-arranged order.
    @Binding var currentOrder: [NodeType]
    /// Set of block types whose quiz has been completed (shown with badge).
    let completedBlocks: Set<NodeType>
    /// Whether ordering phase is done (all blocks correct).
    let isOrdered: Bool
    /// Called when user taps a block to open its quiz.
    let onBlockTap: (NodeType) -> Void

    // MARK: - Drag State

    @State private var draggingIndex: Int?
    @State private var dragOffset: CGFloat = 0
    @State private var blockFrames: [Int: CGRect] = [:]

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(currentOrder.enumerated()), id: \.element) { index, node in
                    VStack(spacing: 0) {
                        blockRow(node: node, index: index)

                        // Connection line between blocks (not after last)
                        if index < currentOrder.count - 1 {
                            connectionLine(
                                fromColor: currentOrder[index].accentColor,
                                toColor: currentOrder[index + 1].accentColor
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Block Row

    @ViewBuilder
    private func blockRow(node: NodeType, index: Int) -> some View {
        let isDraggingThis = draggingIndex == index
        let isCorrect = isCorrectlyPlaced(node: node, at: index)
        let quizDone = completedBlocks.contains(node)

        ZStack(alignment: .topTrailing) {
            ArchitectureBlockView(
                nodeType: node,
                index: index,
                isCorrectlyPlaced: isCorrect,
                isDragging: isDraggingThis
            )
            .offset(y: isDraggingThis ? dragOffset : 0)
            .zIndex(isDraggingThis ? 1 : 0)
            // Quiz completion badge
            if quizDone {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.yellow)
                    .offset(x: -8, y: -4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    blockFrames[index] = geo.frame(in: .global)
                }
                .onChange(of: currentOrder) { _, _ in
                    blockFrames[index] = geo.frame(in: .global)
                }
            }
        )
        // Tap to quiz (only when ordering complete)
        .onTapGesture {
            if isOrdered {
                HapticManager.lightImpact()
                onBlockTap(node)
            }
        }
        // Drag to reorder (ignored once correctly ordered)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    guard !isOrdered else { return }
                    if draggingIndex == nil {
                        draggingIndex = index
                        HapticManager.mediumImpact()
                    }
                    dragOffset = value.translation.height
                    swapIfNeeded(draggingIndex: index, translation: value.translation.height)
                }
                .onEnded { _ in
                    guard !isOrdered else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        draggingIndex = nil
                        dragOffset = 0
                    }
                }
        )
        .accessibilityAction(named: "Move up") {
            guard index > 0 else { return }
            swap(at: index, with: index - 1)
        }
        .accessibilityAction(named: "Move down") {
            guard index < currentOrder.count - 1 else { return }
            swap(at: index, with: index + 1)
        }
    }

    // MARK: - Connection Line

    private func connectionLine(fromColor: Color, toColor: Color) -> some View {
        VStack(spacing: 0) {
            // Gradient dashed line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [fromColor.opacity(0.5), toColor.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 24)
                .overlay(
                    // Arrow chevron in middle
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .offset(y: 4)
                )
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 24)
    }

    // MARK: - Helpers

    private func isCorrectlyPlaced(node: NodeType, at index: Int) -> Bool {
        guard index < correctOrder.count else { return false }
        return correctOrder[index] == node
    }

    private func swap(at a: Int, with b: Int) {
        guard a >= 0, b >= 0, a < currentOrder.count, b < currentOrder.count else { return }
        var newOrder = currentOrder
        newOrder.swapAt(a, b)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            currentOrder = newOrder
        }
        HapticManager.selection()
    }

    /// Swaps blocks when the dragged block's midpoint crosses another block's boundary.
    private func swapIfNeeded(draggingIndex: Int, translation: CGFloat) {
        guard let currentFrame = blockFrames[draggingIndex] else { return }
        let midY = currentFrame.midY + translation

        for (otherIndex, otherFrame) in blockFrames {
            guard otherIndex != draggingIndex else { continue }
            if otherFrame.contains(CGPoint(x: otherFrame.midX, y: midY)) {
                swap(at: draggingIndex, with: otherIndex)
                self.draggingIndex = otherIndex
                return
            }
        }
    }
}
