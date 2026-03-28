import Foundation

enum AppNotification {
    static let dailyReminderId = "daily_sikh_wisdom"
    static let reminderPrefix = "daily_sikh_wisdom"
    static let deepLinkKey = "deep_link"
    static let deepLinkScheme = "jagjeet"
    static let deepLinkTodayReflection = "\(deepLinkScheme)://reflection/today"

    static func deepLinkForCard(id: String) -> String {
        "\(deepLinkScheme)://reflection/card/\(id)"
    }

    static func reflectionId(from deepLink: String) -> String? {
        let prefix = "\(deepLinkScheme)://reflection/card/"
        guard deepLink.hasPrefix(prefix) else { return nil }
        return String(deepLink.dropFirst(prefix.count))
    }
}
