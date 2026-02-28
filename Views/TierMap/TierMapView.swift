import SwiftUI
import SwiftData

struct TierMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tier.id) private var tiers: [Tier]
    @State private var selectedTierID: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var revealedCities = 0
    @State private var routeDrawProgress: [CGFloat] = [0, 0, 0, 0]

    private let lightColor = Color(red: 234 / 255, green: 239 / 255, blue: 239 / 255)
    private let darkColor = Color(red: 12 / 255, green: 15 / 255, blue: 22 / 255)
    private var mapBackground: Color { isDarkMode ? darkColor : lightColor }
    private var mapLineColor: Color { isDarkMode ? lightColor : darkColor }

    private let tierIDs = [1, 2, 3, 4, 5]

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    gridCanvas(canvasWidth: geo.size.width)
                    routeLines(canvasWidth: geo.size.width)
                    cityMarkers(canvasWidth: geo.size.width)
                }
                .frame(width: geo.size.width, height: TierMapConstants.canvasHeight)
            }
        }
        .background(mapBackground)
        .ignoresSafeArea()
        .navigationDestination(item: $selectedTierID) { tierID in
            InteriorView(tierID: tierID)
        }
        .onAppear {
            startRevealSequence()
        }
    }

    // MARK: - Tier Lookup

    private func tier(for id: Int) -> Tier? {
        tiers.first(where: { $0.id == id })
    }

    // MARK: - Grid (Canvas)

    private func gridCanvas(canvasWidth: CGFloat) -> some View {
        Canvas { context, size in
            let shading = GraphicsContext.Shading.color(mapLineColor.opacity(0.25))

            let vSpacing = size.width / 6
            for i in 1 ... 5 {
                let x = vSpacing * CGFloat(i)
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: shading, lineWidth: 1)
            }

            let hSpacing = size.height / 11
            for i in 1 ... 10 {
                let y = hSpacing * CGFloat(i)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: shading, lineWidth: 1)
            }
        }
        .frame(width: canvasWidth, height: TierMapConstants.canvasHeight)
    }

    // MARK: - Routes (animated line draw)

    private func routeLines(canvasWidth: CGFloat) -> some View {
        ZStack {
            ForEach(0 ..< 4, id: \.self) { i in
                if let from = TierMapConstants.positions[tierIDs[i]],
                   let to = TierMapConstants.positions[tierIDs[i + 1]] {
                    let start = CGPoint(x: from.xFraction * canvasWidth, y: from.y)
                    let end = CGPoint(x: to.xFraction * canvasWidth, y: to.y)
                    let midX = (start.x + end.x) / 2
                    let midY = (start.y + end.y) / 2
                    let curveDir: CGFloat = (i % 2 == 0) ? -60 : 60
                    let control = CGPoint(x: midX + curveDir, y: midY)

                    let bothCompleted = (tier(for: tierIDs[i])?.completed ?? false)
                        && (tier(for: tierIDs[i + 1])?.completed ?? false)

                    QuadCurveShape(start: start, end: end, control: control)
                        .trim(from: 0, to: routeDrawProgress[i])
                        .stroke(
                            mapLineColor.opacity(0.35),
                            style: StrokeStyle(
                                lineWidth: TierMapConstants.routeLineWidth,
                                lineCap: .round,
                                dash: bothCompleted ? [] : TierMapConstants.routeDash
                            )
                        )
                }
            }
        }
        .frame(width: canvasWidth, height: TierMapConstants.canvasHeight)
    }

    // MARK: - City Markers

    private func cityMarkers(canvasWidth: CGFloat) -> some View {
        ZStack {
            ForEach(tierIDs, id: \.self) { tierID in
                if let pos = TierMapConstants.positions[tierID] {
                    let t = tier(for: tierID)
                    let cityName = TierMapConstants.cityNames[tierID] ?? "City"
                    let icon = TierMapConstants.cityIcons[tierID] ?? "questionmark.circle"

                    CityMarkerView(
                        tierID: tierID,
                        cityName: cityName,
                        icon: icon,
                        isUnlocked: t?.unlocked ?? true,
                        isCompleted: t?.completed ?? false,
                        lineColor: mapLineColor,
                        isRevealed: revealedCities >= tierID,
                        onTap: { handleCityTap(tierID) }
                    )
                    .position(
                        x: pos.xFraction * canvasWidth,
                        y: pos.y
                    )
                }
            }
        }
        .frame(width: canvasWidth, height: TierMapConstants.canvasHeight)
    }

    // MARK: - Actions

    private func handleCityTap(_ tierID: Int) {
        HapticManager.mediumImpact()
        selectedTierID = tierID
    }

    // MARK: - Sequential Reveal

    private func startRevealSequence() {
        guard revealedCities == 0 else { return }

        // Skip animation for accessibility
        guard !reduceMotion else {
            revealedCities = 5
            routeDrawProgress = [1, 1, 1, 1]
            return
        }

        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.4)) {
                revealedCities = 1
            }
            try? await Task.sleep(for: .milliseconds(500))
            for i in 0 ..< 4 {
                withAnimation(.easeInOut(duration: 0.6)) {
                    routeDrawProgress[i] = 1.0
                }
                try? await Task.sleep(for: .milliseconds(650))
                withAnimation(.easeOut(duration: 0.4)) {
                    revealedCities = i + 2
                }
                try? await Task.sleep(for: .milliseconds(400))
            }
        }
    }
}

// MARK: - Quad Curve Shape (for animated trim)

struct QuadCurveShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}
