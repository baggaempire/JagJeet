enum SourceType {
  jaapSahib('jaap_sahib', 'Jaap Sahib'),
  rehrasSahib('rehras_sahib', 'Rehras Sahib'),
  chaupaiSahib('chaupai_sahib', 'Chaupai Sahib'),
  sukhmaniSahib('sukhmani_sahib', 'Sukhmani Sahib'),
  hukamnama('hukamnama', 'Daily Hukamnama');

  const SourceType(this.value, this.displayName);
  final String value;
  final String displayName;

  static SourceType fromValue(String value) {
    return SourceType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => SourceType.hukamnama,
    );
  }
}
