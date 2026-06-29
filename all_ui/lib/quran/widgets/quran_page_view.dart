import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';
import 'continuous_quran_text.dart';
import 'word_by_word_view.dart';
import 'surah_header.dart';
import 'basmalah_widget.dart';

class QuranPageView extends ConsumerWidget {
  final int pageNumber;
  final double fontSize;
  final bool showTajweed;
  final bool showTranslation;
  final bool showWordByWord;
  final List<Surah> surahs;
  final Function(BuildContext, PageAyah, Surah) onAyahLongPress;
  const QuranPageView({
    super.key,
    required this.pageNumber,
    required this.fontSize,
    required this.showTajweed,
    required this.showTranslation,
    required this.showWordByWord,
    required this.surahs,
    required this.onAyahLongPress,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(quranPageProvider(pageNumber));
    return pageAsync.when(
      data: (page) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${page.pageNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Juz ${page.juz}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (page.startingSurah != null) ...[
                SurahHeader(
                  surah: surahs.firstWhere(
                    (s) => s.number == page.startingSurah,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (page.showBasmalah) ...[
                BasmalahWidget(fontSize: fontSize),
                const SizedBox(height: 12),
              ],
              if (showWordByWord)
                WordByWordView(
                  page: page,
                  surahs: surahs,
                  fontSize: fontSize,
                  showTajweed: showTajweed,
                  onAyahTap: onAyahLongPress,
                )
              else
                ContinuousQuranText(
                  page: page,
                  surahs: surahs,
                  fontSize: fontSize,
                  showTajweed: showTajweed,
                  onAyahTap: onAyahLongPress,
                ),
              if (showTranslation && !showWordByWord) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Translation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...page.ayahs.map((ayah) {
                  if (ayah.translation == null) return const SizedBox.shrink();
                  final surah = surahs.firstWhere(
                    (s) => s.number == ayah.surahNumber,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${surah.englishName} ${ayah.surahNumber}:${ayah.ayahNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ayah.translation!,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: fontSize * 0.65,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(child: Text('Error loading page: $error')),
    );
  }
}
