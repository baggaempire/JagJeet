import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    @Published var pendingRoute: AppRoute?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func cancelAllReminders() async {
        await clearAppReminderRequests(center: UNUserNotificationCenter.current())
    }

    func scheduleDailyNotification(
        hour: Int?,
        minute: Int?,
        timesPerDay: Int,
        useRandomTimes: Bool,
        fixedMinutesOfDay: [Int] = [],
        sourceName: String,
        englishLine: String,
        deepLink: String
    ) async {
        let center = UNUserNotificationCenter.current()
        await clearAppReminderRequests(center: center)

        let safeTimesPerDay = max(1, min(5, timesPerDay))

        let content = UNMutableNotificationContent()
        content.title = "Today's Sikh Wisdom"
        content.body = "From \(sourceName): \(englishLine) Take 2 minutes for yourself."
        content.sound = .default
        content.userInfo = [AppNotification.deepLinkKey: deepLink]

        if useRandomTimes {
            await scheduleRandomNotifications(
                center: center,
                content: content,
                timesPerDay: safeTimesPerDay
            )
            return
        }

        let normalizedFixedTimes = Array(
            Set(fixedMinutesOfDay.map { max(0, min(1439, $0)) })
        ).sorted()
        if !normalizedFixedTimes.isEmpty {
            for (index, totalMinutes) in normalizedFixedTimes.prefix(safeTimesPerDay).enumerated() {
                var dateComponents = DateComponents()
                dateComponents.hour = totalMinutes / 60
                dateComponents.minute = totalMinutes % 60

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let id = "\(AppNotification.reminderPrefix)_fixed_\(index)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                do {
                    try await center.add(request)
                } catch {
                    print("Notification scheduling failed: \(error.localizedDescription)")
                }
            }
            return
        }

        let baseHour = hour ?? 7
        let baseMinute = minute ?? 0
        let baseTotalMinutes = ((baseHour % 24 + 24) % 24) * 60 + ((baseMinute % 60 + 60) % 60)
        let interval = max(1, (24 * 60) / safeTimesPerDay)

        for index in 0..<safeTimesPerDay {
            let totalMinutes = (baseTotalMinutes + (index * interval)) % (24 * 60)
            var dateComponents = DateComponents()
            dateComponents.hour = totalMinutes / 60
            dateComponents.minute = totalMinutes % 60

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let id = "\(AppNotification.reminderPrefix)_fixed_\(index)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                print("Notification scheduling failed: \(error.localizedDescription)")
            }
        }
    }

    private func clearAppReminderRequests(center: UNUserNotificationCenter) async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(AppNotification.reminderPrefix) }
        if !ids.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private func scheduleRandomNotifications(
        center: UNUserNotificationCenter,
        content: UNMutableNotificationContent,
        timesPerDay: Int
    ) async {
        let maxPending = 60
        let daysToSchedule = max(1, maxPending / timesPerDay)
        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<daysToSchedule {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            var usedMinutes: Set<Int> = []

            for index in 0..<timesPerDay {
                let minuteOfDay = randomMinute(excluding: usedMinutes)
                usedMinutes.insert(minuteOfDay)

                let hour = minuteOfDay / 60
                let minute = minuteOfDay % 60
                let dayComponents = calendar.dateComponents([.year, .month, .day], from: dayDate)
                var components = DateComponents()
                components.year = dayComponents.year
                components.month = dayComponents.month
                components.day = dayComponents.day
                components.hour = hour
                components.minute = minute

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let id = "\(AppNotification.reminderPrefix)_random_\(dayOffset)_\(index)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                do {
                    try await center.add(request)
                } catch {
                    print("Notification scheduling failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func randomMinute(excluding used: Set<Int>) -> Int {
        var minute = Int.random(in: 0..<(24 * 60))
        var attempts = 0
        while used.contains(minute) && attempts < 50 {
            minute = Int.random(in: 0..<(24 * 60))
            attempts += 1
        }
        return minute
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let deepLink = userInfo[AppNotification.deepLinkKey] as? String {
            Task { @MainActor in
                if deepLink == AppNotification.deepLinkTodayReflection {
                    self.pendingRoute = .todayReflection
                } else if let id = AppNotification.reflectionId(from: deepLink) {
                    self.pendingRoute = .reflection(id: id)
                }
            }
        }
        completionHandler()
    }
}
