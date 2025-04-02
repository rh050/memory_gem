import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/game_progress.dart';

class GameProgressManager {
  static const _storageKey = 'game_progress';

  /// Load progress from SharedPreferences
  static Future<GameProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final jsonData = jsonDecode(jsonString);
      return GameProgress.fromJson(jsonData);
    }

    // Return default if no saved progress
    return GameProgress.initial();
  }

  /// Save current progress to SharedPreferences
  static Future<void> save(GameProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(progress.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Reset progress
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
