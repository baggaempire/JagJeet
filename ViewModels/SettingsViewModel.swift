import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: AppLanguage
    @Published var notificationTime: Date
    @Published var notificationTimes: [Date]
    @Published var notificationsEnabled: Bool
    @Published var notificationsPerDay: Int
    @Published var useRandomTimes: Bool

    init(preferences: UserPreferences) {
        selectedLanguage = preferences.preferredLanguage
        notificationTime = Date()
        notificationTimes = []
        notificationsEnabled = preferences.notificationsEnabled
        notificationsPerDay = max(1, min(5, preferences.notificationTimesPerDay))
        useRandomTimes = preferences.notificationUseRandomTimes
        load(from: preferences)
    }

    func load(from preferences: UserPreferences) {
        selectedLanguage = preferences.preferredLanguage
        let firstMinutes = preferences.notificationTimes.first ?? (preferences.notificationHour * 60 + preferences.notificationMinute)
        notificationTime = Self.date(from: firstMinutes)
        notificationTimes = preferences.notificationTimes.map(Self.date(from:))
        if notificationTimes.isEmpty {
            notificationTimes = [notificationTime]
        }
        notificationsEnabled = preferences.notificationsEnabled
        notificationsPerDay = max(1, min(5, preferences.notificationTimesPerDay))
        useRandomTimes = preferences.notificationUseRandomTimes
        setNotificationCount(notificationsPerDay)
    }

    func setNotificationCount(_ count: Int) {
        let safeCount = max(1, min(5, count))
        notificationsPerDay = safeCount

        if notificationTimes.isEmpty {
            notificationTimes = [notificationTime]
        }

        if notificationTimes.count > safeCount {
            notificationTimes = Array(notificationTimes.prefix(safeCount))
            notificationTime = notificationTimes[0]
            return
        }

        if notificationTimes.count < safeCount {
            let startMinutes = Self.minutes(from: notificationTimes[0])
            let interval = max(1, (24 * 60) / safeCount)
            var generated = notificationTimes
            for index in notificationTimes.count..<safeCount {
                let minuteOfDay = (startMinutes + (index * interval)) % (24 * 60)
                generated.append(Self.date(from: minuteOfDay))
            }
            notificationTimes = generated
        }
        notificationTime = notificationTimes[0]
    }

    func notificationMinutesOfDay() -> [Int] {
        notificationTimes
            .map(Self.minutes(from:))
            .sorted()
    }

    private static func minutes(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return max(0, min(1439, (hour * 60) + minute))
    }

    private static func date(from totalMinutes: Int) -> Date {
        let safe = max(0, min(1439, totalMinutes))
        let hour = safe / 60
        let minute = safe % 60
        return Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }
}
