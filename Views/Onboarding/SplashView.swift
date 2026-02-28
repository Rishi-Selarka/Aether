import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var startTime: Date?
    @State private var titleOpacity: Double = 0.0
    @State private var network = SplashNetwork.generate()

    // 0→0.5s fast fade in, 0.5→2.2s roam, 2.2→3.6s slow dissolve, ~2.8s title appears
    private let fadeEnd = 3.6

    private var edgeWhiteLevel: Double { colorScheme == .dark ? 0.40 : 0.55 }
    private var dotWhiteLevel: Double { colorScheme == .dark ? 0.75 : 0.25 }
    private var titleColor: Color { colorScheme == .dark ? Color(white: 0.95) : Color(white: 0.05) }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cx = size.width / 2
            let cy = size.height / 2

            ZStack {
                Color.aetherBackground.ignoresSafeArea()

                TimelineView(.animation) { timeline in
                    let t = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0
                    let edgeLevel = edgeWhiteLevel
                    let dotLevel = dotWhiteLevel
                    let subtitleFull = "The Abyss of Cities"
                    let subtitleStart = 3.3
                    let subtitleChars = t >= subtitleStart
                        ? min(Int((t - subtitleStart) / 0.065), subtitleFull.count)
                        : 0

                    ZStack {
                        Canvas { gfx, canvasSize in
                            SplashView.drawNetworkStatic(
                                gfx, t: t, size: canvasSize, cx: cx, cy: cy,
                                network: network,
                                edgeWhiteLevel: edgeLevel,
                                dotWhiteLevel: dotLevel
                            )
                        }
                        .frame(width: size.width, height: size.height)
                        .allowsHitTesting(false)

                        VStack(spacing: 10) {
                            Text("Aether")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .tracking(6)
                                .foregroundColor(titleColor)
                                .opacity(titleOpacity)

                            Text(String(subtitleFull.prefix(subtitleChars)))
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(titleColor.opacity(0.55))
                                .opacity(subtitleChars > 0 ? 1.0 : 0.0)
                        }
                    }
                    .frame(width: size.width, height: size.height)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startTime = .now
            // Show text while network is still dissolving
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.easeOut(duration: 0.8)) {
                    titleOpacity = 1.0
                }
            }
        }
    }

    // MARK: - Draw

    static func drawNetworkStatic(
        _ gfx: GraphicsContext, t: Double, size: CGSize, cx: CGFloat, cy: CGFloat,
        network: SplashNetwork,
        edgeWhiteLevel: Double,
        dotWhiteLevel: Double
    ) {
        let w = Double(size.width)
        let h = Double(size.height)
        let positions = network.nodes.map { $0.position(t: t, w: w, h: h) }

        let breathe = 0.85 + 0.15 * sin(t * 2.4)
        let appearDuration = 0.2
        func appearFactor(_ t: Double, delay: Double) -> Double {
            let elapsed = t - delay
            guard elapsed > 0 else { return 0 }
            return min(1.0, elapsed / appearDuration)
        }

        // Edges
        for edge in network.edges {
            let appear = appearFactor(t, delay: edge.appearDelay)
            guard appear > 0 else { continue }

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

            let opacity = rawOp * appear * breathe
            let a = positions[edge.nodeA]
            let b = positions[edge.nodeB]
            var path = Path()
            path.move(to: a)
            path.addLine(to: b)
            gfx.stroke(path, with: .color(Color(white: edgeWhiteLevel, opacity: opacity)), lineWidth: 0.8)
        }

        // Nodes
        for (i, pos) in positions.enumerated() {
            let node = network.nodes[i]

            let appear = appearFactor(t, delay: node.appearDelay)
            guard appear > 0 else { continue }

            let rawOp: Double
            if t < node.fadeStart {
                rawOp = 1.0
            } else if t < node.fadeStart + 0.8 {
                let p = (t - node.fadeStart) / 0.8
                rawOp = (1.0 - p) * (1.0 - p)
            } else {
                continue
            }

            let opacity = rawOp * appear * breathe

            // Glow — dark blue halo
            let gr: CGFloat = 5
            gfx.fill(
                Path(ellipseIn: CGRect(x: pos.x - gr, y: pos.y - gr, width: gr * 2, height: gr * 2)),
                with: .color(Color(red: 0.10, green: 0.20, blue: 0.45).opacity(opacity * 0.35))
            )
            // Dot — deep navy blue
            let r: CGFloat = 1.8
            gfx.fill(
                Path(ellipseIn: CGRect(x: pos.x - r, y: pos.y - r, width: r * 2, height: r * 2)),
                with: .color(Color(red: 0.12, green: 0.25, blue: 0.55).opacity(opacity))
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

        let cols = 7
        let rows = 10
        let padC = 2
        let padR = 2

        let cStart = -padC
        let cEnd = cols + padC
        let rStart = -padR
        let rEnd = rows + padR

        let totalCols = cEnd - cStart + 1
        let totalRows = rEnd - rStart + 1

        for r in rStart...rEnd {
            for c in cStart...cEnd {
                let seed = Double((r + padR + 1) * (totalCols + 7) + (c + padC + 1))

                let baseX = (Double(c) + 0.5) / Double(cols)
                    + (hash(seed * 127.1 + 311.7) - 0.5) * 0.08
                let baseY = (Double(r) + 0.5) / Double(rows)
                    + (hash(seed * 269.5 + 183.3) - 0.5) * 0.06

                let driftX = (hash(seed * 419.2 + 371.9) - 0.5) * 0.055
                let driftY = (hash(seed * 523.7 + 247.1) - 0.5) * 0.055

                let dx = baseX - 0.5
                let dy = baseY - 0.5
                let dist = min(sqrt(dx * dx + dy * dy) / 0.75, 1.0)

                // Appear: edges of screen first (dist=1 → delay=0), center last (dist=0 → delay=0.4)
                let appearDelay = (1.0 - dist) * 0.4
                    + (hash(seed * 953.7 + 287.1) - 0.5) * 0.1

                // Dissolve: edges first, center last (slower)
                let fadeStart = 2.2 + (1.0 - dist) * 1.4
                    + (hash(seed * 631.4 + 159.3) - 0.5) * 0.3

                nodes.append(NetNode(baseX: baseX, baseY: baseY,
                                     driftX: driftX, driftY: driftY,
                                     appearDelay: max(0, appearDelay),
                                     fadeStart: fadeStart))
            }
        }

        for ri in 0..<totalRows {
            for ci in 0..<totalCols {
                let idx = ri * totalCols + ci
                let seed = Double(idx)

                if ci + 1 < totalCols {
                    edges.append(makeEdge(idx, idx + 1, nodes: nodes))
                }
                if ri + 1 < totalRows {
                    edges.append(makeEdge(idx, idx + totalCols, nodes: nodes))
                }
                if ci + 1 < totalCols, ri + 1 < totalRows, hash(seed * 743.1 + 573.2) > 0.65 {
                    edges.append(makeEdge(idx, idx + totalCols + 1, nodes: nodes))
                }
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
        let dist = min(sqrt(dx * dx + dy * dy) / 0.75, 1.0)

        // Appear: edges first (fast)
        let appearDelay = (1.0 - dist) * 0.4
            + (hash(Double(a * 41 + b * 67) * 953.7) - 0.5) * 0.1

        // Dissolve: edges first (slower)
        let fadeStart = 2.2 + (1.0 - dist) * 1.4
            + (hash(Double(a * 97 + b * 31)) - 0.5) * 0.3
        let fadeDuration = 0.5 + hash(Double(a * 53 + b * 71) * 743.1) * 0.5

        return NetEdge(nodeA: a, nodeB: b,
                       appearDelay: max(0, appearDelay),
                       fadeStart: fadeStart, fadeDuration: fadeDuration)
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
    let appearDelay: Double
    let fadeStart: Double

    func position(t: Double, w: Double, h: Double) -> CGPoint {
        // Clamp to a modest off-screen margin so nodes don't drift arbitrarily far.
        let x = min(max(baseX + driftX * t, -0.15), 1.15)
        let y = min(max(baseY + driftY * t, -0.15), 1.15)
        return CGPoint(x: x * w, y: y * h)
    }
}

struct NetEdge: Sendable {
    let nodeA: Int
    let nodeB: Int
    let appearDelay: Double
    let fadeStart: Double
    let fadeDuration: Double
}
