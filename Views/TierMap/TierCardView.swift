import SwiftUI
import SwiftData

struct TierCardView: View {
    let tier: Tier

    private var tierIcon: String {
        switch tier.id {
        case 1: return "building.2.fill"
        case 2: return "network"
        case 3: return "bolt.fill"
        case 4: return "shield.fill"
        case 5: return "brain.head.profile"
        default: return "questionmark.circle"
        }
    }

    private var statusIcon: String {
        if tier.completed { return "checkmark.circle.fill" }
        if tier.unlocked { return "play.circle.fill" }
        return "lock.fill"
    }

    private var statusColor: Color {
        if tier.completed { return .green }
        if tier.unlocked { return .blue }
        return Color.archsysTextTertiary
    }

    private var subtitle: String {
        if tier.completed { return "Completed" }
        if tier.unlocked { return "Ready to build" }
        return "Locked"
    }

    var body: some View {
        HStack(spacing: LayoutConstants.spacingM) {
            tierBadge
            tierInfo
            Spacer()
            statusIndicator
        }
        .padding(LayoutConstants.spacingM)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusM)
                .fill(tier.unlocked ? Color.archsysSurfaceElevated : Color.archsysSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusM)
                .stroke(Color.archsysBorder, lineWidth: 1)
        )
        .archsysShadow(tier.unlocked ? .medium : .low)
        .opacity(tier.unlocked ? 1.0 : 0.6)
    }

    // MARK: - Subviews

    private var tierBadge: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 56, height: 56)

            Image(systemName: tierIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(statusColor)
        }
    }

    private var tierInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tier \(tier.id)")
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextTertiary)

            Text(tier.name)
                .font(Typography.headingMedium)
                .foregroundStyle(Color.archsysTextPrimary)

            Text(subtitle)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextSecondary)

            if tier.completed {
                scoreBar
            }
        }
    }

    private var scoreBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.archsysBorder)
                        .frame(height: 6)

                    Capsule()
                        .fill(statusColor)
                        .frame(width: geo.size.width * (tier.score / 100), height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Score: \(Int(tier.score))%")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextSecondary)

                if let best = tier.bestTime {
                    Spacer()
                    Text("Best: \(formatTime(best))")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.archsysTextSecondary)
                }
            }
        }
    }

    private var statusIndicator: some View {
        Image(systemName: statusIcon)
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(statusColor)
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
