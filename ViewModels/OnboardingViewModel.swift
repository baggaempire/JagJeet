import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedLanguage: AppLanguage = .english
    @Published var notificationsPerDay: Int = 1
    @Published var useRandomTimes: Bool = false
    @Published var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @Published var notificationTimes: [Date] = [Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()]

    var canContinue: Bool {
        (1...4).contains(notificationsPerDay)
    }

    func setNotificationCount(_ count: Int) {
        let safeCount = max(1, min(4, count))
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
