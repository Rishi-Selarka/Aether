import SwiftUI

struct StatsCardView: View {
    let tiers: [Tier]

    // MARK: - Computed Metrics

    private var citiesPassed: String {
        let count = tiers.reduce(0) { total, tier in
            total + tier.problemBestScores.values.filter { $0 >= 75 }.count
        }
        return "\(min(count, 15))/15"
    }

    private var totalAttempts: String {
        "\(tiers.map { $0.attemptsCount }.reduce(0, +))"
    }

    private var bestScore: String {
        let best = tiers.flatMap { $0.problemBestScores.values }.max() ?? 0
        guard best > 0 else { return "-" }
        return "\(Int(best))%"
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            metric(value: citiesPassed, label: "Passed")
            Divider()
                .frame(height: 32)
                .opacity(0.4)
            metric(value: totalAttempts, label: "Attempts")
            Divider()
                .frame(height: 32)
                .opacity(0.4)
            metric(value: bestScore, label: "Best Score")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        .padding(.horizontal, 20)
    }

    // MARK: - Metric Column

    private func metric(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .monospacedDigit()

            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}
