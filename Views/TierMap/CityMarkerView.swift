import SwiftUI

struct CityMarkerView: View {
    let tierID: Int
    let cityName: String
    let subtitle: String
    let icon: String
    let isUnlocked: Bool
    let isCompleted: Bool
    let lineColor: Color
    let isRevealed: Bool
    let onTap: () -> Void

    private var tintColor: Color {
        TierMapConstants.cityTints[tierID] ?? TierMapConstants.unlockedColor
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image("CitySkylinesVector")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 140, height: 80)
                    .foregroundStyle(tintColor)
                    .opacity(isUnlocked ? 1.0 : 0.3)

                Text(cityName)
                    .font(Typography.headingSmall)
                    .foregroundStyle(lineColor)

                Text(subtitle)
                    .font(Typography.bodySmall)
                    .foregroundStyle(lineColor.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
        .opacity(isRevealed ? 1 : 0)
        .scaleEffect(isRevealed ? 1.0 : 0.75)
        .allowsHitTesting(isRevealed)
        .accessibilityLabel("Tier \(tierID), \(cityName)")
        .accessibilityHint(isUnlocked ? "Double tap to open" : "Locked")
        .accessibilityAddTraits(isUnlocked ? .isButton : [])
    }
}
