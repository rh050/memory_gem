import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';
import '../data/achievements_list.dart';

class AchievementManager {
  static const _storageKey = 'achievements';

  static Future<List<Achievement>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List data = jsonDecode(jsonString);
      return data.map((e) => Achievement.fromJson(e)).toList();
    }

    return defaultAchievements;
  }

  static Future<void> save(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  static Future<void> unlock(String id) async {
    final list = await load();
    final updated = list.map((a) {
      if (a.id == id && !a.achieved) {
        return a.copyWith(achieved: true);
      }
      return a;
    }).toList();
    await save(updated);
  }

  static Future<bool> isUnlocked(String id) async {
    final list = await load();
    return list.firstWhere((a) => a.id == id).achieved;
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
