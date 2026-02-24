import SwiftUI

struct CityMarkerView: View {
    let tierID: Int
    let cityName: String
    let subtitle: String
    let icon: String
    let isUnlocked: Bool
    let isCompleted: Bool
    let lineColor: Color
    let index: Int
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didAppear = false

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
        .buttonStyle(CityMarkerButtonStyle())
        .opacity(didAppear ? 1 : 0)
        .scaleEffect(didAppear ? 1.0 : 0.75)
        .onAppear {
            withAnimation(
                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.72)
                    .delay(Double(index) * 0.12)
            ) {
                didAppear = true
            }
        }
        .accessibilityLabel("Tier \(tierID), \(cityName)")
        .accessibilityHint(isUnlocked ? "Double tap to open" : "Locked")
        .accessibilityAddTraits(isUnlocked ? .isButton : [])
    }
}

private struct CityMarkerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
