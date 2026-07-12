import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/activity.dart';

enum DayType { weekday, weekend }

class StorageService {
  static late SharedPreferences _prefs;
  static const String _activitiesKey = 'activities';
  static const String _recordsKey = 'records';
  static const String _pointsKey = 'points';
  static const String _streakKey = 'streak';
  static const String _challengesKey = 'challenges';
  static const String _shortGoalKey = 'short_goal';
  static const String _longGoalKey = 'long_goal';
  static const String _languageKey = 'language_fa';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Activities Management
  static Future<void> saveActivities(
      List<Activity> activities, DayType dayType) async {
    final key = '${_activitiesKey}_${dayType.name}';
    final jsonList = activities.map((a) => a.toJson()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  static Future<List<Activity>> loadActivities(DayType dayType) async {
    final key = '${_activitiesKey}_${dayType.name}';
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => Activity.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Records Management (Notes)
  static Future<void> saveRecords(List<Map<String, dynamic>> records) async {
    await _prefs.setString(_recordsKey, jsonEncode(records));
  }

  static Future<List<Map<String, dynamic>>> loadRecords() async {
    final jsonString = _prefs.getString(_recordsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(jsonList);
    } catch (e) {
      return [];
    }
  }

  // Points Management
  static Future<void> savePoints(int points) async {
    await _prefs.setInt(_pointsKey, points);
  }

  static Future<int> loadPoints() async {
    return _prefs.getInt(_pointsKey) ?? 0;
  }

  // Streak Management
  static Future<void> saveStreak(int streak) async {
    await _prefs.setInt(_streakKey, streak);
  }

  static Future<int> loadStreak() async {
    return _prefs.getInt(_streakKey) ?? 0;
  }

  static Future<void> rolloverStreakIfNeeded() async {
    final lastRolloverKey = 'last_rollover_date';
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    final lastRollover = _prefs.getString(lastRolloverKey);
    if (lastRollover != todayString) {
      await _prefs.setString(lastRolloverKey, todayString);
    }
  }

  // Challenges Management
  static Future<void> saveChallenges(String date, List<bool> completed) async {
    await _prefs.setString('${_challengesKey}_$date', jsonEncode(completed));
  }

  static Future<List<bool>> loadChallenges(String date) async {
    final jsonString = _prefs.getString('${_challengesKey}_$date');
    if (jsonString == null) return [false, false, false];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return List<bool>.from(jsonList);
    } catch (e) {
      return [false, false, false];
    }
  }

  // Goals Management
  static Future<void> saveGoals(String shortGoal, String longGoal) async {
    await _prefs.setString(_shortGoalKey, shortGoal);
    await _prefs.setString(_longGoalKey, longGoal);
  }

  static Future<String> loadShortGoal() async {
    return _prefs.getString(_shortGoalKey) ??
        'Pass the graduate entrance exam';
  }

  static Future<String> loadLongGoal() async {
    return _prefs.getString(_longGoalKey) ?? 'Financial independence via HVAC';
  }

  // Language Management
  static Future<void> saveLanguage(bool isFarsi) async {
    await _prefs.setBool(_languageKey, isFarsi);
  }

  static Future<bool> loadLanguage() async {
    return _prefs.getBool(_languageKey) ?? true;
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
