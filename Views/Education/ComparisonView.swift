import SwiftUI

struct ComparisonView: View {
    let currentResult: EvaluationResult
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(alignment: .top, spacing: LayoutConstants.spacingM) {
                    currentScoreCard
                    potentialCard
                }
                .padding(LayoutConstants.spacingM)
            }
            .background(Color.archsysBackground)
            .navigationTitle("Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onDismiss() }
                }
            }
        }
    }

    private var currentScoreCard: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingM) {
            Text("Current")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            ScoreRing(score: currentResult.overallScore, label: "Overall")
            CategoryScoreRow(label: "Modularity", value: currentResult.modularity)
            CategoryScoreRow(label: "Performance", value: currentResult.performance)
            CategoryScoreRow(label: "Scalability", value: currentResult.scalability)
            CategoryScoreRow(label: "Resilience", value: currentResult.resilience)
        }
        .padding(LayoutConstants.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
    }

    private var potentialCard: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingM) {
            Text("Improvements")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)
            ForEach(currentResult.feedback.filter { $0.type == .suggestion || $0.type == .warning }) { item in
                HStack(alignment: .top, spacing: LayoutConstants.spacingS) {
                    Image(systemName: iconForFeedback(item.type))
                        .foregroundStyle(colorForFeedback(item.type))
                    Text(item.message)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.archsysTextSecondary)
                }
                .padding(LayoutConstants.spacingS)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.archsysBackground.opacity(0.5))
                .cornerRadius(LayoutConstants.cornerRadiusS)
            }
            if currentResult.feedback.filter({ $0.type == .suggestion || $0.type == .warning }).isEmpty {
                Text("No improvements suggested.")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextTertiary)
            }
        }
        .padding(LayoutConstants.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
    }

    private func iconForFeedback(_ type: FeedbackType) -> String {
        switch type {
        case .praise: return "checkmark.circle.fill"
        case .suggestion: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    private func colorForFeedback(_ type: FeedbackType) -> Color {
        switch type {
        case .praise: return .green
        case .suggestion: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
}

struct ScoreRing: View {
    let score: Double
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.archsysBorder, lineWidth: 6)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(score))")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Color.archsysTextPrimary)
            }
            Text(label)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextTertiary)
        }
    }

    private var scoreColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
}

struct CategoryScoreRow: View {
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Text(label)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextSecondary)
            Spacer()
            Text("\(Int(value))%")
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextPrimary)
        }
    }
}
