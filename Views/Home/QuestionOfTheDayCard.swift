import SwiftUI

/// Daily multiple-choice question with tap-to-answer and explanation reveal.
struct QuestionOfTheDayCard: View {
    let question: DailyQuestion?
    let onAnswer: (Int) -> Void
    var onRefresh: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedIndex: Int?
    @State private var showExplanation = false

    private var isAnswered: Bool { selectedIndex != nil }

    var body: some View {
        Group {
            if let question {
                loadedContent(question)
            } else {
                placeholder
            }
        }
    }

    private func loadedContent(_ q: DailyQuestion) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header label + refresh
            HStack(spacing: 5) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.archsysTextTertiary)
                Text("DAILY CHALLENGE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Color.archsysTextTertiary)
                    .tracking(1.0)

                Spacer()

                if let onRefresh {
                    Button {
                        HapticManager.lightImpact()
                        selectedIndex = nil
                        showExplanation = false
                        onRefresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.archsysTextTertiary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Reload question")
                }
            }
            .padding(.bottom, 8)

            // Question text
            Text(q.question)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.archsysTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
                .padding(.bottom, 10)

            // Options
            VStack(spacing: 6) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { index, option in
                    optionRow(
                        index: index,
                        text: option,
                        correctIndex: q.correctIndex
                    )
                }
            }

            // Explanation (after answer)
            if showExplanation {
                explanationView(q.explanation)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glossyCardBackground(cornerRadius: 12)
        .onAppear {
            // Restore previous answer if already answered today
            if let saved = q.selectedIndex {
                selectedIndex = saved
                showExplanation = true
            }
        }
    }

    private func optionRow(index: Int, text: String, correctIndex: Int) -> some View {
        let isSelected = selectedIndex == index
        let isCorrect = index == correctIndex
        let revealed = isAnswered

        let isDark = colorScheme == .dark
        let defaultBg: Color = isDark ? .white.opacity(0.08) : .black.opacity(0.05)
        let defaultBorder: Color = isDark ? .white.opacity(0.12) : .black.opacity(0.10)

        let bgColor: Color = {
            guard revealed else { return defaultBg }
            if isCorrect { return Color.archsysSuccess.opacity(0.15) }
            if isSelected && !isCorrect { return Color.archsysError.opacity(0.15) }
            return defaultBg
        }()

        let borderColor: Color = {
            guard revealed else { return defaultBorder }
            if isCorrect { return Color.archsysSuccess.opacity(0.6) }
            if isSelected && !isCorrect { return Color.archsysError.opacity(0.5) }
            return defaultBorder
        }()

        let labelPrefix = ["A", "B", "C", "D"][index]

        return Button {
            guard !isAnswered else { return }
            HapticManager.lightImpact()
            selectedIndex = index
            onAnswer(index)
            withAnimation(.easeOut(duration: 0.3)) {
                showExplanation = true
            }
        } label: {
            HStack(spacing: 10) {
                Text(labelPrefix)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(revealed && isCorrect ? Color.archsysSuccess : Color.archsysTextTertiary)
                    .frame(width: 18)

                Text(text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.archsysTextPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 4)

                if revealed && isCorrect {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.archsysSuccess)
                } else if revealed && isSelected && !isCorrect {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.archsysError)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(bgColor, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(borderColor, lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
        .accessibilityLabel("Option \(labelPrefix): \(text)")
    }

    private func explanationView(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.homeAccent)
                .padding(.top, 1)

            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.archsysTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.homeAccentMuted, in: RoundedRectangle(cornerRadius: 10))
    }

    private var placeholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.archsysSurfaceElevated)
                .frame(height: 14)
                .frame(maxWidth: 200)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.archsysSurfaceElevated)
                .frame(height: 14)

            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.archsysSurfaceElevated)
                    .frame(height: 44)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glossyCardBackground(cornerRadius: 12)
    }
}
