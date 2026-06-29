import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/surah.dart';

class DhikrService {
  static const String _dhikrKey = 'dhikr_counts';

  static final List<DhikrItem> _predefinedDhikr = [
    DhikrItem(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'Subhan Allah',
      translation: 'Glory be to Allah',
      targetCount: 33,
      category: 'tasbih',
    ),
    DhikrItem(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      translation: 'Praise be to Allah',
      targetCount: 33,
      category: 'tasbih',
    ),
    DhikrItem(
      id: 'allahuakbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      targetCount: 34,
      category: 'tasbih',
    ),
    DhikrItem(
      id: 'lailahaillallah',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illallah',
      translation: 'There is no god but Allah',
      targetCount: 100,
      category: 'tahlil',
    ),
    DhikrItem(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      translation: 'I seek forgiveness from Allah',
      targetCount: 100,
      category: 'istighfar',
    ),
  ];

  List<DhikrItem> getPredefinedDhikr() {
    return _predefinedDhikr;
  }

  Future<Map<String, int>> getDhikrCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final countsJson = prefs.getString(_dhikrKey);
    if (countsJson == null) return {};
    return Map<String, int>.from(json.decode(countsJson));
  }

  Future<void> incrementDhikr(String dhikrId) async {
    final counts = await getDhikrCounts();
    counts[dhikrId] = (counts[dhikrId] ?? 0) + 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dhikrKey, json.encode(counts));
  }

  Future<void> resetDhikr(String dhikrId) async {
    final counts = await getDhikrCounts();
    counts[dhikrId] = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dhikrKey, json.encode(counts));
  }

  Future<void> resetAllDhikr() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dhikrKey, json.encode({}));
  }
}
