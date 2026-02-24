import SwiftUI

struct TutorialOverlayView: View {
    let tierID: Int
    let step: Int
    let totalSteps: Int
    let instruction: String
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            spotlightOverlay

            VStack(spacing: LayoutConstants.spacingL) {
                Spacer()

                instructionCard

                progressDots

                HStack(spacing: LayoutConstants.spacingM) {
                    Button {
                        HapticManager.selection()
                        onSkip()
                    } label: {
                        Text("Skip")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Color.archsysTextSecondary)
                    }
                    .archsysMinTouchTarget()
                    .accessibilityLabel("Skip tutorial")

                    Spacer()

                    Button {
                        HapticManager.lightImpact()
                        onNext()
                    } label: {
                        Text(step < totalSteps ? "Next" : "Get Started")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, LayoutConstants.spacingL)
                            .padding(.vertical, LayoutConstants.spacingS)
                            .background(Color.accentColor)
                            .cornerRadius(LayoutConstants.cornerRadiusS)
                    }
                    .archsysMinTouchTarget()
                    .accessibilityLabel(step < totalSteps ? "Next step" : "Get started")
                }
                .padding(.horizontal, LayoutConstants.spacingL)

                Spacer()
            }
        }
    }

    private var spotlightOverlay: some View {
        Color.black.opacity(0.7)
            .mask {
                RadialGradient(
                    colors: [.black, .white],
                    center: .center,
                    startRadius: 60,
                    endRadius: 280
                )
            }
            .ignoresSafeArea()
            .onTapGesture { }
    }

    private var instructionCard: some View {
        VStack(spacing: LayoutConstants.spacingM) {
            Text("Tier \(tierID) Tutorial")
                .font(Typography.headingMedium)
                .foregroundStyle(Color.archsysTextPrimary)

            Text(instruction)
                .font(Typography.bodyLarge)
                .foregroundStyle(Color.archsysTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(LayoutConstants.spacingL)
        .frame(maxWidth: .infinity)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
        .padding(.horizontal, LayoutConstants.spacingL)
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Circle()
                    .fill(i == step ? Color.accentColor : Color.archsysTextTertiary)
                    .frame(width: 8, height: 8)
            }
        }
    }
}
