import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("skipTutorials") private var skipTutorials = false
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { _, _ in
                            HapticManager.selection()
                        }
                        .accessibilityLabel("Dark mode")
                        .accessibilityHint("When on, the app uses a dark background with light lines")
                }

                Section("Demo") {
                    Toggle("Skip Tutorials", isOn: $skipTutorials)
                        .onChange(of: skipTutorials) { _, _ in
                            HapticManager.selection()
                        }
                        .accessibilityLabel("Skip tutorials")
                        .accessibilityHint("When on, tutorial overlays are skipped")

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                    }
                    .archsysMinTouchTarget()
                    .accessibilityLabel("Reset all progress")
                    .accessibilityHint("Erases all architectures, progress, and achievements. This cannot be undone.")
                }

                Section("Credits") {
                    VStack(alignment: .leading, spacing: LayoutConstants.spacingXS) {
                        Text("archsys")
                            .font(Typography.headingMedium)
                            .foregroundStyle(Color.archsysTextPrimary)
                        Text("City Architect — Swift Student Challenge 2026")
                            .font(Typography.bodySmall)
                            .foregroundStyle(Color.archsysTextSecondary)
                        Text("Learn mobile architecture through an interactive city-building metaphor.")
                            .font(Typography.bodySmall)
                            .foregroundStyle(Color.archsysTextTertiary)
                            .padding(.top, 4)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    creditsRow(
                        title: "Built with",
                        items: ["SwiftUI", "SwiftData", "SF Symbols"]
                    )
                    creditsRow(
                        title: "Concepts taught",
                        items: ["MVVM", "Repository Pattern", "Clean Architecture", "Event-Driven", "ML Integration"]
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.archsysBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticManager.lightImpact()
                        dismiss()
                    }
                    .archsysMinTouchTarget()
                    .accessibilityLabel("Done")
                }
            }
            .confirmationDialog("Reset All Progress?", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) {
                    HapticManager.mediumImpact()
                    SwiftDataManager.resetAll(context: modelContext)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    HapticManager.selection()
                }
            } message: {
                Text("This will erase all architectures, progress, achievements, and tier completion. This cannot be undone.")
            }
        }
    }

    private func creditsRow(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Typography.bodySmall)
                .foregroundStyle(Color.archsysTextTertiary)
            Text(items.joined(separator: " · "))
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.archsysTextSecondary)
        }
        .listRowBackground(Color.archsysSurface)
    }
}
