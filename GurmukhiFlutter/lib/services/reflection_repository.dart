import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/app_language.dart';
import '../models/reflection_entry.dart';

class ReflectionRepository {
  Future<List<ReflectionEntry>> fetchAllReflections({required AppLanguage language}) async {
    final raw = await rootBundle.loadString(language.assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((json) => ReflectionEntry.fromJson(json))
        .toList(growable: false);
  }
}
