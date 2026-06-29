import 'package:flutter/material.dart';

import '../models/surah.dart';
import 'tajweed_text.dart';

class WordCard extends StatelessWidget {
  final WordTranslation word;
  final double fontSize;
  final bool showTajweed;
  const WordCard({
    super.key,
    required this.word,
    required this.fontSize,
    required this.showTajweed,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showTajweed
              ? TajweedText(
                text: word.arabicWord,
                fontSize: fontSize,
                inline: true,
              )
              : Text(
                word.arabicWord,
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
          const SizedBox(height: 8),
          if (word.transliteration.isNotEmpty)
            Text(
              word.transliteration,
              style: TextStyle(
                fontSize: fontSize * 0.5,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),
          if (word.translation.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                word.translation,
                style: TextStyle(
                  fontSize: fontSize * 0.55,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
