import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onReset: (() -> Void)? = nil

    @AppStorage("isDarkMode") private var isDarkMode = false
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

                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                    }
                    .archsysMinTouchTarget()
                    .accessibilityLabel("Reset all progress")
                    .accessibilityHint("Erases all architectures, progress, and achievements. This cannot be undone.")
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
                    onReset?()
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
}
