import SwiftUI

// MARK: - Slot Frame Preference (refreshes on scroll/layout)

private struct SlotFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] { [:] }
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// Drag-and-drop architecture canvas. Empty placeholder slots run
/// vertically in the center; source blocks float on the left and right
/// sides with a bobbing animation. Users drag blocks into slots,
/// move between slots, or tap to remove. When all slots are filled
/// correctly, `currentOrder` is updated and quiz mode activates.
struct BlockCanvasView: View {
    let correctOrder: [NodeType]
    @Binding var currentOrder: [NodeType]
    let completedBlocks: Set<NodeType>
    let isOrdered: Bool
    let onBlockTap: (NodeType) -> Void

    // MARK: - Placement State

    @State private var slots: [NodeType?]

    // MARK: - Drag State

    @State private var draggedBlock: NodeType?
    @State private var dragSourceSlot: Int?   // nil → dragging from floating
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging = false
    @State private var slotFrames: [Int: CGRect] = [:]

    // MARK: - Animation

    @State private var snapSlot: Int?
    @State private var showSuccessBanner = false

    // MARK: - Constants

    private let gridSpacing: CGFloat = 30
    private let connectorHeight: CGFloat = 30
    private let boxSize: CGFloat = 110

    // MARK: - Init

    init(
        correctOrder: [NodeType],
        currentOrder: Binding<[NodeType]>,
        completedBlocks: Set<NodeType>,
        isOrdered: Bool,
        onBlockTap: @escaping (NodeType) -> Void
    ) {
        self.correctOrder = correctOrder
        self._currentOrder = currentOrder
        self.completedBlocks = completedBlocks
        self.isOrdered = isOrdered
        self.onBlockTap = onBlockTap
        self._slots = State(initialValue: Array(repeating: nil, count: correctOrder.count))
    }

    // MARK: - Computed

    private var unplacedBlocks: [NodeType] {
        let placed = Set(slots.compactMap { $0 })
        return correctOrder.filter { !placed.contains($0) }
    }

    // MARK: - Body

    /// Single coordinate space shared by drag gestures, slot frames, and ghost.
    private let canvasSpace = "blockCanvas"

