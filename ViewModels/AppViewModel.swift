import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var preferences: UserPreferences
    @Published var reflections: [ReflectionEntry] = []
    @Published var bookmarkedIds: Set<String>
    @Published var chaupaiPacketProgress: ChaupaiPacketProgress
    @Published var japjiPacketProgress: JapjiPacketProgress
    @Published var currentRoute: AppRoute?

    private let repository: ReflectionRepositoryProtocol
    private let dailyService: DailyReflectionService
    private let defaultsStore: UserDefaultsStore
    let notificationManager: NotificationManager

    private enum Keys {
        static let preferences = "user_preferences"
        static let bookmarks = "bookmarked_ids"
        static let chaupaiPacketProgress = "chaupai_packet_progress"
        static let japjiPacketProgress = "japji_packet_progress"
    }

    init(
        repository: ReflectionRepositoryProtocol = ReflectionRepository(),
        dailyService: DailyReflectionService = DailyReflectionService(),
        defaultsStore: UserDefaultsStore = UserDefaultsStore(),
        notificationManager: NotificationManager? = nil
    ) {
        self.repository = repository
        self.dailyService = dailyService
        self.defaultsStore = defaultsStore
        self.notificationManager = notificationManager ?? NotificationManager()

        self.preferences = defaultsStore.load(UserPreferences.self, key: Keys.preferences) ?? .default
        self.bookmarkedIds = Set(defaultsStore.load([String].self, key: Keys.bookmarks) ?? [])
        self.chaupaiPacketProgress = defaultsStore.load(ChaupaiPacketProgress.self, key: Keys.chaupaiPacketProgress) ?? .default
        self.japjiPacketProgress = defaultsStore.load(JapjiPacketProgress.self, key: Keys.japjiPacketProgress) ?? .default

        loadReflections()
        bindNotificationRoutes()
    }

    var todayReflection: ReflectionEntry? {
        dailyService.reflectionForToday(from: reflections, preferredSources: preferences.selectedSources)
    }

    var filteredReflections: [ReflectionEntry] {
        reflections
            .filter { preferences.selectedSources.contains($0.sourceType) }
            .sorted { reflectionSort(lhs: $0, rhs: $1) }
    }

    var chaupaiEntries: [ReflectionEntry] {
        reflections
            .filter { $0.sourceType == .chaupaiSahib }
            .sorted { chaupaiSort(lhs: $0, rhs: $1) }
    }

    var japjiEntries: [ReflectionEntry] {
        reflections
            .filter { $0.id.hasPrefix("japji-") }
            .sorted { japjiSort(lhs: $0, rhs: $1) }
    }

    var chaupaiCompletedCount: Int {
        chaupaiPacketProgress.completedIds.intersection(Set(chaupaiEntries.map(\.id))).count
    }

    var chaupaiTotalCount: Int {
        chaupaiEntries.count
    }

    var japjiCompletedCount: Int {
        japjiPacketProgress.completedIds.intersection(Set(japjiEntries.map(\.id))).count
    }

    var japjiTotalCount: Int {
        japjiEntries.count
    }

    var bookmarkedEntries: [ReflectionEntry] {
        reflections.filter { bookmarkedIds.contains($0.id) }
    }

    func loadReflections() {
        do {
            reflections = try repository.fetchAllReflections(fileName: preferences.preferredLanguage.reflectionsFileName)
        } catch {
            do {
                reflections = try repository.fetchAllReflections(fileName: AppLanguage.english.reflectionsFileName)
                print("Failed to load preferred language reflections (\(preferences.preferredLanguage.rawValue)): \(error.localizedDescription). Falling back to English.")
            } catch {
                reflections = []
                print("Failed to load reflections: \(error.localizedDescription)")
            }
        }
    }

    func completeOnboarding(
        selectedSources: [SourceType],
        notificationDate: Date,
        notificationsEnabled: Bool,
        preferredLanguage: AppLanguage,
        notificationTimesPerDay: Int = 1,
        useRandomTimes: Bool = false,
        fixedMinutesOfDay: [Int] = []
    ) async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationDate)
        preferences.hasCompletedOnboarding = true
        preferences.preferredLanguage = preferredLanguage
        preferences.selectedSources = selectedSources
        preferences.notificationHour = components.hour ?? 7
        preferences.notificationMinute = components.minute ?? 0
        let firstMinute = max(0, min(1439, preferences.notificationHour * 60 + preferences.notificationMinute))
        let safeTimesPerDay = max(1, min(5, notificationTimesPerDay))
        if useRandomTimes {
            let interval = max(1, (24 * 60) / safeTimesPerDay)
            preferences.notificationTimes = (0..<safeTimesPerDay).map { index in
                (firstMinute + (index * interval)) % (24 * 60)
            }
        } else if !fixedMinutesOfDay.isEmpty {
            preferences.notificationTimes = Array(
                fixedMinutesOfDay
                    .map { max(0, min(1439, $0)) }
                    .sorted()
                    .prefix(safeTimesPerDay)
            )
        } else {
            let interval = max(1, (24 * 60) / safeTimesPerDay)
            preferences.notificationTimes = (0..<safeTimesPerDay).map { index in
                (firstMinute + (index * interval)) % (24 * 60)
            }
        }

        if let savedFirstMinute = preferences.notificationTimes.first {
            preferences.notificationHour = savedFirstMinute / 60
            preferences.notificationMinute = savedFirstMinute % 60
        }
        preferences.notificationsEnabled = notificationsEnabled
        preferences.notificationTimesPerDay = safeTimesPerDay
        preferences.notificationUseRandomTimes = useRandomTimes

        persistPreferences()
        loadReflections()

        if notificationsEnabled {
            await scheduleNotification()
        }
    }

    func updateSources(_ sources: [SourceType]) {
        preferences.selectedSources = sources
        persistPreferences()
        Task {
            if preferences.notificationsEnabled {
                await scheduleNotification()
            }
        }
    }

    func updateNotificationTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        preferences.notificationHour = components.hour ?? 7
        preferences.notificationMinute = components.minute ?? 0
        let firstMinute = max(0, min(1439, preferences.notificationHour * 60 + preferences.notificationMinute))
        if preferences.notificationTimes.isEmpty {
            preferences.notificationTimes = [firstMinute]
        } else {
            preferences.notificationTimes[0] = firstMinute
        }
        persistPreferences()
        Task {
            if preferences.notificationsEnabled {
                await scheduleNotification()
            }
        }
    }

    func updateNotificationFrequency(timesPerDay: Int, useRandomTimes: Bool) {
        let safeTimes = max(1, min(5, timesPerDay))
        preferences.notificationTimesPerDay = safeTimes
        preferences.notificationUseRandomTimes = useRandomTimes
        if preferences.notificationTimes.isEmpty {
            let firstMinute = max(0, min(1439, preferences.notificationHour * 60 + preferences.notificationMinute))
            preferences.notificationTimes = [firstMinute]
        }
        if preferences.notificationTimes.count > safeTimes {
            preferences.notificationTimes = Array(preferences.notificationTimes.prefix(safeTimes))
        } else if preferences.notificationTimes.count < safeTimes {
            let startMinute = preferences.notificationTimes.first ?? (preferences.notificationHour * 60 + preferences.notificationMinute)
            let interval = max(1, (24 * 60) / safeTimes)
            let existingCount = preferences.notificationTimes.count
            for index in existingCount..<safeTimes {
                preferences.notificationTimes.append((startMinute + (index * interval)) % (24 * 60))
            }
        }
        persistPreferences()
        Task {
            if preferences.notificationsEnabled {
                await scheduleNotification()
            }
        }
    }

    func updateNotificationTimes(_ minutesOfDay: [Int]) {
        let normalized = minutesOfDay
            .map { max(0, min(1439, $0)) }
            .sorted()
        guard !normalized.isEmpty else { return }

        preferences.notificationTimes = Array(normalized.prefix(max(1, min(5, preferences.notificationTimesPerDay))))
        let first = preferences.notificationTimes[0]
        preferences.notificationHour = first / 60
        preferences.notificationMinute = first % 60
        persistPreferences()
        Task {
            if preferences.notificationsEnabled {
                await scheduleNotification()
            }
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        preferences.notificationsEnabled = enabled
        persistPreferences()
        Task {
            if enabled {
                let granted = await notificationManager.requestAuthorization()
                if granted {
                    await scheduleNotification()
                } else {
                    preferences.notificationsEnabled = false
                    persistPreferences()
                    await notificationManager.cancelAllReminders()
                }
            } else {
                await notificationManager.cancelAllReminders()
            }
        }
    }

    func bookmarkToggle(_ entry: ReflectionEntry) {
        if bookmarkedIds.contains(entry.id) {
            bookmarkedIds.remove(entry.id)
        } else {
            bookmarkedIds.insert(entry.id)
        }
        defaultsStore.save(Array(bookmarkedIds), key: Keys.bookmarks)
    }

    func isBookmarked(_ entry: ReflectionEntry) -> Bool {
        bookmarkedIds.contains(entry.id)
    }

    func handleIncomingDeepLink(_ url: URL) {
        let deepLink = url.absoluteString
        if deepLink == AppNotification.deepLinkTodayReflection {
            currentRoute = .todayReflection
            return
        }
        if let id = AppNotification.reflectionId(from: deepLink) {
            currentRoute = .reflection(id: id)
        }
    }

    func shuffledLearningDeck(startingWith startEntry: ReflectionEntry) -> [ReflectionEntry] {
        let allowedSources: Set<SourceType> = [.jaapSahib, .rehrasSahib, .chaupaiSahib, .sukhmaniSahib]
        let base = reflections.filter {
            allowedSources.contains($0.sourceType) || $0.id.hasPrefix("japji-")
        }

        guard !base.isEmpty else { return [startEntry] }

        var remaining = base.filter { $0.id != startEntry.id }
        remaining.shuffle()

        if base.contains(where: { $0.id == startEntry.id }) {
            return [startEntry] + remaining
        } else if let first = remaining.first {
            return [first] + Array(remaining.dropFirst())
        } else {
            return [startEntry]
        }
    }

    func isChaupaiCompleted(_ entry: ReflectionEntry) -> Bool {
        chaupaiPacketProgress.completedIds.contains(entry.id)
    }

    func markChaupaiCompleted(_ entry: ReflectionEntry) {
        chaupaiPacketProgress.completedIds.insert(entry.id)
        persistChaupaiProgress()
    }

    func updateChaupaiCurrentIndex(_ index: Int) {
        let maxIndex = max(chaupaiEntries.count - 1, 0)
        chaupaiPacketProgress.currentIndex = min(max(index, 0), maxIndex)
        persistChaupaiProgress()
    }

    func resetChaupaiProgress() {
        chaupaiPacketProgress = .default
        persistChaupaiProgress()
    }

    func isJapjiCompleted(_ entry: ReflectionEntry) -> Bool {
        japjiPacketProgress.completedIds.contains(entry.id)
    }

    func markJapjiCompleted(_ entry: ReflectionEntry) {
        japjiPacketProgress.completedIds.insert(entry.id)
        persistJapjiProgress()
    }

    func updateJapjiCurrentIndex(_ index: Int) {
        let maxIndex = max(japjiEntries.count - 1, 0)
        japjiPacketProgress.currentIndex = min(max(index, 0), maxIndex)
        persistJapjiProgress()
    }

    func resetJapjiProgress() {
        japjiPacketProgress = .default
        persistJapjiProgress()
    }

    func clearRoute() {
        currentRoute = nil
    }

    func showOnboardingAgain() {
        preferences.hasCompletedOnboarding = false
        persistPreferences()
    }

    func updatePreferredLanguage(_ language: AppLanguage) {
        guard preferences.preferredLanguage != language else { return }
        preferences.preferredLanguage = language
        persistPreferences()
        loadReflections()
        Task {
            if preferences.notificationsEnabled {
                await scheduleNotification()
            }
        }
    }

    private func persistPreferences() {
        defaultsStore.save(preferences, key: Keys.preferences)
    }

    private func persistChaupaiProgress() {
        defaultsStore.save(chaupaiPacketProgress, key: Keys.chaupaiPacketProgress)
    }

    private func persistJapjiProgress() {
        defaultsStore.save(japjiPacketProgress, key: Keys.japjiPacketProgress)
    }

    private func scheduleNotification() async {
        let candidate = notificationCardCandidate()
        let sourceName = candidate.map { sourcePathLabel(for: $0) } ?? "Sikh scripture"
        let englishLine = candidate?.englishMeaning
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "Your daily reflection is ready."
        let deepLink = candidate.map { AppNotification.deepLinkForCard(id: $0.id) }
            ?? AppNotification.deepLinkTodayReflection

        await notificationManager.scheduleDailyNotification(
            hour: preferences.notificationUseRandomTimes ? nil : preferences.notificationHour,
            minute: preferences.notificationUseRandomTimes ? nil : preferences.notificationMinute,
            timesPerDay: preferences.notificationTimesPerDay,
            useRandomTimes: preferences.notificationUseRandomTimes,
            fixedMinutesOfDay: preferences.notificationUseRandomTimes ? [] : preferences.notificationTimes,
            sourceName: sourceName,
            englishLine: englishLine,
            deepLink: deepLink
        )
    }

    private func bindNotificationRoutes() {
        notificationManager.$pendingRoute
            .receive(on: RunLoop.main)
            .sink { [weak self] route in
                guard let route else { return }
                self?.currentRoute = route
                self?.notificationManager.pendingRoute = nil
            }
            .store(in: &cancellables)
    }

    private var cancellables: Set<AnyCancellable> = []

    private func reflectionSort(lhs: ReflectionEntry, rhs: ReflectionEntry) -> Bool {
        let lhsDay = lhs.dayIndex ?? Int.max
        let rhsDay = rhs.dayIndex ?? Int.max
        if lhsDay == rhsDay {
            return lhs.id < rhs.id
        }
        return lhsDay < rhsDay
    }

    private func notificationCardCandidate() -> ReflectionEntry? {
        let allowedSources: Set<SourceType> = [.jaapSahib, .rehrasSahib, .chaupaiSahib, .sukhmaniSahib]
        let pool = reflections.filter { allowedSources.contains($0.sourceType) }
        guard !pool.isEmpty else { return todayReflection }

        if let today = todayReflection {
            let deck = shuffledLearningDeck(startingWith: today)
            return deck.randomElement() ?? today
        }
        return pool.randomElement()
    }

    private func sourcePathLabel(for entry: ReflectionEntry) -> String {
        if entry.id.hasPrefix("japji-") {
            return "Japji Sahib"
        }
        return entry.sourceType.displayName
    }

    private func chaupaiSort(lhs: ReflectionEntry, rhs: ReflectionEntry) -> Bool {
        let lhsNum = chaupaiIdNumber(lhs.id)
        let rhsNum = chaupaiIdNumber(rhs.id)
        if lhsNum == rhsNum {
            return lhs.id < rhs.id
        }
        return lhsNum < rhsNum
    }

    private func chaupaiIdNumber(_ id: String) -> Int {
        guard let suffix = id.split(separator: "-").last, let number = Int(suffix) else {
            return Int.max
        }
        return number
    }

    private func japjiSort(lhs: ReflectionEntry, rhs: ReflectionEntry) -> Bool {
        let lhsNum = japjiIdNumber(lhs.id)
        let rhsNum = japjiIdNumber(rhs.id)
        if lhsNum == rhsNum {
            return lhs.id < rhs.id
        }
        return lhsNum < rhsNum
    }

    private func japjiIdNumber(_ id: String) -> Int {
        guard let suffix = id.split(separator: "-").last, let number = Int(suffix) else {
            return Int.max
        }
        return number
    }
}
