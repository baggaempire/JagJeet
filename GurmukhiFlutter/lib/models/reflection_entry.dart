import 'source_type.dart';

class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.dayIndex,
    required this.date,
    required this.gurmukhiText,
    required this.englishMeaning,
    required this.simpleExplanation,
    required this.lifeReflection,
    required this.isFeatured,
    required this.audioFileName,
    required this.tags,
  });

  final String id;
  final SourceType sourceType;
  final String title;
  final int? dayIndex;
  final String? date;
  final String gurmukhiText;
  final String englishMeaning;
  final String simpleExplanation;
  final String lifeReflection;
  final bool isFeatured;
  final String? audioFileName;
  final List<String> tags;

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) {
    return ReflectionEntry(
      id: json['id'] as String,
      sourceType: SourceType.fromValue(json['sourceType'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      dayIndex: json['dayIndex'] as int?,
      date: json['date'] as String?,
      gurmukhiText: json['gurmukhiText'] as String? ?? '',
      englishMeaning: json['englishMeaning'] as String? ?? '',
      simpleExplanation: json['simpleExplanation'] as String? ?? '',
      lifeReflection: json['lifeReflection'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      audioFileName: json['audioFileName'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((tag) => tag.toString())
          .toList(growable: false),
    );
  }
}
