import SwiftUI

struct StatsCardView: View {
    let tiers: [Tier]

    // MARK: - Computed Metrics

    private var citiesUnlocked: String {
        let count = tiers.isEmpty ? 5 : tiers.filter { $0.unlocked }.count
        return "\(count)/5"
    }

    private var totalBuilds: String {
        "\(tiers.flatMap { $0.architectures }.count)"
    }

    private var bestScore: String {
        let max = tiers.map { $0.score }.max() ?? 0
        guard max > 0 else { return "—" }
        return "\(Int(max * 100))%"
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            metric(value: citiesUnlocked, label: "Cities")
            Divider()
                .frame(height: 32)
                .opacity(0.4)
            metric(value: totalBuilds, label: "Builds")
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
