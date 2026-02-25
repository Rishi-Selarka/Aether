import SwiftUI

/// Glass overlay shown on first entry to the builder with instructions.
struct InstructionOverlay: View {
    let problemTitle: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dimming background — intercepted touches dismiss overlay
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // Glass card
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How to Play")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(problemTitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Dismiss instructions")
                }

                Divider().opacity(0.3)

                // Instructions
                VStack(alignment: .leading, spacing: 14) {
                    instructionRow(
                        icon: "arrow.up.arrow.down",
                        color: .blue,
                        text: "Drag blocks to reorder from top (UI) to bottom (data)"
                    )
                    instructionRow(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        text: "Get all blocks in the correct order to unlock the quiz"
                    )
                    instructionRow(
                        icon: "questionmark.circle.fill",
                        color: .orange,
                        text: "Tap each block to answer 3 system design questions"
                    )
                    instructionRow(
                        icon: "trophy.fill",
                        color: .yellow,
                        text: "Score 75% or higher to survive and pass the level"
                    )
                }

                Divider().opacity(0.3)

                Button(action: onDismiss) {
                    Text("Ready to dive")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.blue.opacity(0.6))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                }
                        }
                }
                .accessibilityLabel("Ready to dive")
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.4), radius: 40)
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Instruction Row

    private func instructionRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
