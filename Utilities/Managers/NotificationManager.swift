import UserNotifications

/// Manages local notification scheduling for the daily challenge reminder.
@MainActor
enum NotificationManager {

    private static let dailyChallengeID = "aether_daily_challenge"
    private static let enabledKey = "dailyReminderEnabled"
    private static let hourKey = "dailyReminderHour"
    private static let minuteKey = "dailyReminderMinute"

    // MARK: - Persisted Preferences

    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    static var reminderHour: Int {
        get {
            let h = UserDefaults.standard.integer(forKey: hourKey)
            return h == 0 && !UserDefaults.standard.bool(forKey: enabledKey) ? 9 : h
        }
        set { UserDefaults.standard.set(newValue, forKey: hourKey) }
    }

    static var reminderMinute: Int {
        get { UserDefaults.standard.integer(forKey: minuteKey) }
        set { UserDefaults.standard.set(newValue, forKey: minuteKey) }
    }

    static var reminderDate: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 9
            reminderMinute = components.minute ?? 0
        }
    }

    // MARK: - Authorization

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Scheduling

    static func scheduleDailyReminder() async {
        let granted = await requestAuthorization()
        guard granted, isEnabled else {
            cancelReminder()
            return
        }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyChallengeID])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Your daily architecture challenge is ready. Dive in!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: dailyChallengeID,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    static func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyChallengeID])
    }
}
