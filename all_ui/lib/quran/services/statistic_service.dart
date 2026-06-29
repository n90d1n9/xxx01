import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/surah.dart';

class StatisticsService {
  static const String _statsKey = 'reading_statistics';
  Timer? _readingTimer;
  DateTime? _sessionStart;

  Future<ReadingStatistics> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    if (statsJson == null) return ReadingStatistics();
    return ReadingStatistics.fromJson(json.decode(statsJson));
  }

  Future<void> recordVerseRead(int surahNumber, int ayahNumber) async {
    final stats = await getStatistics();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final updatedVersesMap = Map<String, int>.from(stats.versesReadByDate);
    updatedVersesMap[today] = (updatedVersesMap[today] ?? 0) + 1;

    final lastRead = stats.lastReadDate;
    int newStreak = stats.currentStreak;
    if (lastRead != null) {
      final daysDiff = DateTime.now().difference(lastRead).inDays;
      if (daysDiff == 0) {
        newStreak = stats.currentStreak;
      } else if (daysDiff == 1) {
        newStreak = stats.currentStreak + 1;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final newStats = stats.copyWith(
      totalVersesRead: stats.totalVersesRead + 1,
      currentStreak: newStreak,
      longestStreak:
          newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
      lastReadDate: DateTime.now(),
      versesReadByDate: updatedVersesMap,
    );

    await _saveStatistics(newStats);
  }

  Future<void> recordPageRead(int pageNumber) async {
    final stats = await getStatistics();
    final newStats = stats.copyWith(totalPagesRead: stats.totalPagesRead + 1);
    await _saveStatistics(newStats);
  }

  void startReadingSession() {
    _sessionStart = DateTime.now();
    _readingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateReadingTime();
    });
  }

  Future<void> _updateReadingTime() async {
    if (_sessionStart != null) {
      final stats = await getStatistics();
      final sessionDuration = DateTime.now().difference(_sessionStart!);
      final newStats = stats.copyWith(
        totalTimeSpent: stats.totalTimeSpent + sessionDuration,
      );
      await _saveStatistics(newStats);
      _sessionStart = DateTime.now();
    }
  }

  void endReadingSession() async {
    await _updateReadingTime();
    _readingTimer?.cancel();
    _sessionStart = null;
  }

  Future<void> markSurahCompleted(int surahNumber) async {
    final stats = await getStatistics();
    if (!stats.completedSurahs.contains(surahNumber)) {
      final newStats = stats.copyWith(
        completedSurahs: [...stats.completedSurahs, surahNumber],
      );
      await _saveStatistics(newStats);
    }
  }

  Future<void> _saveStatistics(ReadingStatistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<Map<String, int>> getWeeklyStats() async {
    final stats = await getStatistics();
    final now = DateTime.now();
    final Map<String, int> weeklyStats = {};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('E').format(date);
      weeklyStats[dayName] = stats.versesReadByDate[key] ?? 0;
    }
    return weeklyStats;
  }

  Future<Map<String, int>> getMonthlyStats() async {
    final stats = await getStatistics();
    final now = DateTime.now();
    final Map<String, int> monthlyStats = {};

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel = DateFormat('MM-dd').format(date);
      monthlyStats[dayLabel] = stats.versesReadByDate[key] ?? 0;
    }
    return monthlyStats;
  }
}
