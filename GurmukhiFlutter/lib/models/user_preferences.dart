import 'app_language.dart';
import 'source_type.dart';

class UserPreferences {
  UserPreferences({
    required this.hasCompletedOnboarding,
    required this.preferredLanguage,
    required this.selectedSources,
    required this.notificationHour,
    required this.notificationMinute,
    required this.notificationTimes,
    required this.notificationsEnabled,
    required this.notificationTimesPerDay,
    required this.notificationUseRandomTimes,
  });

  bool hasCompletedOnboarding;
  AppLanguage preferredLanguage;
  List<SourceType> selectedSources;
  int notificationHour;
  int notificationMinute;
  List<int> notificationTimes;
  bool notificationsEnabled;
  int notificationTimesPerDay;
  bool notificationUseRandomTimes;

  static UserPreferences defaults() {
    return UserPreferences(
      hasCompletedOnboarding: false,
      preferredLanguage: AppLanguage.english,
      selectedSources: SourceType.values,
      notificationHour: 7,
      notificationMinute: 0,
      notificationTimes: const [420],
      notificationsEnabled: false,
      notificationTimesPerDay: 1,
      notificationUseRandomTimes: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'preferredLanguage': preferredLanguage.value,
      'selectedSources': selectedSources.map((e) => e.value).toList(),
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'notificationTimes': notificationTimes,
      'notificationsEnabled': notificationsEnabled,
      'notificationTimesPerDay': notificationTimesPerDay,
      'notificationUseRandomTimes': notificationUseRandomTimes,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final selected = (json['selectedSources'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => SourceType.fromValue(item.toString()))
        .toList();

    return UserPreferences(
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      preferredLanguage: AppLanguage.fromValue(json['preferredLanguage'] as String? ?? ''),
      selectedSources: selected.isEmpty ? SourceType.values : selected,
      notificationHour: (json['notificationHour'] as int?) ?? 7,
      notificationMinute: (json['notificationMinute'] as int?) ?? 0,
      notificationTimes: ((json['notificationTimes'] as List<dynamic>? ?? const [420])
          .map((item) => (item as num).toInt())
          .toList()),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      notificationTimesPerDay: ((json['notificationTimesPerDay'] as int?) ?? 1).clamp(1, 5),
      notificationUseRandomTimes: json['notificationUseRandomTimes'] as bool? ?? false,
    );
  }
}
