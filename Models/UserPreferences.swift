import Foundation

struct UserPreferences: Codable {
    var hasCompletedOnboarding: Bool
    var preferredLanguage: AppLanguage
    var selectedSources: [SourceType]
    var notificationHour: Int
    var notificationMinute: Int
    var notificationTimes: [Int]
    var notificationsEnabled: Bool
    var notificationTimesPerDay: Int
    var notificationUseRandomTimes: Bool

    static let `default` = UserPreferences(
        hasCompletedOnboarding: false,
        preferredLanguage: .english,
        selectedSources: SourceType.allCases,
        notificationHour: 7,
        notificationMinute: 0,
        notificationTimes: [7 * 60],
        notificationsEnabled: false,
        notificationTimesPerDay: 1,
        notificationUseRandomTimes: false
    )

    private enum CodingKeys: String, CodingKey {
        case hasCompletedOnboarding
        case preferredLanguage
        case selectedSources
        case notificationHour
        case notificationMinute
        case notificationTimes
        case notificationsEnabled
        case notificationTimesPerDay
        case notificationUseRandomTimes
    }

    init(
        hasCompletedOnboarding: Bool,
        preferredLanguage: AppLanguage,
        selectedSources: [SourceType],
        notificationHour: Int,
        notificationMinute: Int,
        notificationTimes: [Int],
        notificationsEnabled: Bool,
        notificationTimesPerDay: Int,
        notificationUseRandomTimes: Bool
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.preferredLanguage = preferredLanguage
        self.selectedSources = selectedSources
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.notificationTimes = notificationTimes
        self.notificationsEnabled = notificationsEnabled
        self.notificationTimesPerDay = notificationTimesPerDay
        self.notificationUseRandomTimes = notificationUseRandomTimes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasCompletedOnboarding = try container.decode(Bool.self, forKey: .hasCompletedOnboarding)
        preferredLanguage = try container.decodeIfPresent(AppLanguage.self, forKey: .preferredLanguage) ?? .english
        selectedSources = try container.decode([SourceType].self, forKey: .selectedSources)
        notificationHour = try container.decode(Int.self, forKey: .notificationHour)
        notificationMinute = try container.decode(Int.self, forKey: .notificationMinute)
        let fallbackMinute = max(0, min(1439, notificationHour * 60 + notificationMinute))
        let decodedTimes = try container.decodeIfPresent([Int].self, forKey: .notificationTimes) ?? [fallbackMinute]
        notificationTimes = decodedTimes
            .map { max(0, min(1439, $0)) }
            .sorted()
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        notificationTimesPerDay = max(1, min(5, try container.decodeIfPresent(Int.self, forKey: .notificationTimesPerDay) ?? 1))
        notificationUseRandomTimes = try container.decodeIfPresent(Bool.self, forKey: .notificationUseRandomTimes) ?? false
    }
}