    var body: some View {
        ZStack {
            blueprintBackground

            GeometryReader { geo in
                let sideWidth = max(90, (geo.size.width - boxSize - 40) / 2)

                ScrollView(.vertical, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 0) {
                        // Left floating blocks (even indices)
                        floatingColumn(
                            blocks: unplacedBlocks.enumerated()
                                .filter { $0.offset % 2 == 0 }.map(\.element),
                            startSeed: 0,
                            align: .trailing
                        )
                        .frame(width: sideWidth)

                        // Center: slot pipeline
                        slotPipeline
                            .frame(width: boxSize + 20)

                        // Right floating blocks (odd indices)
                        floatingColumn(
                            blocks: unplacedBlocks.enumerated()
                                .filter { $0.offset % 2 != 0 }.map(\.element),
                            startSeed: 1,
                            align: .leading
                        )
                        .frame(width: sideWidth)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }

            // Drag ghost follows finger - same coordinate space as drag
            if isDragging, let block = draggedBlock {
                ghostView(block: block)
            }
        }
        .coordinateSpace(name: canvasSpace)
        .onChange(of: isOrdered) { _, ordered in
            if ordered {
                withAnimation(.easeOut(duration: 0.35)) { showSuccessBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.3)) { showSuccessBanner = false }
                }
            }
        }
        .overlay(alignment: .top) {
            if showSuccessBanner {
                successBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Slot Pipeline

    private var slotPipeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(slots.indices), id: \.self) { index in
                VStack(spacing: 0) {
                    slotView(index: index)
                    if index < slots.count - 1 {
                        connectorLine(index: index)
                    }
                }
            }
            if !isOrdered {
                Text("Tap a block inside placeholder to remove it")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal, 8)
            }
        }
        .onPreferenceChange(SlotFramePreferenceKey.self) { slotFrames = $0 }
    }

    // MARK: - Single Slot

    @ViewBuilder
    private func slotView(index: Int) -> some View {
        ZStack {
            if let block = slots[index] {
                filledSlotContent(block: block, index: index)
            } else {
                emptySlotContent(index: index)
            }
        }
        .frame(width: boxSize, height: boxSize)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: SlotFramePreferenceKey.self,
                        value: [index: geo.frame(in: .named(canvasSpace))]
                    )
            }
        )
    }

    private func filledSlotContent(block: NodeType, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            ArchitectureBlockView(
                nodeType: block,
                isDragging: false,
                isLocked: isOrdered
            )
            .scaleEffect(snapSlot == index ? 1.12 : 1.0)
            .animation(
                .spring(response: 0.2, dampingFraction: 0.35),
                value: snapSlot == index
            )
            .opacity(isDragging && dragSourceSlot == index ? 0.2 : 1.0)

            if completedBlocks.contains(block) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.5), radius: 4)
                    .offset(x: -6, y: 4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            if isOrdered {
                HapticManager.lightImpact()
                onBlockTap(block)
            } else {
                // Remove to floating
                withAnimation(.spring(response: 0.3)) { slots[index] = nil }
                syncCurrentOrder()
                HapticManager.lightImpact()
            }
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 8, coordinateSpace: .named(canvasSpace))
                .onChanged { value in
                    guard !isOrdered else { return }
                    if !isDragging {
                        draggedBlock = block
                        dragSourceSlot = index
                        isDragging = true
                        HapticManager.lightImpact()
                    }
                    dragLocation = value.location
                }
                .onEnded { value in
                    guard !isOrdered else { return }
                    handleDrop(at: value.location)
                }
        )
    }

    private func emptySlotContent(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.06))

            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
                .foregroundStyle(Color(white: 0.22))

            Image(systemName: "plus")
                .font(.system(size: 18, weight: .ultraLight))
                .foregroundStyle(Color(white: 0.18))
        }
    }

    // MARK: - Floating Column

    private func floatingColumn(
        blocks: [NodeType], startSeed: Int, align: HorizontalAlignment
    ) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)
            ForEach(Array(blocks.enumerated()), id: \.element) { idx, block in
                floatingCell(block: block, seed: startSeed + idx * 2)
            }
            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, alignment: align == .trailing ? .trailing : .leading)
        .animation(.spring(response: 0.4), value: unplacedBlocks)
    }

    private func floatingCell(block: NodeType, seed: Int) -> some View {
        ArchitectureBlockView(nodeType: block, isDragging: false)
            .scaleEffect(isDragging && draggedBlock == block ? 0.5 : 0.75)
            .opacity(isDragging && draggedBlock == block ? 0.2 : 1.0)
            .modifier(FloatingBob(seed: seed))
            .shadow(color: block.accentColor.opacity(0.15), radius: 8, y: 4)
            .highPriorityGesture(
                DragGesture(minimumDistance: 8, coordinateSpace: .named(canvasSpace))
                    .onChanged { value in
                        if !isDragging {
                            draggedBlock = block
                            dragSourceSlot = nil
                            isDragging = true
                            HapticManager.lightImpact()
                        }
                        dragLocation = value.location
                    }
                    .onEnded { value in
                        handleDrop(at: value.location)
                    }
            )
    }

    // MARK: - Drag Ghost

    private func ghostView(block: NodeType) -> some View {
        ArchitectureBlockView(nodeType: block, isDragging: true)
            .frame(width: boxSize, height: boxSize)
            .scaleEffect(1.08)
            .shadow(color: block.accentColor.opacity(0.4), radius: 20, y: 6)
            .position(dragLocation)
            .allowsHitTesting(false)
            .zIndex(100)
    }

    // MARK: - Drop Handling

    private func handleDrop(at location: CGPoint) {
        guard let block = draggedBlock else { resetDrag(); return }

        if let target = targetSlotIndex(for: location) {
            if let source = dragSourceSlot {
                // Slot → Slot: swap contents
                let occupant = slots[target]
                withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                    slots[target] = block
                    slots[source] = occupant
                }
            } else {
                // Floating → Slot (existing occupant returns to floating automatically)
                withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                    slots[target] = block
                }
            }
            triggerSnap(at: target)
        }
        // Dropped outside any slot: snap back (no change)

        resetDrag()
        syncCurrentOrder()
    }

    private func targetSlotIndex(for location: CGPoint) -> Int? {
        // Iterate in slot order (0..<count) — dictionary iteration is unordered and
        // could return slot 4 before slot 6 when both expanded hit areas overlap.
        let candidates = (0 ..< slots.count).compactMap { index -> (Int, CGRect)? in
            guard let frame = slotFrames[index] else { return nil }
            let expanded = frame.insetBy(dx: -30, dy: -18)
            return expanded.contains(location) ? (index, frame) : nil
        }
        guard !candidates.isEmpty else { return nil }
        // When multiple slots overlap (common with 6 slots + generous hit area),
        // pick the one whose center is closest to the drop point.
        if candidates.count == 1 { return candidates[0].0 }
        let best = candidates.min { a, b in
            let distA = hypot(location.x - a.1.midX, location.y - a.1.midY)
            let distB = hypot(location.x - b.1.midX, location.y - b.1.midY)
            return distA < distB
        }
        return best?.0
    }

    private func triggerSnap(at index: Int) {
        HapticManager.mediumImpact()
        snapSlot = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            snapSlot = nil
        }
    }

    private func resetDrag() {
        isDragging = false
        draggedBlock = nil
        dragSourceSlot = nil
    }

    private func syncCurrentOrder() {
        let filled = slots.compactMap { $0 }
        currentOrder = filled.count == correctOrder.count ? filled : []
    }

    // MARK: - Connector Line

    private func connectorLine(index: Int) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let midX = size.width / 2
                let top: CGFloat = 2
                let bottom = size.height - 2

                // Dashed vertical line
                ctx.stroke(
                    Path { p in
                        p.move(to: CGPoint(x: midX, y: top))
                        p.addLine(to: CGPoint(x: midX, y: bottom))
                    },
                    with: .color(Color(white: 0.25)),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )

                // Chevron
                let cy = size.height / 2
                ctx.stroke(
                    Path { p in
                        p.move(to: CGPoint(x: midX - 4, y: cy - 3))
                        p.addLine(to: CGPoint(x: midX, y: cy + 3))
                        p.addLine(to: CGPoint(x: midX + 4, y: cy - 3))
                    },
                    with: .color(Color(white: 0.35)),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round)
                )

                // Data-pulse dot
                let t = fmod(time * 0.6 + Double(index) * 0.35, 1.0)
                let py = top + CGFloat(t) * (bottom - top)
                let life = 1.0 - abs(t - 0.5) * 2.0
                ctx.fill(
                    Path(ellipseIn: CGRect(x: midX - 2, y: py - 2, width: 4, height: 4)),
                    with: .color(.white.opacity(life * 0.3))
                )
            }
        }
        .frame(height: connectorHeight)
        .allowsHitTesting(false)
    }

    // MARK: - Blueprint Background

    private var blueprintBackground: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { ctx, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                drawGrid(ctx: ctx, size: size, time: time)
                drawAmbient(ctx: ctx, size: size, time: time)
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
                let a = 0.06 + sin(time * 0.3 + Double(row * 3 + col) * 0.15) * 0.02
                let arm: CGFloat = 1.6
                ctx.fill(Path(CGRect(x: x - arm, y: y - 0.4, width: arm * 2, height: 0.8)),
                          with: .color(.white.opacity(a)))
                ctx.fill(Path(CGRect(x: x - 0.4, y: y - arm, width: 0.8, height: arm * 2)),
                          with: .color(.white.opacity(a)))
            }
        }
    }

    private func drawAmbient(ctx: GraphicsContext, size: CGSize, time: Double) {
        for i in 0 ..< 18 {
            let s = Double(i)
            let xN = fmod(s * 0.3717 + sin(time * 0.08 + s * 1.6) * 0.02, 1.0)
            let yN = fmod(s * 0.4331 + time * (0.004 + fmod(s * 0.002, 0.006)), 1.0)
            let sz: CGFloat = 2 + CGFloat(fmod(s * 0.41, 1.5))
            let pulse = 0.5 + sin(time * 0.8 + s * 0.9) * 0.5
            let a = (0.06 + fmod(s * 0.018, 0.06)) * pulse
            let px = CGFloat(xN) * size.width
            let py = CGFloat(yN) * size.height
            let g = sz * 3
            ctx.fill(Path(ellipseIn: CGRect(x: px - g / 2, y: py - g / 2, width: g, height: g)),
                      with: .color(.white.opacity(a * 0.3)))
            ctx.fill(Path(ellipseIn: CGRect(x: px - sz / 2, y: py - sz / 2, width: sz, height: sz)),
                      with: .color(.white.opacity(a)))
        }
    }

    // MARK: - Success Banner

    private var successBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.green)
            Text("Architecture Correct - Tap blocks to begin quiz")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.green.opacity(0.5), lineWidth: 1)
                }
        }
        .shadow(color: .green.opacity(0.25), radius: 12, y: 4)
        .padding(.top, 8)
    }
}

// MARK: - Floating Bob Animation

private struct FloatingBob: ViewModifier {
    let seed: Int
    @State private var isUp = false

    func body(content: Content) -> some View {
        content
            .offset(y: isUp ? -5 : 5)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4 + Double(seed % 4) * 0.2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(seed) * 0.12)
                ) {
                    isUp = true
                }
            }
    }
}
