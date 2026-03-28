enum AppLanguage {
  english('english', 'English', 'assets/data/reflections.json'),
  hindi('hindi', 'Hindi', 'assets/data/reflections_hi.json'),
  punjabi('punjabi', 'Punjabi', 'assets/data/reflections_pa.json');

  const AppLanguage(this.value, this.displayName, this.assetPath);
  final String value;
  final String displayName;
  final String assetPath;

  static AppLanguage fromValue(String value) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.value == value,
      orElse: () => AppLanguage.english,
    );
  }
}
