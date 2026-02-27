import SwiftUI

struct StatsCardView: View {
    @Environment(TierStatsCache.self) private var statsCache

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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
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
