import SwiftUI

struct InteriorGlassCard: View {
    let problem: InteriorProblem
    @Binding var timeLimitMinutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            problemTitle
            problemDescription
            keywordsRow

            Spacer().frame(height: 4)

            timeLimitRow
        }
        .padding(.horizontal, InteriorConstants.cardPaddingHorizontal)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: InteriorConstants.cardCornerRadius)
                .fill(.black.opacity(0.25))
                .background {
                    RoundedRectangle(cornerRadius: InteriorConstants.cardCornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: InteriorConstants.cardCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: InteriorConstants.cardCornerRadius)
                        .strokeBorder(
                            .white.opacity(0.2),
                            lineWidth: InteriorConstants.cardBorderWidth
                        )
                }
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
        }
    }

    // MARK: - Problem Title

    private var problemTitle: some View {
        Text(problem.title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }

    // MARK: - Problem Description

    private var problemDescription: some View {
        Text(problem.description)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.white.opacity(0.85))
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Keywords

    private var keywordsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(problem.keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(.white.opacity(0.12))
                                .overlay {
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                                }
                        }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Keywords: \(problem.keywords.joined(separator: ", "))")
    }

    // MARK: - Time Limit Stepper

    private var timeLimitRow: some View {
        HStack {
            Text("Time limit")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))

            Spacer()

            HStack(spacing: 12) {
                stepperButton(systemName: "minus", action: decrementTime)
                    .accessibilityLabel("Decrease time")
                    .accessibilityHint("Current: \(timeLimitMinutes) minutes")

                Text("\(timeLimitMinutes) min")
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(minWidth: 56)

                stepperButton(systemName: "plus", action: incrementTime)
                    .accessibilityLabel("Increase time")
                    .accessibilityHint("Current: \(timeLimitMinutes) minutes")
            }
        }
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(.white.opacity(0.12))
                }
        }
    }

    private func decrementTime() {
        guard timeLimitMinutes > InteriorConstants.timeLimitMin else { return }
        timeLimitMinutes -= 1
        HapticManager.selection()
    }

    private func incrementTime() {
        guard timeLimitMinutes < InteriorConstants.timeLimitMax else { return }
        timeLimitMinutes += 1
        HapticManager.selection()
    }
}
