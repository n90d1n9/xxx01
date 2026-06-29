import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/memorization.dart';

class MemorizationService {
  static const String _memorizationKey = 'memorization_entries';

  Future<List<MemorizationEntry>> getMemorizationEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_memorizationKey);
    if (entriesJson == null) return [];

    final List decoded = json.decode(entriesJson);
    return decoded.map((e) => MemorizationEntry.fromJson(e)).toList();
  }

  Future<void> startMemorizing(int surahNumber, int ayahNumber) async {
    final entries = await getMemorizationEntries();

    final existingIndex = entries.indexWhere(
      (e) => e.surahNumber == surahNumber && e.ayahNumber == ayahNumber,
    );

    if (existingIndex == -1) {
      final entry = MemorizationEntry(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        startDate: DateTime.now(),
        nextReview: DateTime.now().add(const Duration(days: 1)),
        status: MemorizationStatus.learning,
      );
      entries.add(entry);
      await _saveEntries(entries);
    }
  }

  Future<void> recordReview(
    int surahNumber,
    int ayahNumber, {
    required bool correct,
  }) async {
    final entries = await getMemorizationEntries();
    final index = entries.indexWhere(
      (e) => e.surahNumber == surahNumber && e.ayahNumber == ayahNumber,
    );

    if (index != -1) {
      final entry = entries[index];
      final newReviewCount = entry.reviewCount + 1;
      final newCorrectCount =
          correct ? entry.correctCount + 1 : entry.correctCount;
      final accuracy = newCorrectCount / newReviewCount;

      double newStrength = entry.strength;
      if (correct) {
        newStrength = (newStrength + 0.2).clamp(0.0, 1.0);
      } else {
        newStrength = (newStrength - 0.15).clamp(0.0, 1.0);
      }

      int daysUntilReview = _calculateNextReviewInterval(
        newStrength,
        newReviewCount,
      );
      final nextReview = DateTime.now().add(Duration(days: daysUntilReview));

      MemorizationStatus status = entry.status;
      if (newStrength >= 0.9 && accuracy >= 0.8) {
        status = MemorizationStatus.mastered;
      } else if (newStrength < 0.3) {
        status = MemorizationStatus.struggling;
      } else if (newReviewCount > 3) {
        status = MemorizationStatus.reviewing;
      }

      entries[index] = entry.copyWith(
        reviewCount: newReviewCount,
        correctCount: newCorrectCount,
        strength: newStrength,
        nextReview: nextReview,
        status: status,
        masteredDate:
            status == MemorizationStatus.mastered && entry.masteredDate == null
                ? DateTime.now()
                : entry.masteredDate,
      );

      await _saveEntries(entries);
    }
  }

  int _calculateNextReviewInterval(double strength, int reviewCount) {
    if (strength >= 0.9) {
      return [1, 3, 7, 14, 30, 60, 90][reviewCount.clamp(0, 6)];
    } else if (strength >= 0.7) {
      return [1, 2, 4, 7, 14, 30][reviewCount.clamp(0, 5)];
    } else if (strength >= 0.5) {
      return [1, 1, 2, 3, 7, 14][reviewCount.clamp(0, 5)];
    } else {
      return 1;
    }
  }

  Future<List<MemorizationEntry>> getDueForReview() async {
    final entries = await getMemorizationEntries();
    final now = DateTime.now();
    return entries.where((e) => e.nextReview.isBefore(now)).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final entries = await getMemorizationEntries();

    final total = entries.length;
    final mastered =
        entries.where((e) => e.status == MemorizationStatus.mastered).length;
    final learning =
        entries.where((e) => e.status == MemorizationStatus.learning).length;
    final reviewing =
        entries.where((e) => e.status == MemorizationStatus.reviewing).length;
    final struggling =
        entries.where((e) => e.status == MemorizationStatus.struggling).length;

    final avgStrength =
        entries.isEmpty
            ? 0.0
            : entries.map((e) => e.strength).reduce((a, b) => a + b) /
                entries.length;

    final dueToday =
        entries.where((e) {
          final now = DateTime.now();
          return e.nextReview.year == now.year &&
              e.nextReview.month == now.month &&
              e.nextReview.day == now.day;
        }).length;

    return {
      'total': total,
      'mastered': mastered,
      'learning': learning,
      'reviewing': reviewing,
      'struggling': struggling,
      'avgStrength': avgStrength,
      'dueToday': dueToday,
    };
  }

  Future<void> addNote(int surahNumber, int ayahNumber, String note) async {
    final entries = await getMemorizationEntries();
    final index = entries.indexWhere(
      (e) => e.surahNumber == surahNumber && e.ayahNumber == ayahNumber,
    );

    if (index != -1) {
      final entry = entries[index];
      final newNotes = [...entry.notes, note];
      entries[index] = entry.copyWith(notes: newNotes);
      await _saveEntries(entries);
    }
  }

  Future<void> _saveEntries(List<MemorizationEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _memorizationKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteEntry(int surahNumber, int ayahNumber) async {
    final entries = await getMemorizationEntries();
    entries.removeWhere(
      (e) => e.surahNumber == surahNumber && e.ayahNumber == ayahNumber,
    );
    await _saveEntries(entries);
  }
}
