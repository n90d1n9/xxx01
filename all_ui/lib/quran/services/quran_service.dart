// ==================== COMPLETE SERVICES IMPLEMENTATION ====================
// services/quran_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../models/surah.dart';

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  List<Surah>? _cachedSurahs;
  List<PageMetadata>? _cachedPageMetadata;
  Map<int, List<String>>? _cachedQuranText;
  Map<int, Map<int, String>>? _cachedTranslations;
  Map<int, List<Ayah>>? _cachedSurahAyahs;

  // Page to Juz mapping
  static const Map<int, int> _pageToJuz = {
    1: 1,
    22: 2,
    42: 3,
    62: 4,
    82: 5,
    102: 6,
    122: 7,
    142: 8,
    162: 9,
    182: 10,
    202: 11,
    222: 12,
    242: 13,
    262: 14,
    282: 15,
    302: 16,
    322: 17,
    342: 18,
    362: 19,
    382: 20,
    402: 21,
    422: 22,
    442: 23,
    462: 24,
    482: 25,
    502: 26,
    522: 27,
    542: 28,
    562: 29,
    582: 30,
  };

  Future<List<PageMetadata>> getPageMetadata() async {
    if (_cachedPageMetadata != null) return _cachedPageMetadata!;

    try {
      final String xmlString = await rootBundle.loadString(
        'assets/data/quran-data.xml',
      );
      final document = xml.XmlDocument.parse(xmlString);
      final pages = <PageMetadata>[];
      final pageElements = document.findAllElements('page');

      for (var element in pageElements) {
        pages.add(PageMetadata.fromXml(element));
      }

      _cachedPageMetadata = pages;
      return pages;
    } catch (e) {
      throw Exception('Failed to load page metadata: $e');
    }
  }

  Future<List<Surah>> getSurahsFromXml() async {
    if (_cachedSurahs != null) return _cachedSurahs!;

    try {
      final String xmlString = await rootBundle.loadString(
        'assets/data/quran-data.xml',
      );
      final document = xml.XmlDocument.parse(xmlString);
      final surahs = <Surah>[];
      final surahElements = document.findAllElements('sura');

      for (var element in surahElements) {
        surahs.add(Surah.fromXml(element));
      }

      _cachedSurahs = surahs;
      return surahs;
    } catch (e) {
      return getSurahsFromApi();
    }
  }

  Future<List<Surah>> getSurahsFromApi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahs = data['data'];
        return surahs.map((s) => Surah.fromJson(s)).toList();
      }
      throw Exception('Failed to load surahs');
    } catch (e) {
      throw Exception('Failed to load surahs: $e');
    }
  }

  Future<Map<int, List<String>>> getAllQuranText() async {
    if (_cachedQuranText != null) return _cachedQuranText!;

    try {
      final String quranText = await rootBundle.loadString(
        'assets/data/quran-uthmani.txt',
      );
      final lines = quranText.split('\n');
      final Map<int, List<String>> quranData = {};

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split('|');
        if (parts.length >= 3) {
          final surahNumber = int.parse(parts[0]);
          final ayahText = parts[2].trim();

          if (!quranData.containsKey(surahNumber)) {
            quranData[surahNumber] = [];
          }
          quranData[surahNumber]!.add(ayahText);
        }
      }

      _cachedQuranText = quranData;
      return quranData;
    } catch (e) {
      throw Exception('Failed to load Quran text: $e');
    }
  }

  Future<List<Ayah>> getSurahWithTranslation(
    int surahNumber,
    String edition,
    String reciter,
  ) async {
    final cacheKey = surahNumber * 1000 + edition.hashCode % 1000;
    if (_cachedSurahAyahs != null && _cachedSurahAyahs!.containsKey(cacheKey)) {
      return _cachedSurahAyahs![cacheKey]!;
    }

    try {
      final quranData = await getAllQuranText();
      final surahAyahs = quranData[surahNumber];
      if (surahAyahs == null) throw Exception('Surah not found');

      final arabicResponse = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$reciter'),
      );
      final translationResponse = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$edition'),
      );

      if (arabicResponse.statusCode == 200 &&
          translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);
        final List arabicAyahs = arabicData['data']['ayahs'];
        final List translationAyahs = translationData['data']['ayahs'];

        final ayahs = List.generate(surahAyahs.length, (i) {
          return Ayah(
            number: arabicAyahs[i]['number'],
            text: surahAyahs[i],
            numberInSurah: i + 1,
            surahNumber: surahNumber,
            translation: translationAyahs[i]['text'],
            audioUrl: arabicAyahs[i]['audio'],
          );
        });

        if (_cachedSurahAyahs == null) _cachedSurahAyahs = {};
        _cachedSurahAyahs![cacheKey] = ayahs;
        return ayahs;
      }
      throw Exception('Failed to load surah');
    } catch (e) {
      throw Exception('Failed to load surah: $e');
    }
  }

  Future<List<WordTranslation>> getWordByWord(
    int surahNumber,
    int ayahNumber,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.quran.com/api/v4/quran/words/$surahNumber:$ayahNumber?word_fields=text_uthmani,transliteration,translation',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List words = data['words'] ?? [];
        return words.map((word) => WordTranslation.fromJson(word)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<QuranPage> getPageByNumber(
    int pageNumber,
    String edition, {
    bool includeWordByWord = false,
  }) async {
    try {
      final pageMetadataList = await getPageMetadata();
      final quranData = await getAllQuranText();
      final surahs = await getSurahsFromXml();

      final currentPageMeta = pageMetadataList.firstWhere(
        (p) => p.pageNumber == pageNumber,
        orElse: () => PageMetadata(pageNumber: 1, startSurah: 1, startAyah: 1),
      );

      PageMetadata? nextPageMeta;
      if (pageNumber < 604) {
        try {
          nextPageMeta = pageMetadataList.firstWhere(
            (p) => p.pageNumber == pageNumber + 1,
          );
        } catch (e) {
          nextPageMeta = null;
        }
      }

      final List<PageAyah> pageAyahs = [];
      int currentSurah = currentPageMeta.startSurah;
      int currentAyah = currentPageMeta.startAyah;

      int? startingSurah;
      bool showBasmalah = false;

      if (currentPageMeta.startAyah == 1) {
        startingSurah = currentSurah;
        showBasmalah = currentSurah != 1 && currentSurah != 9;
      }

      bool reachedEnd = false;
      while (!reachedEnd) {
        final surahAyahs = quranData[currentSurah];
        if (surahAyahs == null) break;

        if (currentAyah <= surahAyahs.length) {
          final ayahText = surahAyahs[currentAyah - 1];
          String? translation;
          List<WordTranslation>? wordByWord;

          if (edition.isNotEmpty) {
            final translations = await _loadTranslationForSurah(
              currentSurah,
              edition,
            );
            translation = translations[currentAyah];
          }

          if (includeWordByWord) {
            wordByWord = await getWordByWord(currentSurah, currentAyah);
          }

          pageAyahs.add(
            PageAyah(
              surahNumber: currentSurah,
              ayahNumber: currentAyah,
              text: ayahText,
              translation: translation,
              wordByWord: wordByWord,
            ),
          );

          if (nextPageMeta != null) {
            if (currentSurah == nextPageMeta.startSurah &&
                currentAyah == nextPageMeta.startAyah - 1) {
              reachedEnd = true;
              break;
            }
          }

          currentAyah++;

          if (currentAyah > surahAyahs.length) {
            currentSurah++;
            currentAyah = 1;
            if (currentSurah > 114) {
              reachedEnd = true;
              break;
            }
          }
        } else {
          break;
        }
      }

      return QuranPage(
        pageNumber: pageNumber,
        ayahs: pageAyahs,
        juz: _getJuzForPage(pageNumber),
        startingSurah: startingSurah,
        showBasmalah: showBasmalah,
      );
    } catch (e) {
      throw Exception('Failed to load page: $e');
    }
  }

  Future<Map<int, String>> _loadTranslationForSurah(
    int surahNumber,
    String edition,
  ) async {
    if (_cachedTranslations == null) _cachedTranslations = {};

    final cacheKey = surahNumber * 1000 + edition.hashCode % 1000;
    if (_cachedTranslations!.containsKey(cacheKey)) {
      return _cachedTranslations![cacheKey]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$edition'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayahs = data['data']['ayahs'];
        final Map<int, String> translations = {};
        for (var ayah in ayahs) {
          translations[ayah['numberInSurah']] = ayah['text'];
        }
        _cachedTranslations![cacheKey] = translations;
        return translations;
      }
      throw Exception('Failed to load translation');
    } catch (e) {
      throw Exception('Failed to load translation: $e');
    }
  }

  int _getJuzForPage(int page) {
    int juz = 1;
    for (var entry in _pageToJuz.entries) {
      if (page >= entry.key) {
        juz = entry.value;
      } else {
        break;
      }
    }
    return juz;
  }

  Future<int> getPageForSurah(int surahNumber) async {
    final surahs = await getSurahsFromXml();
    final surah = surahs.firstWhere((s) => s.number == surahNumber);
    return surah.startPage;
  }

  Future<List<SearchResult>> searchQuran(String query, String edition) async {
    try {
      final quranData = await getAllQuranText();
      final List<SearchResult> results = [];
      final surahs = await getSurahsFromXml();
      final lowerQuery = query.toLowerCase();

      for (var entry in quranData.entries) {
        final surahNumber = entry.key;
        final surahAyahs = entry.value;
        final surah = surahs.firstWhere((s) => s.number == surahNumber);

        for (int i = 0; i < surahAyahs.length; i++) {
          final ayahText = surahAyahs[i];
          if (ayahText.toLowerCase().contains(lowerQuery)) {
            results.add(
              SearchResult(
                ayah: Ayah(
                  number: i + 1,
                  text: ayahText,
                  numberInSurah: i + 1,
                  surahNumber: surahNumber,
                ),
                surahName: surah.englishName,
              ),
            );
          }
        }
      }

      if (edition.isNotEmpty) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/search/$query/all/$edition'),
          );
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['data']['count'] > 0) {
              final List matches = data['data']['matches'];
              for (var match in matches) {
                final alreadyExists = results.any(
                  (r) =>
                      r.ayah.surahNumber == match['surah']['number'] &&
                      r.ayah.numberInSurah == match['numberInSurah'],
                );
                if (!alreadyExists) {
                  results.add(
                    SearchResult(
                      ayah: Ayah(
                        number: match['number'],
                        text: match['text'],
                        numberInSurah: match['numberInSurah'],
                        surahNumber: match['surah']['number'],
                      ),
                      surahName: match['surah']['englishName'],
                    ),
                  );
                }
              }
            }
          }
        } catch (e) {
          // Continue with Arabic results
        }
      }

      return results;
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}
