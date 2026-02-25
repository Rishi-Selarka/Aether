import SwiftUI

/// Scrollable vertical canvas showing draggable architecture blocks
/// with a three-layer particle system: ambient background, bezier flow
/// streams between blocks, and burst effects on key events.
///
/// Particle types (from plan.md "Enhanced Particle System"):
/// - **Primary**: 12pt glowing core, 6-point trail, bezier path
/// - **Secondary**: 6pt, faster, 3-point trail
/// - **Ambient**: 4pt background drift with glow halos
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
    @State private var burstTriggerTime: Double?

    private let gridSpacing: CGFloat = 30

    // MARK: - Body

    var body: some View {
        ZStack {
            // Layer 1 — Ambient particles + grid dots
            ambientLayer

            // Layer 2 — Blocks with flow-particle streams between them
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(currentOrder.enumerated()), id: \.element) { index, node in
                        VStack(spacing: 0) {
                            blockRow(node: node, index: index)

                            if index < currentOrder.count - 1 {
                                particleStream(
                                    fromColor: currentOrder[index].accentColor,
                                    toColor: currentOrder[index + 1].accentColor,
                                    seed: Double(index)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }

            // Layer 3 — Burst overlay (triggered on correct ordering)
            burstLayer
        }
        .onChange(of: isOrdered) { _, ordered in
            if ordered {
                burstTriggerTime = Date().timeIntervalSinceReferenceDate
            }
        }
    }

    // MARK: - Layer 1: Ambient Background

    private var ambientLayer: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                drawGrid(ctx: ctx, size: size, time: time)
                drawAmbientParticles(ctx: ctx, size: size, time: time)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func drawGrid(ctx: GraphicsContext, size: CGSize, time: Double) {
        let cols = Int(size.width / gridSpacing) + 1
        let rows = Int(size.height / gridSpacing) + 1

        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let x = CGFloat(col) * gridSpacing
                let y = CGFloat(row) * gridSpacing
                let pulse = sin(time * 0.5 + Double(row + col) * 0.3) * 0.5 + 0.5
                let alpha = 0.03 + pulse * 0.05
                let rect = CGRect(x: x - 1.2, y: y - 1.2, width: 2.4, height: 2.4)
                ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(alpha)))
            }
        }
    }

    /// 30 ambient particles (4pt base) drifting slowly with glow halos.
    /// Positions are purely deterministic from time + seed — no @State arrays.
    private func drawAmbientParticles(ctx: GraphicsContext, size: CGSize, time: Double) {
        for i in 0 ..< 30 {
            let s = Double(i)
            let speed = 0.008 + fmod(s * 0.0037, 0.012)
            let xNorm = fmod(s * 0.3717 + sin(time * 0.15 + s * 1.3) * 0.025, 1.0)
            let yNorm = fmod(s * 0.4331 + time * speed, 1.0)
            let dotSize = 3.0 + CGFloat(fmod(s * 0.31, 2.0))
            let baseOpacity = 0.15 + fmod(s * 0.23, 0.22)
            let pulse = 0.55 + sin(time * 1.5 + s * 0.7) * 0.45
            let hue = fmod(s * 0.13, 1.0)

            GlowRenderer.drawDot(
                in: ctx,
                at: CGPoint(x: CGFloat(xNorm) * size.width, y: CGFloat(yNorm) * size.height),
                size: dotSize * CGFloat(max(0.5, pulse)),
                opacity: baseOpacity * pulse,
                hue: hue
            )
        }
    }

    // MARK: - Layer 2: Flow Particle Streams

    /// A tall Canvas between two blocks with primary + secondary particles
    /// flowing along organic bezier curves with glow trails.
    private func particleStream(fromColor: Color, toColor: Color, seed: Double) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let from = CGPoint(x: size.width / 2, y: 0)
                let to = CGPoint(x: size.width / 2, y: size.height)

                // Faint bezier guide curve
                drawGuideCurve(ctx: ctx, from: from, to: to, time: time,
                               fromColor: fromColor, toColor: toColor)

                // Primary particles (3): 12pt, slow, 6-point trail
                for i in 0 ..< 3 {
                    let offset = Double(i) / 3.0 + seed * 0.17
                    let progress = CGFloat(fmod(time * 0.32 + offset, 1.0))
                    let waviness: CGFloat = 0.4 + CGFloat(sin(time * 0.7 + Double(i) * 2.1 + seed)) * 0.3
                    let blended = blendColor(fromColor, toColor, t: Double(progress))
                    let pos = BezierMath.point(from: from, to: to, t: progress,
                                               waviness: waviness, time: time + seed)

                    GlowRenderer.drawTrail(
                        in: ctx, from: from, to: to,
                        headProgress: progress, waviness: waviness,
                        time: time + seed, headSize: 12, color: blended, count: 6
                    )
                    GlowRenderer.drawDot(in: ctx, at: pos, size: 12, opacity: 0.9, color: blended)
                }

                // Secondary particles (5): 6pt, faster, 3-point trail
                for i in 0 ..< 5 {
                    let offset = Double(i) / 5.0 + seed * 0.13
                    let progress = CGFloat(fmod(time * 0.6 + offset + 0.3, 1.0))
                    let waviness: CGFloat = 0.25 + CGFloat(sin(time + Double(i))) * 0.1
                    let blended = blendColor(fromColor, toColor, t: Double(progress))
                    let pos = BezierMath.point(from: from, to: to, t: progress,
                                               waviness: waviness, time: time + seed * 1.7)

                    GlowRenderer.drawTrail(
                        in: ctx, from: from, to: to,
                        headProgress: progress, waviness: waviness,
                        time: time + seed * 1.7, headSize: 6, color: blended, count: 3
                    )
                    GlowRenderer.drawDot(in: ctx, at: pos, size: 6, opacity: 0.55, color: blended)
                }
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
    }

    private func drawGuideCurve(
        ctx: GraphicsContext, from: CGPoint, to: CGPoint,
        time: Double, fromColor: Color, toColor: Color
    ) {
        let path = Path { p in
            p.move(to: from)
            let steps = 12
            for s in 1 ... steps {
                let t = CGFloat(s) / CGFloat(steps)
                let pt = BezierMath.point(from: from, to: to, t: t, waviness: 0.3, time: time)
                p.addLine(to: pt)
            }
        }
        ctx.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [fromColor.opacity(0.12), toColor.opacity(0.12)]),
                startPoint: from, endPoint: to
            ),
            lineWidth: 1
        )
    }

    /// Simple colour blend between two SwiftUI colours at parameter `t`.
    private func blendColor(_ a: Color, _ b: Color, t: Double) -> Color {
        let clamped = min(1, max(0, t))
        // Approximate blend using opacity layering
        return clamped < 0.5 ? a : b
    }

    // MARK: - Layer 3: Burst Effect

    /// 16 exploding particles + expanding ripple ring, fully deterministic.
    private var burstLayer: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            Canvas { ctx, size in
                guard let trigger = burstTriggerTime else { return }
                let elapsed = CGFloat(timeline.date.timeIntervalSinceReferenceDate - trigger)
                guard elapsed >= 0, elapsed < 2.0 else { return }

                let center = CGPoint(x: size.width / 2, y: size.height * 0.4)
                let gravity: CGFloat = 80

                // Burst particles (12 as per plan.md)
                for i in 0 ..< 16 {
                    let angle = CGFloat(i) / 16.0 * .pi * 2 + elapsed * 0.2
                    let force: CGFloat = 100 + CGFloat(i % 4) * 35
                    let x = center.x + cos(angle) * force * elapsed
                    let y = center.y + sin(angle) * force * elapsed + 0.5 * gravity * elapsed * elapsed
                    let life = max(0, 1.0 - elapsed / 1.6)
                    let hue = fmod(Double(i) / 16.0 + Double(elapsed) * 0.08, 1.0)

                    GlowRenderer.drawDot(
                        in: ctx,
                        at: CGPoint(x: x, y: y),
                        size: 8 * life + 2,
                        opacity: Double(life) * 0.85,
                        hue: hue
                    )
                }

                // Expanding ripple ring
                let rippleRadius = elapsed * 110
                let rippleLife = max(0, 1.0 - elapsed / 1.5) * 0.35
                let rippleRect = CGRect(
                    x: center.x - rippleRadius, y: center.y - rippleRadius,
                    width: rippleRadius * 2, height: rippleRadius * 2
                )
                ctx.stroke(
                    Path(ellipseIn: rippleRect),
                    with: .color(.white.opacity(Double(rippleLife))),
                    lineWidth: 2
                )
            }
        }
        .ignoresSafeArea()
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
                isDragging: isDraggingThis
            )
            .offset(y: isDraggingThis ? dragOffset : 0)
            .zIndex(isDraggingThis ? 1 : 0)

            if quizDone {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 6)
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
        .onTapGesture {
            if isOrdered {
                HapticManager.lightImpact()
                onBlockTap(node)
            }
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

    // MARK: - Helpers

    private func swap(at a: Int, with b: Int) {
        guard a >= 0, b >= 0, a < currentOrder.count, b < currentOrder.count else { return }
        var newOrder = currentOrder
        newOrder.swapAt(a, b)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            currentOrder = newOrder
        }
        HapticManager.selection()
    }

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
