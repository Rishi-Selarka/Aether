import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onReset: (() -> Void)? = nil

    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            headerRow
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    settingsSection(header: "Appearance") {
                        toggleRow(
                            icon: "moon.fill",
                            iconColor: Color(red: 0.30, green: 0.35, blue: 0.70),
                            label: "Dark Mode",
                            isOn: $isDarkMode
                        )
                    }

                    settingsSection(header: "Data") {
                        buttonRow(
                            icon: "arrow.counterclockwise",
                            iconColor: Color(red: 0.75, green: 0.22, blue: 0.18),
                            label: "Reset All Progress",
                            role: .destructive
                        ) {
                            showResetConfirmation = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(.clear)
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

    // MARK: - Header

    private var headerRow: some View {
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
                .accessibilityLabel("Done")
            }
        }
    }

    // MARK: - Section Builder

    @ViewBuilder
    private func settingsSection<Content: View>(
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
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
            }
        }
    }

    // MARK: - Row Types

    private func toggleRow(
        icon: String,
        iconColor: Color,
        label: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            iconChip(icon: icon, color: iconColor)
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .onChange(of: isOn.wrappedValue) { _, _ in
                    HapticManager.selection()
                }
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
    }

    private func buttonRow(
        icon: String,
        iconColor: Color,
        label: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            HStack(spacing: 14) {
                iconChip(icon: icon, color: iconColor)
                Text(label)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(role == .destructive ? Color(red: 1.0, green: 0.32, blue: 0.28) : .primary)
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
