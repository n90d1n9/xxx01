// ==================== COMPLETE PROVIDERS IMPLEMENTATION ====================
// providers/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/audio_playback.dart';
import '../models/memorization.dart';
import '../models/prayer.dart';
import '../models/reading_preferences.dart';
import '../models/surah.dart';
import '../services/audio_service.dart';
import '../services/bookmark_service.dart';
import '../services/dziker_service.dart';
import '../services/memorization_service.dart';
import '../services/prayer_time_service.dart';
import '../services/preferences_service.dart';
import '../services/quran_service.dart';
import '../services/reciter_management_service.dart';
import '../services/statistic_service.dart';
import '../services/study_service.dart';

// ==================== SERVICE PROVIDERS (10) ====================

final quranServiceProvider = Provider<QuranService>((ref) {
  return QuranService();
});

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final memorizationServiceProvider = Provider<MemorizationService>((ref) {
  return MemorizationService();
});

final studyServiceProvider = Provider<StudyService>((ref) {
  return StudyService();
});

final prayerTimesServiceProvider = Provider<PrayerTimesService>((ref) {
  return PrayerTimesService();
});

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});

final reciterManagementServiceProvider = Provider<ReciterManagementService>((
  ref,
) {
  return ReciterManagementService();
});

final dhikrServiceProvider = Provider<DhikrService>((ref) {
  return DhikrService();
});

// ==================== STATE PROVIDERS (8) ====================

// Selected translation ID (e.g., 'en.sahih', 'en.pickthall')
final selectedTranslationProvider = StateProvider<String>((ref) {
  return 'en.sahih';
});

// Toggle translation visibility
final showTranslationProvider = StateProvider<bool>((ref) {
  return true;
});

// Toggle word-by-word translation
final showWordByWordProvider = StateProvider<bool>((ref) {
  return false;
});

// Search query text
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Currently playing ayah (surahNumber, ayahNumber)
final currentPlayingAyahProvider = StateProvider<(int, int)?>((ref) {
  return null;
});

// Current page number in page-by-page mode
final currentPageProvider = StateProvider<int>((ref) {
  return 1;
});

// Selected Juz (1-30)
final selectedJuzProvider = StateProvider<int>((ref) {
  return 1;
});

// Theme mode
final themeModeProvider = StateProvider<bool>((ref) {
  // true = dark mode, false = light mode
  return false;
});

// ==================== FUTURE PROVIDERS (15) ====================

// Get all Surahs
final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final service = ref.watch(quranServiceProvider);
  return await service.getSurahsFromApi();
});

// Get reading preferences
final readingPreferencesProvider = FutureProvider<ReadingPreferences>((
  ref,
) async {
  final service = ref.watch(preferencesServiceProvider);
  return await service.getPreferences();
});

// Get Surah with ayahs (family provider)
final surahAyahsProvider = FutureProvider.family<List<Ayah>, int>((
  ref,
  surahNumber,
) async {
  final service = ref.watch(quranServiceProvider);
  final translationId = ref.watch(selectedTranslationProvider);
  final reciterInfo = await ref.watch(selectedReciterProvider.future);
  return await service.getSurahWithTranslation(
    surahNumber,
    translationId,
    reciterInfo.id,
  );
});

// Get Quran page (family provider)
final quranPageProvider = FutureProvider.family<QuranPage, int>((
  ref,
  pageNumber,
) async {
  final service = ref.watch(quranServiceProvider);
  final translationId = ref.watch(selectedTranslationProvider);
  return await service.getPageByNumber(pageNumber, translationId);
});

// Get all bookmarks
final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final service = ref.watch(bookmarkServiceProvider);
  return await service.getBookmarks();
});

// Get last read position
final lastReadPositionProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final service = ref.watch(bookmarkServiceProvider);
  return await service.getLastReadPosition();
});

// Search results based on query
final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final service = ref.watch(quranServiceProvider);
  final edition = ref.watch(selectedTranslationProvider);
  return await service.searchQuran(query, edition);
});

// Get memorization entries
final memorizationEntriesProvider = FutureProvider<List<MemorizationEntry>>((
  ref,
) async {
  final service = ref.watch(memorizationServiceProvider);
  return await service.getMemorizationEntries();
});

// Get memorization statistics
final memorizationStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(memorizationServiceProvider);
  return await service.getStatistics();
});

// Get due reviews
final dueReviewsProvider = FutureProvider<List<MemorizationEntry>>((ref) async {
  final service = ref.watch(memorizationServiceProvider);
  return await service.getDueForReview();
});

// Get all annotations
final annotationsProvider = FutureProvider<List<Annotation>>((ref) async {
  final service = ref.watch(studyServiceProvider);
  return await service.getAnnotations();
});

// Get tafsir for specific ayah (family provider)
final tafsirProvider = FutureProvider.family<Tafsir, (int, int)>((
  ref,
  params,
) async {
  final (surahNumber, ayahNumber) = params;
  final service = ref.watch(studyServiceProvider);
  final tafsirs = await service.getTafsir(surahNumber, ayahNumber);

  if (tafsirs.isNotEmpty) {
    return tafsirs.first;
  }

  throw Exception('Tafsir not found');
});

// Get annotations for specific ayah (family provider)
final ayahAnnotationsProvider =
    FutureProvider.family<List<Annotation>, (int, int)>((ref, params) async {
      final (surahNumber, ayahNumber) = params;
      final service = ref.watch(studyServiceProvider);
      return await service.getAnnotationsForAyah(surahNumber, ayahNumber);
    });

