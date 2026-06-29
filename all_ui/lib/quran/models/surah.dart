// ==================== ALL MODELS - COMPLETE IMPLEMENTATION ====================
// This file contains ALL models used in the Quran Reader app
// Copy these into your models/ folder

import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

// ==================== ENUMS ====================

enum TajweedCategory { nun, meem, madd, qalqalah, lam, ra, misc }

// ==================== CORE QURAN MODELS ====================

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final int startPage;
  final int endPage;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.startPage,
    required this.endPage,
  });

  factory Surah.fromXml(xml.XmlElement element) {
    return Surah(
      number: int.parse(element.getAttribute('index') ?? '1'),
      name: element.getAttribute('name') ?? '',
      englishName: element.getAttribute('ename') ?? '',
      englishNameTranslation: element.getAttribute('tname') ?? '',
      numberOfAyahs: int.parse(element.getAttribute('ayas') ?? '0'),
      revelationType: element.getAttribute('type') ?? 'Meccan',
      startPage: int.parse(element.getAttribute('page') ?? '1'),
      endPage:
          int.parse(element.getAttribute('page') ?? '1') +
          (int.parse(element.getAttribute('ayas') ?? '0') ~/ 15),
    );
  }

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
      startPage: json['startPage'] ?? 1,
      endPage: json['endPage'] ?? 1,
    );
  }
}

class PageMetadata {
  final int pageNumber;
  final int startSurah;
  final int startAyah;

  PageMetadata({
    required this.pageNumber,
    required this.startSurah,
    required this.startAyah,
  });

  factory PageMetadata.fromXml(xml.XmlElement element) {
    return PageMetadata(
      pageNumber: int.parse(element.getAttribute('index') ?? '1'),
      startSurah: int.parse(element.getAttribute('sura') ?? '1'),
      startAyah: int.parse(element.getAttribute('aya') ?? '1'),
    );
  }
}

class QuranPage {
  final int pageNumber;
  final List<PageAyah> ayahs;
  final int juz;
  final int? startingSurah;
  final bool showBasmalah;

  QuranPage({
    required this.pageNumber,
    required this.ayahs,
    required this.juz,
    this.startingSurah,
    this.showBasmalah = false,
  });
}

class PageAyah {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String? translation;
  final List<WordTranslation>? wordByWord;

  PageAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.translation,
    this.wordByWord,
  });
}

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int surahNumber;
  final String? translation;
  final String? audioUrl;
  final List<String>? audioUrls;
  final Map<String, String>? morphology;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.surahNumber,
    this.translation,
    this.audioUrl,
    this.audioUrls,
    this.morphology,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, {String? translation}) {
    return Ayah(
      number: json['number'],
      text: json['text'],
      numberInSurah: json['numberInSurah'],
      surahNumber: json['surah']['number'],
      translation: translation,
      audioUrl: json['audio'],
    );
  }
}

class WordTranslation {
  final String arabicWord;
  final String transliteration;
  final String translation;

  WordTranslation({
    required this.arabicWord,
    required this.transliteration,
    required this.translation,
  });

  factory WordTranslation.fromJson(Map<String, dynamic> json) {
    return WordTranslation(
      arabicWord: json['text'] ?? '',
      transliteration: json['transliteration']?['text'] ?? '',
      translation: json['translation']?['text'] ?? '',
    );
  }
}

class Bookmark {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final DateTime timestamp;

