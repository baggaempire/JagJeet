import '../models/reflection_entry.dart';
import '../models/source_type.dart';

class DailyReflectionService {
  ReflectionEntry? reflectionForToday(
    List<ReflectionEntry> entries,
    List<SourceType> preferredSources,
  ) {
    final filtered = entries.where((entry) => preferredSources.contains(entry.sourceType)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    if (filtered.isEmpty) {
      return entries.isEmpty ? null : entries.first;
    }

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
    final index = (dayOfYear - 1) % filtered.length;
    return filtered[index];
  }
}
