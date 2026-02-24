import SwiftUI
import SwiftData

/// Sheet showing all quiz attempts grouped and filtered by city.
struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuizAttempt.timestamp, order: .reverse) private var allAttempts: [QuizAttempt]

    @State private var selectedFilter: Int = 0  // 0 = All, 1–5 = tier ID
    @State private var selectedAttempt: QuizAttempt?

    private let tierNames = ["All", "Tokyo", "London", "Singapore", "New York", "San Francisco"]

    private var filteredAttempts: [QuizAttempt] {
        guard selectedFilter > 0 else { return allAttempts }
        return allAttempts.filter { $0.tierID == selectedFilter }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.09, green: 0.09, blue: 0.12).ignoresSafeArea()

                VStack(spacing: 0) {
                    filterChips
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    if filteredAttempts.isEmpty {
                        emptyState
                    } else {
                        summaryCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)

                        attemptsList
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedAttempt) { attempt in
                AttemptDetailView(attempt: attempt)
            }
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(tierNames.enumerated()), id: \.offset) { idx, name in
                    filterChip(index: idx, label: name)
                }
            }
        }
    }

    private func filterChip(index: Int, label: String) -> some View {
        let isSelected = selectedFilter == index
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = index }
            HapticManager.selection()
        } label: {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.08))
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.blue.opacity(0.8) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label) filter")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        let attempts = filteredAttempts
        let passCount = attempts.filter { $0.passed }.count
        let avgScore = attempts.isEmpty ? 0.0 : attempts.map { $0.score }.reduce(0, +) / Double(attempts.count)
        let best = attempts.map { $0.score }.max() ?? 0.0

        return HStack(spacing: 0) {
            statsColumn(value: "\(attempts.count)", label: "Attempts")
            Divider().frame(height: 32).opacity(0.3)
            statsColumn(value: "\(passCount)", label: "Passed")
            Divider().frame(height: 32).opacity(0.3)
            statsColumn(value: avgScore > 0 ? "\(Int(avgScore))%" : "—", label: "Avg Score")
            Divider().frame(height: 32).opacity(0.3)
            statsColumn(value: best > 0 ? "\(Int(best))%" : "—", label: "Best")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                }
        }
    }

    private func statsColumn(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Attempts List

    private var attemptsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(filteredAttempts) { attempt in
                    attemptRow(attempt: attempt)
                        .onTapGesture {
                            selectedAttempt = attempt
                            HapticManager.lightImpact()
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    private func attemptRow(attempt: QuizAttempt) -> some View {
        HStack(spacing: 14) {
            // Pass/fail dot
            Circle()
                .fill(attempt.passed ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(attempt.problemTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(tierName(for: attempt.tierID))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(Int(attempt.score))%")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(attempt.passed ? .green : .red)
                Text(attempt.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.25))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            attempt.passed ? Color.green.opacity(0.2) : Color.red.opacity(0.15),
                            lineWidth: 1
                        )
                }
        }
        .accessibilityLabel("\(attempt.problemTitle), \(Int(attempt.score))%, \(attempt.passed ? "passed" : "failed")")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.2))
            Text("No attempts yet")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
            Text("Complete a challenge to see your history here.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.25))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Helpers

    private func tierName(for id: Int) -> String {
        let names = ["", "Tokyo", "London", "Singapore", "New York", "San Francisco"]
        return names[safe: id] ?? "Unknown"
    }
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
