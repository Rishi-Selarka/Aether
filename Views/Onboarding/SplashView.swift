import SwiftUI

struct SplashView: View {
    @State private var startTime: Date?
    @State private var titleOpacity: Double = 0.0
    @State private var network = SplashNetwork.generate()

    // 0→2.2s roam, 2.2→4.0s dissolve edges→center, 4.3s title
    private let fadeEnd = 4.0

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cx = size.width / 2
            let cy = size.height / 2

            ZStack {
                Color.archsysBackground.ignoresSafeArea()

                TimelineView(.animation) { timeline in
                    let t = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0

                    ZStack {
                        Canvas { gfx, canvasSize in
                            drawNetwork(gfx, t: t, size: canvasSize, cx: cx, cy: cy)
                        }
                        .frame(width: size.width, height: size.height)
                        .allowsHitTesting(false)

                        Text("archsys")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .tracking(6)
                            .foregroundColor(Color(white: 0.95))
                            .opacity(titleOpacity)
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startTime = .now
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeEnd + 0.3) {
                withAnimation(.easeOut(duration: 1.0)) {
                    titleOpacity = 1.0
                }
            }
        }
    }

    // MARK: - Draw

    private func drawNetwork(_ gfx: GraphicsContext, t: Double, size: CGSize, cx: CGFloat, cy: CGFloat) {
        let w = Double(size.width)
        let h = Double(size.height)
        let positions = network.nodes.map { $0.position(t: t, w: w, h: h) }

        let breathe = 0.85 + 0.15 * sin(t * 1.8)

        // Edges
        for edge in network.edges {
            let rawOp: Double
            if t < edge.fadeStart {
                rawOp = 1.0
            } else if t < edge.fadeStart + edge.fadeDuration {
                let p = (t - edge.fadeStart) / edge.fadeDuration
                let bump = p < 0.15 ? 1.0 + p * 3.0 : 1.0
                rawOp = bump * (1.0 - p) * (1.0 - p)
            } else {
                continue
            }

            let opacity = rawOp * breathe
            let a = positions[edge.nodeA]
            let b = positions[edge.nodeB]
            var path = Path()
            path.move(to: a)
            path.addLine(to: b)
            gfx.stroke(path, with: .color(Color(white: 0.40, opacity: opacity)), lineWidth: 0.8)
        }

        // Nodes
        for (i, pos) in positions.enumerated() {
            let node = network.nodes[i]
            let rawOp: Double
            if t < node.fadeStart {
                rawOp = 1.0
            } else if t < node.fadeStart + 0.5 {
                let p = (t - node.fadeStart) / 0.5
                rawOp = (1.0 - p) * (1.0 - p)
            } else {
                continue
            }

            let opacity = rawOp * breathe

            // Glow
            let gr: CGFloat = 5
            gfx.fill(
                Path(ellipseIn: CGRect(x: pos.x - gr, y: pos.y - gr, width: gr * 2, height: gr * 2)),
                with: .color(Color(white: 0.5, opacity: opacity * 0.15))
            )
            // Dot
            let r: CGFloat = 1.8
            gfx.fill(
                Path(ellipseIn: CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)),
                with: .color(Color(white: 0.75, opacity: opacity))
            )
        }
    }
}

// MARK: - Grid Network

struct SplashNetwork: Sendable {
    let nodes: [NetNode]
    let edges: [NetEdge]

    static func generate() -> SplashNetwork {
        var nodes: [NetNode] = []
        var edges: [NetEdge] = []

        // 7x10 grid + 2 rows/cols overflow on EVERY side → full bleed coverage
        let cols = 7
        let rows = 10
        let padC = 2
        let padR = 2

        let cStart = -padC
        let cEnd = cols + padC     // inclusive
        let rStart = -padR
        let rEnd = rows + padR     // inclusive

        let totalCols = cEnd - cStart + 1  // 7 + 4 + 1 = 12
        let totalRows = rEnd - rStart + 1  // 10 + 4 + 1 = 15

        for r in rStart...rEnd {
            for c in cStart...cEnd {
                let seed = Double((r + padR + 1) * (totalCols + 7) + (c + padC + 1))

                // Normalized position — 0 at first real col/row, 1 at last
                let baseX = (Double(c) + 0.5) / Double(cols)
                    + (hash(seed * 127.1 + 311.7) - 0.5) * 0.08
                let baseY = (Double(r) + 0.5) / Double(rows)
                    + (hash(seed * 269.5 + 183.3) - 0.5) * 0.06

                let driftX = (hash(seed * 419.2 + 371.9) - 0.5) * 0.022
                let driftY = (hash(seed * 523.7 + 247.1) - 0.5) * 0.022

                let dx = baseX - 0.5
                let dy = baseY - 0.5
                let dist = sqrt(dx * dx + dy * dy) / 0.75
                let fadeStart = 2.2 + (1.0 - min(dist, 1.0)) * 1.5
                    + (hash(seed * 631.4 + 159.3) - 0.5) * 0.5

                nodes.append(NetNode(baseX: baseX, baseY: baseY,
                                     driftX: driftX, driftY: driftY,
                                     fadeStart: fadeStart))
            }
        }

        // Connect neighbors within the grid
        for ri in 0..<totalRows {
            for ci in 0..<totalCols {
                let idx = ri * totalCols + ci
                let seed = Double(idx)

                // Right
                if ci + 1 < totalCols {
                    edges.append(makeEdge(idx, idx + 1, nodes: nodes))
                }
                // Down
                if ri + 1 < totalRows {
                    edges.append(makeEdge(idx, idx + totalCols, nodes: nodes))
                }
                // Diagonal ↘ ~35%
                if ci + 1 < totalCols, ri + 1 < totalRows, hash(seed * 743.1 + 573.2) > 0.65 {
                    edges.append(makeEdge(idx, idx + totalCols + 1, nodes: nodes))
                }
                // Diagonal ↙ ~20%
                if ci > 0, ri + 1 < totalRows, hash(seed * 857.3 + 421.7) > 0.80 {
                    edges.append(makeEdge(idx, idx + totalCols - 1, nodes: nodes))
                }
            }
        }

        return SplashNetwork(nodes: nodes, edges: edges)
    }

    private static func makeEdge(_ a: Int, _ b: Int, nodes: [NetNode]) -> NetEdge {
        let midX = (nodes[a].baseX + nodes[b].baseX) / 2
        let midY = (nodes[a].baseY + nodes[b].baseY) / 2
        let dx = midX - 0.5
        let dy = midY - 0.5
        let dist = sqrt(dx * dx + dy * dy) / 0.75

        let fadeStart = 2.2 + (1.0 - min(dist, 1.0)) * 1.5
            + (hash(Double(a * 97 + b * 31)) - 0.5) * 0.5
        let fadeDuration = 0.4 + hash(Double(a * 53 + b * 71) * 743.1) * 0.5

        return NetEdge(nodeA: a, nodeB: b, fadeStart: fadeStart, fadeDuration: fadeDuration)
    }

    private static func hash(_ n: Double) -> Double {
        let x = sin(n) * 43758.5453123
        return x - floor(x)
    }
}

// MARK: - Types

struct NetNode: Sendable {
    let baseX: Double
    let baseY: Double
    let driftX: Double
    let driftY: Double
    let fadeStart: Double

    func position(t: Double, w: Double, h: Double) -> CGPoint {
        CGPoint(x: (baseX + driftX * t) * w,
                y: (baseY + driftY * t) * h)
    }
}

struct NetEdge: Sendable {
    let nodeA: Int
    let nodeB: Int
    let fadeStart: Double
    let fadeDuration: Double
}
