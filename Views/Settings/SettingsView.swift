import SwiftUI
import SwiftData

// Plain VStack + ScrollView (no NavigationStack/List) to avoid content clipping in .medium detent.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onReset: (() -> Void)? = nil

    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false
    @State private var reminderTime = NotificationManager.reminderDate
    @State private var showResetConfirmation = false

    private let headerBarSpacing: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            GlassEffectContainer(spacing: headerBarSpacing) {
                HStack(spacing: headerBarSpacing) {
                    Spacer(minLength: 0)
                    Text("Settings")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)

                    Button("Done") {
                        HapticManager.lightImpact()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .buttonStyle(.glass)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
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

                    section(header: "Notifications") {
                        toggleRow(
                            icon: "bell.fill",
                            iconColor: Color(red: 0.90, green: 0.55, blue: 0.15),
                            label: "Daily Challenge",
                            isOn: $reminderEnabled
                        )
                        .onChange(of: reminderEnabled) { _, enabled in
                            NotificationManager.isEnabled = enabled
                            Task {
                                if enabled {
                                    await NotificationManager.scheduleDailyReminder()
                                } else {
                                    NotificationManager.cancelReminder()
                                }
                            }
                        }

                        if reminderEnabled {
                            Divider()
                                .padding(.horizontal, 14)

                            timePickerRow(
                                icon: "clock.fill",
                                iconColor: Color(red: 0.90, green: 0.55, blue: 0.15),
                                label: "Challenge Time",
                                selection: $reminderTime
                            )
                            .onChange(of: reminderTime) { _, newTime in
                                NotificationManager.reminderDate = newTime
                                Task {
                                    await NotificationManager.scheduleDailyReminder()
                                }
                            }
                        }
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
        .background(.ultraThinMaterial.opacity(0.04))
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
            .glassEffect(.regular, in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(isDarkMode ? 0.12 : 0.08), lineWidth: 0.5)
            }
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
        .buttonStyle(.glass)
    }

    private func timePickerRow(
        icon: String,
        iconColor: Color,
        label: String,
        selection: Binding<Date>
    ) -> some View {
        HStack(spacing: 14) {
            iconChip(icon: icon, color: iconColor)
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
            Spacer()
            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
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
