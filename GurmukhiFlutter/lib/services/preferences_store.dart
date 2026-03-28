import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/packet_progress.dart';
import '../models/user_preferences.dart';

class PreferencesStore {
  static const _preferencesKey = 'user_preferences';
  static const _bookmarksKey = 'bookmarked_ids';
  static const _chaupaiKey = 'chaupai_packet_progress';
  static const _japjiKey = 'japji_packet_progress';

  Future<UserPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_preferencesKey);
    if (raw == null || raw.isEmpty) {
      return UserPreferences.defaults();
    }
    return UserPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> savePreferences(UserPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(value.toJson()));
  }

  Future<Set<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey)?.toSet() ?? <String>{};
  }

  Future<void> saveBookmarks(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarksKey, ids.toList());
  }

  Future<PacketProgress> loadChaupaiProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chaupaiKey);
    if (raw == null || raw.isEmpty) {
      return PacketProgress.defaults();
    }
    return PacketProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveChaupaiProgress(PacketProgress value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaupaiKey, jsonEncode(value.toJson()));
  }

  Future<PacketProgress> loadJapjiProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_japjiKey);
    if (raw == null || raw.isEmpty) {
      return PacketProgress.defaults();
    }
    return PacketProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveJapjiProgress(PacketProgress value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_japjiKey, jsonEncode(value.toJson()));
  }
}