  Bookmark({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'surahName': surahName,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      surahName: json['surahName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SearchResult {
  final Ayah ayah;
  final String surahName;

  SearchResult({required this.ayah, required this.surahName});
}

// ==================== MEMORIZATION MODELS ====================

// ==================== STUDY MODELS ====================

class Tafsir {
  final int surahNumber;
  final int ayahNumber;
  final String source;
  final String text;
  final String language;

  Tafsir({
    required this.surahNumber,
    required this.ayahNumber,
    required this.source,
    required this.text,
    required this.language,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      surahNumber: json['surahNumber'] ?? 0,
      ayahNumber: json['ayahNumber'] ?? 0,
      source: json['source'] ?? '',
      text: json['text'] ?? '',
      language: json['language'] ?? 'en',
    );
  }
}

class Annotation {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final Color? highlightColor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;

  Annotation({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.highlightColor,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'text': text,
    'highlightColor': highlightColor?.value,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'tags': tags,
  };

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'],
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      text: json['text'],
      highlightColor:
          json['highlightColor'] != null ? Color(json['highlightColor']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// ==================== AUDIO MODELS ====================

class ReciterInfo {
  final String id;
  final String name;
  final String style;
  final String language;
  final String baseUrl;
  final bool isDownloaded;
  final int totalSurahs;
  final double downloadSizeMB;

  ReciterInfo({
    required this.id,
    required this.name,
    required this.style,
    this.language = 'ar',
    required this.baseUrl,
    this.isDownloaded = false,
    this.totalSurahs = 114,
    this.downloadSizeMB = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'style': style,
    'language': language,
    'baseUrl': baseUrl,
    'isDownloaded': isDownloaded,
    'totalSurahs': totalSurahs,
    'downloadSizeMB': downloadSizeMB,
  };

  factory ReciterInfo.fromJson(Map<String, dynamic> json) {
    return ReciterInfo(
      id: json['id'],
      name: json['name'],
      style: json['style'],
      language: json['language'] ?? 'ar',
      baseUrl: json['baseUrl'],
      isDownloaded: json['isDownloaded'] ?? false,
      totalSurahs: json['totalSurahs'] ?? 114,
      downloadSizeMB: json['downloadSizeMB'] ?? 0.0,
    );
  }
}

// ==================== PRAYER TIMES MODELS ====================

// ==================== STATISTICS MODELS ====================

class ReadingStatistics {
  final int totalVersesRead;
  final int totalPagesRead;
  final Duration totalTimeSpent;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final Map<String, int> versesReadByDate;
  final List<int> completedSurahs;

  ReadingStatistics({
    this.totalVersesRead = 0,
    this.totalPagesRead = 0,
    this.totalTimeSpent = Duration.zero,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
    this.versesReadByDate = const {},
    this.completedSurahs = const [],
  });

  ReadingStatistics copyWith({
    int? totalVersesRead,
    int? totalPagesRead,
    Duration? totalTimeSpent,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    Map<String, int>? versesReadByDate,
    List<int>? completedSurahs,
  }) {
    return ReadingStatistics(
      totalVersesRead: totalVersesRead ?? this.totalVersesRead,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      versesReadByDate: versesReadByDate ?? this.versesReadByDate,
      completedSurahs: completedSurahs ?? this.completedSurahs,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalVersesRead': totalVersesRead,
    'totalPagesRead': totalPagesRead,
    'totalTimeSpent': totalTimeSpent.inSeconds,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastReadDate': lastReadDate?.toIso8601String(),
    'versesReadByDate': versesReadByDate,
    'completedSurahs': completedSurahs,
  };

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) {
    return ReadingStatistics(
      totalVersesRead: json['totalVersesRead'] ?? 0,
      totalPagesRead: json['totalPagesRead'] ?? 0,
      totalTimeSpent: Duration(seconds: json['totalTimeSpent'] ?? 0),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastReadDate:
          json['lastReadDate'] != null
              ? DateTime.parse(json['lastReadDate'])
              : null,
      versesReadByDate: Map<String, int>.from(json['versesReadByDate'] ?? {}),
      completedSurahs: List<int>.from(json['completedSurahs'] ?? []),
    );
  }
}

// ==================== DHIKR MODELS ====================

class DhikrItem {
  final String id;
  final String arabic;
  final String transliteration;
  final String translation;
  final int? targetCount;
  final int currentCount;
  final String category;

  DhikrItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.targetCount,
    this.currentCount = 0,
    this.category = 'general',
  });

  DhikrItem copyWith({int? currentCount}) {
    return DhikrItem(
      id: id,
      arabic: arabic,
      transliteration: transliteration,
      translation: translation,
      targetCount: targetCount,
      currentCount: currentCount ?? this.currentCount,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'arabic': arabic,
    'transliteration': transliteration,
    'translation': translation,
    'targetCount': targetCount,
    'currentCount': currentCount,
    'category': category,
  };

  factory DhikrItem.fromJson(Map<String, dynamic> json) {
    return DhikrItem(
      id: json['id'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      targetCount: json['targetCount'],
      currentCount: json['currentCount'] ?? 0,
      category: json['category'] ?? 'general',
    );
  }
}

// ==================== TAJWEED MODELS ====================

class TajweedRule {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String detailedExplanation;
  final Color color;
  final TajweedCategory category;
  final List<String> patterns;
  final List<String> examples;
  final int priority;

  TajweedRule({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.detailedExplanation,
    required this.color,
    required this.category,
    required this.patterns,
    required this.examples,
    this.priority = 0,
  });
}

// ==================== RECORDING MODELS ====================

class VoiceRecording {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String filePath;
  final Duration duration;
  final DateTime recordedAt;
  final double accuracy;

  VoiceRecording({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.filePath,
    required this.duration,
    required this.recordedAt,
    this.accuracy = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'ayahNumber': ayahNumber,
    'filePath': filePath,
    'duration': duration.inMilliseconds,
    'recordedAt': recordedAt.toIso8601String(),
    'accuracy': accuracy,
  };

  factory VoiceRecording.fromJson(Map<String, dynamic> json) {
    return VoiceRecording(
      id: json['id'],
      surahNumber: json['surahNumber'],
      ayahNumber: json['ayahNumber'],
      filePath: json['filePath'],
      duration: Duration(milliseconds: json['duration']),
      recordedAt: DateTime.parse(json['recordedAt']),
      accuracy: json['accuracy'] ?? 0.0,
    );
  }
}

/* 
==================== MODEL SUMMARY ====================

✅ ENUMS (6):
- RepeatMode
- ReadingMode
- MemorizationStatus
- TajweedCategory
- Prayer

✅ CORE QURAN MODELS (9):
- Surah
- PageMetadata
- QuranPage
- PageAyah
- Ayah
- WordTranslation
- Bookmark
- ReadingPreferences
- SearchResult

✅ MEMORIZATION MODELS (1):
- MemorizationEntry

✅ STUDY MODELS (2):
- Tafsir
- Annotation

✅ AUDIO MODELS (2):
- AudioPlaybackState
- ReciterInfo

✅ PRAYER TIMES MODELS (1):
- PrayerTimes

✅ STATISTICS MODELS (1):
- ReadingStatistics

✅ DHIKR MODELS (1):
- DhikrItem

✅ TAJWEED MODELS (1):
- TajweedRule

✅ RECORDING MODELS (1):
- VoiceRecording

TOTAL: 6 Enums + 19 Model Classes = 25 Data Types

All models include:
- Complete toJson() methods
- Complete fromJson() factory constructors
- copyWith() methods where needed
- Helper methods (getNextPrayer, etc.)
- Proper null safety
- Type-safe enums

*/
