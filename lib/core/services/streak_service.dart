import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Streak Service for tracking user engagement
class StreakService {
  static const String _prayerStreakKey = 'prayer_streak';
  static const String _quranStreakKey = 'quran_streak';
  static const String _dhikrStreakKey = 'dhikr_streak';
  static const String _lastPrayerDateKey = 'last_prayer_date';
  static const String _lastQuranDateKey = 'last_quran_date';
  static const String _lastDhikrDateKey = 'last_dhikr_date';
  static const String _prayerLogKey = 'prayer_log';

  /// Get current prayer streak
  Future<int> getPrayerStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prayerStreakKey) ?? 0;
  }

  /// Get current Quran reading streak
  Future<int> getQuranStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quranStreakKey) ?? 0;
  }

  /// Get current Dhikr streak
  Future<int> getDhikrStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dhikrStreakKey) ?? 0;
  }

  /// Get all streaks
  Future<StreakData> getAllStreaks() async {
    return StreakData(
      prayerStreak: await getPrayerStreak(),
      quranStreak: await getQuranStreak(),
      dhikrStreak: await getDhikrStreak(),
    );
  }

  /// Log a completed prayer
  Future<void> logPrayer(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    
    // Get or create today's prayer log
    final logJson = prefs.getString(_prayerLogKey) ?? '{}';
    final log = Map<String, List<String>>.from(
      (jsonDecode(logJson) as Map).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
    
    if (!log.containsKey(today)) {
      log[today] = [];
    }
    
    if (!log[today]!.contains(prayerName)) {
      log[today]!.add(prayerName);
      await prefs.setString(_prayerLogKey, jsonEncode(log));
      
      // Check if all 5 prayers completed today
      if (log[today]!.length >= 5) {
        await _updateStreak(_prayerStreakKey, _lastPrayerDateKey);
      }
    }
  }

  /// Log Quran reading
  Future<void> logQuranReading() async {
    await _updateStreak(_quranStreakKey, _lastQuranDateKey);
  }

  /// Log Dhikr completion
  Future<void> logDhikr() async {
    await _updateStreak(_dhikrStreakKey, _lastDhikrDateKey);
  }

  /// Update a streak
  Future<void> _updateStreak(String streakKey, String lastDateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final lastDate = prefs.getString(lastDateKey);
    
    if (lastDate == today) {
      // Already logged today
      return;
    }
    
    int currentStreak = prefs.getInt(streakKey) ?? 0;
    
    if (lastDate == yesterday) {
      // Consecutive day - increment streak
      currentStreak++;
    } else {
      // Streak broken - reset to 1
      currentStreak = 1;
    }
    
    await prefs.setInt(streakKey, currentStreak);
    await prefs.setString(lastDateKey, today);
  }

  /// Reset all streaks (for testing)
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prayerStreakKey);
    await prefs.remove(_quranStreakKey);
    await prefs.remove(_dhikrStreakKey);
    await prefs.remove(_lastPrayerDateKey);
    await prefs.remove(_lastQuranDateKey);
    await prefs.remove(_lastDhikrDateKey);
    await prefs.remove(_prayerLogKey);
  }

  /// Get today's completed prayers
  Future<List<String>> getTodayPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final logJson = prefs.getString(_prayerLogKey) ?? '{}';
    final log = jsonDecode(logJson) as Map;
    
    if (log.containsKey(today)) {
      return List<String>.from(log[today]);
    }
    return [];
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Streak data model
class StreakData {
  final int prayerStreak;
  final int quranStreak;
  final int dhikrStreak;

  StreakData({
    required this.prayerStreak,
    required this.quranStreak,
    required this.dhikrStreak,
  });

  int get totalStreak => prayerStreak + quranStreak + dhikrStreak;
  
  int get longestStreak => [prayerStreak, quranStreak, dhikrStreak].reduce(
    (a, b) => a > b ? a : b,
  );
}
