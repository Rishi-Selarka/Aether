import SwiftUI

/// Full-width CTA with animated GIF background and a glass "Dare to Dive" button.
/// Randomly picks one of two GIFs each time the view appears.
struct DareToDiveCard: View {
    let onTap: () -> Void

    private static let gifAssets = ["daretodive_gif", "daretodive_gif_2"]

    /// Picked once per view lifetime (each app launch creates a new view).
    @State private var selectedGIF: String = gifAssets.randomElement() ?? "daretodive_gif"

    var body: some View {
        ZStack {
            // GIF background via asset catalog Data Set
            GIFImage(assetName: selectedGIF)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dim overlay for readability
            Color.black.opacity(0.3)

            // Liquid Glass "Dare to Dive" button
            Button {
                HapticManager.mediumImpact()
                onTap()
            } label: {
                HStack(spacing: 8) {
                    Text("Dare to Dive ?")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .buttonStyle(.glass(.clear))
            .accessibilityLabel("Dare to Dive")
            .accessibilityHint("Navigate to the city tier map")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
