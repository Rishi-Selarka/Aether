import SwiftUI

struct StatsCardView: View {
    @Environment(TierStatsCache.self) private var statsCache
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            metric(value: statsCache.citiesPassed, label: "Passed")
            Divider()
                .frame(height: 32)
                .opacity(0.4)
            metric(value: statsCache.totalAttempts, label: "Attempts")
            Divider()
                .frame(height: 32)
                .opacity(0.4)
            metric(value: statsCache.bestScoreToday, label: "Best Today")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background { glossyBackground }
    }

    // MARK: - Glossy Background

    private var glossyBackground: some View {
        let isDark = colorScheme == .dark
        let baseColor: Color = isDark ? .black : .white
        let sheenColor: Color = isDark ? .white : .black

        return ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(baseColor)

            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            sheenColor.opacity(isDark ? 0.12 : 0.04),
                            sheenColor.opacity(isDark ? 0.03 : 0.01),
                            .clear,
                            sheenColor.opacity(isDark ? 0.05 : 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            sheenColor.opacity(isDark ? 0.25 : 0.12),
                            sheenColor.opacity(isDark ? 0.08 : 0.04),
                            sheenColor.opacity(isDark ? 0.04 : 0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }

    private func metric(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .monospacedDigit()

            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}
