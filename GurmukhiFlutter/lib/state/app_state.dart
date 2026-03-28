import 'package:flutter/foundation.dart';

import '../models/app_language.dart';
import '../models/packet_progress.dart';
import '../models/reflection_entry.dart';
import '../models/source_type.dart';
import '../models/user_preferences.dart';
import '../services/daily_reflection_service.dart';
import '../services/notification_service.dart';
import '../services/preferences_store.dart';
import '../services/reflection_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    required ReflectionRepository repository,
    required DailyReflectionService dailyService,
    required PreferencesStore store,
    required NotificationService notifications,
  })  : _repository = repository,
        _dailyService = dailyService,
        _store = store,
        _notifications = notifications;

  final ReflectionRepository _repository;
  final DailyReflectionService _dailyService;
  final PreferencesStore _store;
  final NotificationService _notifications;

  UserPreferences preferences = UserPreferences.defaults();
  List<ReflectionEntry> reflections = const [];
  Set<String> bookmarkedIds = <String>{};
  PacketProgress chaupaiPacketProgress = PacketProgress.defaults();
  PacketProgress japjiPacketProgress = PacketProgress.defaults();
  bool isLoading = true;

  Future<void> initialize() async {
    preferences = await _store.loadPreferences();
    bookmarkedIds = await _store.loadBookmarks();
    chaupaiPacketProgress = await _store.loadChaupaiProgress();
    japjiPacketProgress = await _store.loadJapjiProgress();

    await _notifications.initialize();
    await loadReflections();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadReflections() async {
    try {
      reflections = await _repository.fetchAllReflections(language: preferences.preferredLanguage);
    } catch (_) {
      reflections = await _repository.fetchAllReflections(language: AppLanguage.english);
    }
    notifyListeners();
  }

  ReflectionEntry? get todayReflection {
    return _dailyService.reflectionForToday(reflections, preferences.selectedSources);
  }

  List<ReflectionEntry> get filteredReflections {
    final allowed = preferences.selectedSources.toSet();
    final list = reflections.where((entry) => allowed.contains(entry.sourceType)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  List<ReflectionEntry> get bookmarkedEntries {
    return reflections.where((entry) => bookmarkedIds.contains(entry.id)).toList();
  }

  Future<void> completeOnboarding({
    required List<SourceType> selectedSources,
    required AppLanguage language,
    required bool notificationsEnabled,
    required int notificationHour,
    required int notificationMinute,
  }) async {
    preferences
      ..hasCompletedOnboarding = true
      ..preferredLanguage = language
      ..selectedSources = selectedSources
      ..notificationsEnabled = notificationsEnabled
      ..notificationHour = notificationHour
      ..notificationMinute = notificationMinute
      ..notificationTimes = [notificationHour * 60 + notificationMinute]
      ..notificationTimesPerDay = 1
      ..notificationUseRandomTimes = false;

    await _store.savePreferences(preferences);
    await loadReflections();

    if (notificationsEnabled) {
      final granted = await _notifications.requestPermission();
      if (granted) {
        await _notifications.scheduleDailySkeleton(
          title: 'Today\'s Sikh Wisdom',
          body: 'Take 2 minutes for your daily reflection.',
        );
      }
    }

    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    preferences.preferredLanguage = language;
    await _store.savePreferences(preferences);
    await loadReflections();
  }

  Future<void> setSources(List<SourceType> sources) async {
    preferences.selectedSources = sources;
    await _store.savePreferences(preferences);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    preferences.notificationsEnabled = enabled;
    await _store.savePreferences(preferences);

    if (!enabled) {
      await _notifications.cancelAll();
    }

    notifyListeners();
  }

  Future<void> toggleBookmark(ReflectionEntry entry) async {
    if (bookmarkedIds.contains(entry.id)) {
      bookmarkedIds.remove(entry.id);
    } else {
      bookmarkedIds.add(entry.id);
    }
    await _store.saveBookmarks(bookmarkedIds);
    notifyListeners();
  }

  bool isBookmarked(ReflectionEntry entry) => bookmarkedIds.contains(entry.id);

  List<ReflectionEntry> shuffledLearningDeck({required ReflectionEntry startEntry}) {
    final allowed = <SourceType>{
      SourceType.jaapSahib,
      SourceType.rehrasSahib,
      SourceType.chaupaiSahib,
      SourceType.sukhmaniSahib,
    };

    final base = reflections
        .where((entry) => allowed.contains(entry.sourceType) || entry.id.startsWith('japji-'))
        .toList();

    if (base.isEmpty) {
      return [startEntry];
    }

    final remaining = base.where((entry) => entry.id != startEntry.id).toList()..shuffle();
    final hasStart = base.any((entry) => entry.id == startEntry.id);
    return hasStart ? [startEntry, ...remaining] : remaining;
  }
}
