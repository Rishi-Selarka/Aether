import SwiftUI

/// Vertical canvas showing draggable architecture node boxes in a
/// system-design schematic layout. Clean circuit-board connectors
/// link each component. Ambient particle field adds subtle depth.
struct BlockCanvasView: View {
    let correctOrder: [NodeType]
    @Binding var currentOrder: [NodeType]
    let completedBlocks: Set<NodeType>
    let isOrdered: Bool
    let onBlockTap: (NodeType) -> Void

    // MARK: - State

    @State private var draggingIndex: Int?
    @State private var dragOffset: CGFloat = 0
    @State private var blockFrames: [Int: CGRect] = [:]

    private let gridSpacing: CGFloat = 30
    private let connectorHeight: CGFloat = 44

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background — blueprint grid + faint ambient particles
            blueprintBackground

            // Blocks + connectors
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(currentOrder.enumerated()), id: \.element) { index, node in
                        VStack(spacing: 0) {
                            blockRow(node: node, index: index)

                            if index < currentOrder.count - 1 {
                                circuitConnector(index: index)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
            }
        }
        // Fix overlap: when isOrdered flips, immediately settle any active drag
        .onChange(of: isOrdered) { _, ordered in
            if ordered {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    draggingIndex = nil
                    dragOffset = 0
                    blockFrames.removeAll()
                }
            }
        }
    }

    // MARK: - Blueprint Background

    private var blueprintBackground: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Grid dots — subtle blueprint feel
                drawSchematicGrid(ctx: ctx, size: size, time: time)

                // Subtle ambient particles — monochrome, architecture-feel
                drawAmbientField(ctx: ctx, size: size, time: time)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func drawSchematicGrid(ctx: GraphicsContext, size: CGSize, time: Double) {
        let cols = Int(size.width / gridSpacing) + 1
        let rows = Int(size.height / gridSpacing) + 1

        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let x = CGFloat(col) * gridSpacing
                let y = CGFloat(row) * gridSpacing

                // Crosshair-style dots (+ shape instead of circles)
                let alpha = 0.06 + sin(time * 0.3 + Double(row * 3 + col) * 0.15) * 0.02
                let arm: CGFloat = 1.6

                // Horizontal arm
                ctx.fill(
                    Path(CGRect(x: x - arm, y: y - 0.4, width: arm * 2, height: 0.8)),
                    with: .color(.white.opacity(alpha))
                )
                // Vertical arm
                ctx.fill(
                    Path(CGRect(x: x - 0.4, y: y - arm, width: 0.8, height: arm * 2)),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
    }

    /// Monochrome ambient particles — white/grey, slow drift, no rainbow.
    private func drawAmbientField(ctx: GraphicsContext, size: CGSize, time: Double) {
        for i in 0 ..< 20 {
            let s = Double(i)
            let xNorm = fmod(s * 0.3717 + sin(time * 0.08 + s * 1.6) * 0.02, 1.0)
            let yNorm = fmod(s * 0.4331 + time * (0.004 + fmod(s * 0.002, 0.006)), 1.0)
            let dotSize: CGFloat = 2.0 + CGFloat(fmod(s * 0.41, 1.5))
            let pulse = 0.5 + sin(time * 0.8 + s * 0.9) * 0.5
            let alpha = (0.06 + fmod(s * 0.018, 0.06)) * pulse

            let px = CGFloat(xNorm) * size.width
            let py = CGFloat(yNorm) * size.height

            // Subtle white glow
            let glowSize = dotSize * 3
            ctx.fill(
                Path(ellipseIn: CGRect(x: px - glowSize / 2, y: py - glowSize / 2,
                                       width: glowSize, height: glowSize)),
                with: .color(.white.opacity(alpha * 0.3))
            )
            ctx.fill(
                Path(ellipseIn: CGRect(x: px - dotSize / 2, y: py - dotSize / 2,
                                       width: dotSize, height: dotSize)),
                with: .color(.white.opacity(alpha))
            )
        }
    }

    // MARK: - Circuit Connector

    /// Clean vertical data-flow line between components with small arrow indicator.
    private func circuitConnector(index: Int) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let midX = size.width / 2
                let topY: CGFloat = 2
                let bottomY = size.height - 2

                // Dashed vertical line
                let linePath = Path { p in
                    p.move(to: CGPoint(x: midX, y: topY))
                    p.addLine(to: CGPoint(x: midX, y: bottomY))
                }
                ctx.stroke(
                    linePath,
                    with: .color(Color(white: 0.3)),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )

                // Downward arrow chevron at center
                let arrowY = size.height / 2
                let chevron = Path { p in
                    p.move(to: CGPoint(x: midX - 4, y: arrowY - 3))
                    p.addLine(to: CGPoint(x: midX, y: arrowY + 3))
                    p.addLine(to: CGPoint(x: midX + 4, y: arrowY - 3))
                }
                ctx.stroke(
                    chevron,
                    with: .color(Color(white: 0.4)),
                    style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round)
                )

                // Single small data-pulse dot travelling downward
                let pulseT = fmod(time * 0.7 + Double(index) * 0.4, 1.0)
                let pulseY = topY + CGFloat(pulseT) * (bottomY - topY)
                let life = 1.0 - abs(pulseT - 0.5) * 2.0 // peaks at center

                ctx.fill(
                    Path(ellipseIn: CGRect(x: midX - 2, y: pulseY - 2, width: 4, height: 4)),
                    with: .color(.white.opacity(life * 0.35))
                )
                // Glow ring
                ctx.fill(
                    Path(ellipseIn: CGRect(x: midX - 5, y: pulseY - 5, width: 10, height: 10)),
                    with: .color(.white.opacity(life * 0.08))
                )
            }
        }
        .frame(height: connectorHeight)
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
    }

    // MARK: - Block Row

    @ViewBuilder
    private func blockRow(node: NodeType, index: Int) -> some View {
        let isDraggingThis = draggingIndex == index
        let quizDone = completedBlocks.contains(node)

        ZStack(alignment: .topTrailing) {
            ArchitectureBlockView(
                nodeType: node,
                isDragging: isDraggingThis,
                isLocked: !isOrdered
            )

            if quizDone {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.5), radius: 4)
                    .offset(x: -6, y: 4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .offset(y: isDraggingThis ? dragOffset : 0)
        .zIndex(isDraggingThis ? 10 : 0)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        blockFrames[index] = geo.frame(in: .global)
                    }
                    .onChange(of: currentOrder) { _, _ in
                        DispatchQueue.main.async {
                            blockFrames[index] = geo.frame(in: .global)
                        }
                    }
            }
        )
        .onTapGesture {
            guard isOrdered else { return }
            HapticManager.lightImpact()
            onBlockTap(node)
        }
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
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        draggingIndex = nil
                        dragOffset = 0
                    }
                }
        )
        .accessibilityAction(named: "Move up") {
            guard index > 0 else { return }
            swapBlocks(at: index, with: index - 1)
        }
        .accessibilityAction(named: "Move down") {
            guard index < currentOrder.count - 1 else { return }
            swapBlocks(at: index, with: index + 1)
        }
    }

    // MARK: - Helpers

    private func swapBlocks(at a: Int, with b: Int) {
        guard a >= 0, b >= 0, a < currentOrder.count, b < currentOrder.count else { return }
        var newOrder = currentOrder
        newOrder.swapAt(a, b)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentOrder = newOrder
        }
        HapticManager.selection()
    }

    private func swapIfNeeded(draggingIndex idx: Int, translation: CGFloat) {
        guard let currentFrame = blockFrames[idx] else { return }
        let midY = currentFrame.midY + translation

        for (otherIndex, otherFrame) in blockFrames {
            guard otherIndex != idx else { continue }
            if otherFrame.contains(CGPoint(x: otherFrame.midX, y: midY)) {
                swapBlocks(at: idx, with: otherIndex)
                self.draggingIndex = otherIndex
                return
            }
        }
    }
}