// Get prayer times
final prayerTimesProvider = FutureProvider<PrayerTimes?>((ref) async {
  final service = ref.watch(prayerTimesServiceProvider);
  final location = await service.getSavedLocation();

  if (location == null) return null;

  return await service.getPrayerTimes(
    latitude: location['latitude']!,
    longitude: location['longitude']!,
  );
});

// Get reading statistics
final readingStatisticsProvider = FutureProvider<ReadingStatistics>((
  ref,
) async {
  final service = ref.watch(statisticsServiceProvider);
  return await service.getStatistics();
});

// Get selected reciter

// Get selected reciter
final selectedReciterProvider = FutureProvider<ReciterInfo>((ref) async {
  final service = ref.watch(reciterManagementServiceProvider);
  final reciterId = await service.getSelectedReciter();
  final availableReciters = service.getAvailableReciters();

  return availableReciters.firstWhere(
    (r) => r.id == reciterId,
    orElse: () => availableReciters.first,
  );
});

// Get dhikr counts
final dhikrCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(dhikrServiceProvider);
  return await service.getDhikrCounts();
});

// ==================== STREAM PROVIDERS (2) ====================

// Audio playback state stream
final audioStateProvider = StreamProvider<AudioPlaybackState>((ref) {
  final service = ref.watch(audioServiceProvider);
  return service.stateStream;
});

// Note: Location stream would require geolocator package
// Placeholder for now
final locationStreamProvider = StreamProvider<Map<String, double>?>((
  ref,
) async* {
  // This would use geolocator package in production
  final service = ref.watch(prayerTimesServiceProvider);
  final location = await service.getSavedLocation();

  if (location != null) {
    yield {
      'latitude': location['latitude']!,
      'longitude': location['longitude']!,
    };
  } else {
    yield null;
  }
});

// ==================== COMPUTED/DERIVED PROVIDERS (8) ====================

// Get next prayer
final nextPrayerProvider = Provider<Prayer?>((ref) {
  final prayerTimesAsync = ref.watch(prayerTimesProvider);

  return prayerTimesAsync.when(
    data: (times) => times?.getNextPrayer(),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Get time until next prayer
final timeUntilNextPrayerProvider = Provider<Duration?>((ref) {
  final prayerTimesAsync = ref.watch(prayerTimesProvider);

  return prayerTimesAsync.when(
    data: (times) => times?.getTimeUntilNext(),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Get available reciters
final availableRecitersProvider = Provider<List<ReciterInfo>>((ref) {
  final service = ref.watch(reciterManagementServiceProvider);
  return service.getAvailableReciters();
});

// Get dhikr list with counts
final dhikrListProvider = Provider<List<DhikrItem>>((ref) {
  final service = ref.watch(dhikrServiceProvider);
  final countsAsync = ref.watch(dhikrCountsProvider);

  return countsAsync.when(
    data: (counts) {
      return service.getPredefinedDhikr().map((dhikr) {
        return dhikr.copyWith(currentCount: counts[dhikr.id] ?? 0);
      }).toList();
    },
    loading: () => service.getPredefinedDhikr(),
    error: (_, __) => service.getPredefinedDhikr(),
  );
});

// Filtered surahs based on search
final filteredSurahsProvider = Provider<List<Surah>>((ref) {
  final surahsAsync = ref.watch(surahListProvider);
  final query = ref.watch(searchQueryProvider);

  return surahsAsync.when(
    data: (surahs) {
      if (query.isEmpty) return surahs;

      return surahs.where((surah) {
        return surah.name.contains(query) ||
            surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
            surah.englishNameTranslation.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            surah.number.toString() == query;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Current streak
final currentStreakProvider = Provider<int>((ref) {
  final statsAsync = ref.watch(readingStatisticsProvider);

  return statsAsync.when(
    data: (stats) => stats.currentStreak,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Today's progress (verses read today)
final todayProgressProvider = Provider<int>((ref) {
  final statsAsync = ref.watch(readingStatisticsProvider);

  return statsAsync.when(
    data: (stats) {
      final today = DateTime.now();
      final key =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return stats.versesReadByDate[key] ?? 0;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Memorized ayahs count
final memorizedAyahsCountProvider = Provider<int>((ref) {
  final statsAsync = ref.watch(memorizationStatsProvider);

  return statsAsync.when(
    data: (stats) => stats['mastered'] ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// ==================== HELPER PROVIDERS ====================

// Check if ayah is bookmarked (family provider)
final isBookmarkedProvider = FutureProvider.family<bool, (int, int)>((
  ref,
  params,
) async {
  final (surahNumber, ayahNumber) = params;
  final service = ref.watch(bookmarkServiceProvider);
  return await service.isBookmarked(surahNumber, ayahNumber);
});

// Get word by word for ayah (family provider)
final wordByWordProvider =
    FutureProvider.family<List<WordTranslation>, (int, int)>((
      ref,
      params,
    ) async {
      final (surahNumber, ayahNumber) = params;
      final service = ref.watch(quranServiceProvider);
      return await service.getWordByWord(surahNumber, ayahNumber);
    });

// Get specific surah info (family provider)
final surahInfoProvider = FutureProvider.family<Surah?, int>((
  ref,
  surahNumber,
) async {
  final surahsAsync = ref.watch(surahListProvider);

  return surahsAsync.when(
    data:
        (surahs) => surahs.firstWhere(
          (s) => s.number == surahNumber,
          orElse: () => surahs.first,
        ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Get weekly statistics
final weeklyStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(statisticsServiceProvider);
  return await service.getWeeklyStats();
});

// Get monthly statistics
final monthlyStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(statisticsServiceProvider);
  return await service.getMonthlyStats();
});
