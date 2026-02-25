import SwiftUI

// MARK: - Ambient Particle

/// A single floating particle for the grid background.
private struct AmbientParticle: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: CGFloat
    var hue: Double
}

/// Scrollable vertical canvas showing draggable architecture blocks
/// with an animated particle-grid background and energy-stream connections.
struct BlockCanvasView: View {
    let correctOrder: [NodeType]
    @Binding var currentOrder: [NodeType]
    let completedBlocks: Set<NodeType>
    let isOrdered: Bool
    let onBlockTap: (NodeType) -> Void

    // MARK: - Drag State

    @State private var draggingIndex: Int?
    @State private var dragOffset: CGFloat = 0
    @State private var blockFrames: [Int: CGRect] = [:]

    // MARK: - Particle State

    @State private var particles: [AmbientParticle] = []
    @State private var gridPhase: CGFloat = 0
    @State private var energyPhase: CGFloat = 0

    private let particleCount = 35
    private let gridSpacing: CGFloat = 28

    // MARK: - Body

    var body: some View {
        ZStack {
            // Animated particle grid background
            particleGridLayer

            // Block list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(currentOrder.enumerated()), id: \.element) { index, node in
                        VStack(spacing: 0) {
                            blockRow(node: node, index: index)

                            if index < currentOrder.count - 1 {
                                energyStream(
                                    fromColor: currentOrder[index].accentColor,
                                    toColor: currentOrder[index + 1].accentColor
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .onAppear { initParticles() }
    }

    // MARK: - Particle Grid Background

    private var particleGridLayer: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Grid dots
                drawGrid(context: context, size: size, time: time)

                // Floating particles
                drawParticles(context: context, size: size, time: time)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func drawGrid(context: GraphicsContext, size: CGSize, time: Double) {
        let cols = Int(size.width / gridSpacing) + 1
        let rows = Int(size.height / gridSpacing) + 1

        for row in 0 ..< rows {
            for col in 0 ..< cols {
                let x = CGFloat(col) * gridSpacing
                let y = CGFloat(row) * gridSpacing
                let wave = sin(time * 0.6 + Double(row + col) * 0.3) * 0.5 + 0.5
                let alpha = 0.04 + wave * 0.06

                let rect = CGRect(x: x - 1.2, y: y - 1.2, width: 2.4, height: 2.4)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
    }

    private func drawParticles(context: GraphicsContext, size: CGSize, time: Double) {
        for p in particles {
            let drift = sin(time * Double(p.speed) + Double(p.id)) * 8
            let yMove = (CGFloat(time.truncatingRemainder(dividingBy: 60)) * p.speed * 6)
                .truncatingRemainder(dividingBy: size.height + 40) - 20

            let px = p.x * size.width + CGFloat(drift)
            let py = (p.y * size.height + yMove).truncatingRemainder(dividingBy: size.height)

            let pulse = sin(time * 2 + Double(p.id) * 0.7) * 0.3 + 0.7
            let finalSize = p.size * CGFloat(pulse)

            // Glow
            let glowRect = CGRect(
                x: px - finalSize * 2, y: py - finalSize * 2,
                width: finalSize * 4, height: finalSize * 4
            )
            context.fill(
                Path(ellipseIn: glowRect),
                with: .color(
                    Color(hue: p.hue, saturation: 0.7, brightness: 1.0)
                        .opacity(p.opacity * 0.15 * pulse)
                )
            )

            // Core
            let coreRect = CGRect(
                x: px - finalSize / 2, y: py - finalSize / 2,
                width: finalSize, height: finalSize
            )
            context.fill(
                Path(ellipseIn: coreRect),
                with: .color(
                    Color(hue: p.hue, saturation: 0.5, brightness: 1.0)
                        .opacity(p.opacity * pulse)
                )
            )
        }
    }

    private func initParticles() {
        particles = (0 ..< particleCount).map { i in
            AmbientParticle(
                id: i,
                x: CGFloat.random(in: 0 ... 1),
                y: CGFloat.random(in: 0 ... 1),
                size: CGFloat.random(in: 2.5 ... 5),
                opacity: Double.random(in: 0.2 ... 0.5),
                speed: CGFloat.random(in: 0.3 ... 1.2),
                hue: Double.random(in: 0 ... 1)
            )
        }
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

    // MARK: - Energy Stream Connection

    private func energyStream(fromColor: Color, toColor: Color) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let midX = size.width / 2

                // Flowing line
                let path = Path { p in
                    p.move(to: CGPoint(x: midX, y: 0))
                    let segments = 8
                    for i in 1 ... segments {
                        let frac = CGFloat(i) / CGFloat(segments)
                        let wave = sin(time * 3 + Double(i) * 0.8) * 4
                        p.addLine(to: CGPoint(x: midX + CGFloat(wave), y: size.height * frac))
                    }
                }
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [fromColor.opacity(0.5), toColor.opacity(0.5)]),
                        startPoint: CGPoint(x: midX, y: 0),
                        endPoint: CGPoint(x: midX, y: size.height)
                    ),
                    lineWidth: 1.5
                )

                // Flowing energy dots
                for i in 0 ..< 3 {
                    let offset = Double(i) * 0.33
                    let t = (time * 1.2 + offset).truncatingRemainder(dividingBy: 1.0)
                    let y = size.height * CGFloat(t)
                    let wave = sin(time * 3 + t * 8) * 4
                    let dotSize: CGFloat = 3
                    let rect = CGRect(x: midX + CGFloat(wave) - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize)

                    // Glow
                    let glowRect = CGRect(x: midX + CGFloat(wave) - 6, y: y - 6, width: 12, height: 12)
                    context.fill(
                        Path(ellipseIn: glowRect),
                        with: .color(fromColor.opacity(0.3))
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(0.8))
                    )
                }
            }
        }
        .frame(height: 28)
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
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
