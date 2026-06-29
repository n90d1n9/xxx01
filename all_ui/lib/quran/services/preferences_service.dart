import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_mode.dart';
import '../models/reading_preferences.dart';

class PreferencesService {
  static const String _preferencesKey = 'reading_preferences';

  Future<ReadingPreferences> getPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_preferencesKey);
      if (json != null) {
        return ReadingPreferences.fromJson(jsonDecode(json));
      }
      return ReadingPreferences();
    } catch (e) {
      return ReadingPreferences();
    }
  }

  Future<void> savePreferences(ReadingPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
    } catch (e) {
      throw Exception('Failed to save preferences: $e');
    }
  }

  Future<void> updateArabicFontSize(double size) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(arabicFontSize: size));
  }

  Future<void> updateTranslationFontSize(double size) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(translationFontSize: size));
  }

  Future<void> updateReciter(String reciterId) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(reciter: reciterId));
  }

  Future<void> updateReadingMode(ReadingMode mode) async {
    final prefs = await getPreferences();
    await savePreferences(prefs.copyWith(readingMode: mode));
  }

  Future<void> resetToDefaults() async {
    await savePreferences(ReadingPreferences());
  }
}
