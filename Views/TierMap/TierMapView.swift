import SwiftUI
import SwiftData

struct TierMapView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var tiers: [Tier] = []
    @State private var selectedTierID: Int?
    @State private var routesRevealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("isDarkMode") private var isDarkMode = false

    // Light mode: light bg, dark lines. Dark mode: dark bg, light lines (swapped).
    private let lightColor = Color(red: 234 / 255, green: 239 / 255, blue: 239 / 255)
    private let darkColor = Color(red: 12 / 255, green: 15 / 255, blue: 22 / 255)
    private var mapBackground: Color { isDarkMode ? darkColor : lightColor }
    private var mapLineColor: Color { isDarkMode ? lightColor : darkColor }

    // Always iterate over these - markers render even if SwiftData is empty
    private let tierIDs = [1, 2, 3, 4, 5]

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    mapCanvas(canvasWidth: geo.size.width)
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
            refreshTiers()
            revealRoutes()
        }
    }

    // MARK: - Tier Lookup

    /// Fetches tiers from SwiftData for city markers (unlocked, completed state).
    private func refreshTiers() {
        let descriptor = FetchDescriptor<Tier>(sortBy: [SortDescriptor(\.id)])
        tiers = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func tier(for id: Int) -> Tier? {
        tiers.first(where: { $0.id == id })
    }

    // MARK: - Canvas (Grid + Routes)

    private func mapCanvas(canvasWidth: CGFloat) -> some View {
        Canvas { context, size in
            drawGridLines(context: context, size: size, lineColor: mapLineColor)
            if routesRevealed {
                drawRoutes(context: context, canvasWidth: canvasWidth, lineColor: mapLineColor)
            }
        }
        .frame(width: canvasWidth, height: TierMapConstants.canvasHeight)
    }

    private func drawGridLines(context: GraphicsContext, size: CGSize, lineColor: Color) {
        let shading = GraphicsContext.Shading.color(lineColor.opacity(0.25))

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

    private func drawRoutes(context: GraphicsContext, canvasWidth: CGFloat, lineColor: Color) {
        let routeShading = GraphicsContext.Shading.color(lineColor.opacity(0.35))

        for i in 0 ..< tierIDs.count - 1 {
            let fromID = tierIDs[i]
            let toID = tierIDs[i + 1]

            guard let from = TierMapConstants.positions[fromID],
                  let to = TierMapConstants.positions[toID] else { continue }

            let start = CGPoint(x: from.xFraction * canvasWidth, y: from.y)
            let end = CGPoint(x: to.xFraction * canvasWidth, y: to.y)

            let midX = (start.x + end.x) / 2
            let midY = (start.y + end.y) / 2
            let curveDirection: CGFloat = (i % 2 == 0) ? -60 : 60
            let control = CGPoint(x: midX + curveDirection, y: midY)

            var path = Path()
            path.move(to: start)
            path.addQuadCurve(to: end, control: control)

            let bothCompleted = (tier(for: fromID)?.completed ?? false)
                && (tier(for: toID)?.completed ?? false)

            context.stroke(
                path,
                with: routeShading,
                style: StrokeStyle(
                    lineWidth: TierMapConstants.routeLineWidth,
                    dash: bothCompleted ? [] : TierMapConstants.routeDash
                )
            )
        }
    }

    // MARK: - City Markers (always renders 5 markers from constants)

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
                    subtitle: t?.name ?? "",
                    icon: icon,
                    isUnlocked: t?.unlocked ?? true,
                    isCompleted: t?.completed ?? false,
                    lineColor: mapLineColor,
                    index: tierID - 1,
                    onTap: { handleCityTap(tierID) }
                )
                .position(
                    x: pos.xFraction * canvasWidth,
                    y: pos.y
                )
                } // if let pos
            }

        }
        .frame(width: canvasWidth, height: TierMapConstants.canvasHeight)
    }

    // MARK: - Actions

    private func handleCityTap(_ tierID: Int) {
        HapticManager.mediumImpact()
        selectedTierID = tierID
    }

    private func revealRoutes() {
        guard !routesRevealed else { return }
        let delay = reduceMotion ? 0.0 : 0.8
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.6)) {
                routesRevealed = true
            }
        }
    }
}
