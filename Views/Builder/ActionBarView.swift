import SwiftUI

struct ActionBarView: View {
    let canRunSimulation: Bool
    let onRunSimulation: () -> Void
    let onEvaluate: () -> Void
    let onCodeView: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: LayoutConstants.spacingS) {
            Button {
                HapticManager.lightImpact()
                onRunSimulation()
            } label: {
                Label("Run", systemImage: "play.fill")
                    .font(Typography.headingSmall)
                    .foregroundStyle(.white)
                    .padding(.horizontal, LayoutConstants.spacingL)
                    .padding(.vertical, LayoutConstants.spacingS)
                    .background(
                        RoundedRectangle(cornerRadius: LayoutConstants.cornerRadiusS)
                            .fill(canRunSimulation ? Color.green : Color.archsysTextTertiary)
                    )
            }
            .disabled(!canRunSimulation)
            .archsysMinTouchTarget()
            .accessibilityLabel("Run simulation")
            .accessibilityHint(canRunSimulation ? "Double tap to run" : "Add at least two nodes to run")

            Button {
                HapticManager.lightImpact()
                onEvaluate()
            } label: {
                Label("Evaluate", systemImage: "chart.bar.fill")
                    .font(Typography.bodyMedium)
            }
            .archsysMinTouchTarget()
            .accessibilityLabel("Evaluate")

            Button {
                HapticManager.lightImpact()
                onCodeView()
            } label: {
                Label("Code", systemImage: "curlybraces")
                    .font(Typography.bodyMedium)
            }
            .archsysMinTouchTarget()
            .accessibilityLabel("View generated code")

            Button {
                HapticManager.mediumImpact()
                onReset()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(Typography.bodyMedium)
            }
            .archsysMinTouchTarget()
            .accessibilityLabel("Reset canvas")
            
            Spacer()
        }
        .padding(LayoutConstants.spacingM)
        .background(Color.archsysSurface)
    }
}
