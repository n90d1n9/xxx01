import 'package:flutter/material.dart';

import '../models/surah.dart';
import 'word_card.dart';

class WordByWordView extends StatelessWidget {
  final QuranPage page;
  final List<Surah> surahs;
  final double fontSize;
  final bool showTajweed;
  final Function(BuildContext, PageAyah, Surah) onAyahTap;
  const WordByWordView({
    super.key,
    required this.page,
    required this.surahs,
    required this.fontSize,
    required this.showTajweed,
    required this.onAyahTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          page.ayahs.map((ayah) {
            final surah = surahs.firstWhere(
              (s) => s.number == ayah.surahNumber,
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${ayah.ayahNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${surah.englishName} ${ayah.surahNumber}:${ayah.ayahNumber}',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 20),
                          onPressed: () => onAyahTap(context, ayah, surah),
                          tooltip: 'More details',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (ayah.wordByWord != null && ayah.wordByWord!.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        alignment: WrapAlignment.end,
                        children:
                            ayah.wordByWord!.map((word) {
                              return WordCard(
                                word: word,
                                fontSize: fontSize,
                                showTajweed: showTajweed,
                              );
                            }).toList(),
                      )
                    else
                      Column(
                        children: [
                          Text(
                            ayah.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Scheherazade',
                              fontSize: fontSize,
                              height: 2.0,
                            ),
                          ),
                          if (ayah.translation != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              ayah.translation!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize * 0.7,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Word-by-word data loading...',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
