import SwiftUI

/// Full detail view for a single quiz attempt.
struct AttemptDetailView: View {
    let attempt: QuizAttempt
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.09, green: 0.09, blue: 0.12).ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        scoreSection
                            .padding(.top, 8)
                        infoSection
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle(attempt.problemTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Score Section

    private var scoreSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: CGFloat(attempt.score / 100))
                    .stroke(
                        LinearGradient(
                            colors: attempt.passed ? [.green, .mint] : [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(attempt.score))%")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(attempt.correctAnswers)/\(attempt.totalQuestions)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            // Pass/fail badge
            HStack(spacing: 8) {
                Image(systemName: attempt.passed ? "checkmark.shield.fill" : "drop.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(attempt.passed ? .green : .blue)
                Text(attempt.passed ? "Passed" : "Drowned")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(attempt.passed ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                attempt.passed ? Color.green.opacity(0.4) : Color.blue.opacity(0.4),
                                lineWidth: 1
                            )
                    }
            }
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(icon: "building.2.fill", label: "City", value: tierCityName)
            infoRow(icon: "calendar", label: "Date", value: attempt.timestamp.formatted(
                date: .long, time: .shortened
            ))
            infoRow(icon: "checkmark.circle.fill", label: "Correct", value: "\(attempt.correctAnswers) of \(attempt.totalQuestions)")
            infoRow(icon: "percent", label: "Score", value: "\(Int(attempt.score))%")
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var tierCityName: String {
        switch attempt.tierID {
        case 1: return "Tokyo"
        case 2: return "London"
        case 3: return "Singapore"
        case 4: return "New York"
        case 5: return "San Francisco"
        default: return "Unknown"
        }
    }
}
