import SwiftUI

struct InspectorView: View {
    let result: EvaluationResult
    let onDismiss: () -> Void
    @State private var showComparison = false

    @State private var animatedScore: Double = 0
    @State private var animatedModularity: Double = 0
    @State private var animatedPerformance: Double = 0
    @State private var animatedScalability: Double = 0
    @State private var animatedResilience: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: LayoutConstants.spacingL) {
                    scoreSection
                    categoryBars
                    feedbackSection
                }
                .padding(LayoutConstants.spacingM)
            }
        }
        .background(Color.archsysSurface)
        .sheet(isPresented: $showComparison) {
            ComparisonView(currentResult: result) { showComparison = false }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = result.overallScore
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animatedModularity = result.modularity
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.35)) {
                animatedPerformance = result.performance
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                animatedScalability = result.scalability
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.65)) {
                animatedResilience = result.resilience
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Evaluation")
                .font(Typography.headingMedium)
                .foregroundStyle(Color.archsysTextPrimary)
            Spacer()
            Button("Compare") { showComparison = true }
                .font(Typography.bodyMedium)
            Button("Done") { onDismiss() }
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.accentColor)
        }
        .padding(LayoutConstants.spacingM)
        .background(Color.archsysSurfaceElevated)
    }

    private var scoreSection: some View {
        VStack(spacing: LayoutConstants.spacingS) {
            ZStack {
                Circle()
                    .stroke(Color.archsysBorder, lineWidth: 8)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(animatedScore))")
                    .font(Typography.displaySmall)
                    .foregroundStyle(Color.archsysTextPrimary)
            }
            Text("Overall Score")
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextSecondary)
        }
        .padding(LayoutConstants.spacingL)
    }

    private var scoreColor: Color {
        if result.overallScore >= 80 { return .green }
        if result.overallScore >= 60 { return .orange }
        return .red
    }

    private var categoryBars: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("Categories")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)

            CategoryBar(label: "Modularity", value: animatedModularity, color: .blue)
            CategoryBar(label: "Performance", value: animatedPerformance, color: .green)
            CategoryBar(label: "Scalability", value: animatedScalability, color: .purple)
            CategoryBar(label: "Resilience", value: animatedResilience, color: .orange)
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            Text("Feedback")
                .font(Typography.headingSmall)
                .foregroundStyle(Color.archsysTextPrimary)

            ForEach(result.feedback) { item in
                FeedbackRow(feedback: item)
            }
        }
    }
}

struct CategoryBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextSecondary)
                Spacer()
                Text("\(Int(value))%")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.archsysBorder)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * (value / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct FeedbackRow: View {
    let feedback: Feedback

    private var icon: String {
        switch feedback.type {
        case .praise: return "checkmark.circle.fill"
        case .suggestion: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch feedback.type {
        case .praise: return .green
        case .suggestion: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: LayoutConstants.spacingS) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
            Text(feedback.message)
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.archsysTextPrimary)
            Spacer()
        }
        .padding(LayoutConstants.spacingS)
        .background(Color.archsysBackground.opacity(0.5))
        .cornerRadius(LayoutConstants.cornerRadiusS)
    }
}
