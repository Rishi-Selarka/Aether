import SwiftUI
import SwiftData

// NOTE: No NavigationStack or List — both cause content clipping inside
// a .medium presentationDetent sheet. NavigationStack reserves nav-bar
// height that overflows the fixed detent bounds; List doesn't honour the
// constrained height. Plain VStack + ScrollView solves this cleanly.

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onReset: (() -> Void)? = nil

    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header — no NavigationStack needed
            ZStack {
                Text("Settings")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                    Button("Done") {
                        HapticManager.lightImpact()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)

            // Content — ScrollView so height is always content-driven
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    section(header: "Appearance") {
                        toggleRow(
                            icon: "moon.fill",
                            iconColor: Color(red: 0.30, green: 0.35, blue: 0.70),
                            label: "Dark Mode",
                            isOn: $isDarkMode
                        )
                    }

                    section(header: "Data") {
                        buttonRow(
                            icon: "arrow.counterclockwise",
                            iconColor: Color(red: 0.80, green: 0.22, blue: 0.18),
                            label: "Reset All Progress",
                            isDestructive: true
                        ) {
                            showResetConfirmation = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
            }
        }
        // Fill the sheet height so glassEffect covers it completely
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(in: .rect(cornerRadius: 32))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .confirmationDialog("Reset All Progress?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                HapticManager.mediumImpact()
                SwiftDataManager.resetAll(context: modelContext)
                onReset?()
                dismiss()
            }
            Button("Cancel", role: .cancel) { HapticManager.selection() }
        } message: {
            Text("This will erase all progress, achievements, and tier completion. This cannot be undone.")
        }
    }

    // MARK: - Section

    @ViewBuilder
    private func section<Content: View>(
        header: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.6)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Rows

    private func toggleRow(
        icon: String,
        iconColor: Color,
        label: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            iconChip(icon: icon, color: iconColor)
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { _, _ in HapticManager.selection() }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
    }

    private func buttonRow(
        icon: String,
        iconColor: Color,
        label: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconChip(icon: icon, color: iconColor)
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(isDestructive ? Color(red: 1.0, green: 0.27, blue: 0.23) : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
        }
    }

    private func iconChip(icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 32, height: 32)
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
