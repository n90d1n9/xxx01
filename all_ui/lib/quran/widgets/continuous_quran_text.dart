import 'package:flutter/material.dart';

import '../models/surah.dart';
import 'tajweed_text.dart';

class ContinuousQuranText extends StatelessWidget {
  final QuranPage page;
  final List<Surah> surahs;
  final double fontSize;
  final bool showTajweed;
  final Function(BuildContext, PageAyah, Surah) onAyahTap;
  const ContinuousQuranText({
    super.key,
    required this.page,
    required this.surahs,
    required this.fontSize,
    required this.showTajweed,
    required this.onAyahTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 8,
            children: _buildInlineAyahs(context),
          );
        },
      ),
    );
  }

  List<Widget> _buildInlineAyahs(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < page.ayahs.length; i++) {
      final ayah = page.ayahs[i];
      final surah = surahs.firstWhere((s) => s.number == ayah.surahNumber);
      widgets.add(
        InkWell(
          onLongPress: () => onAyahTap(context, ayah, surah),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child:
                showTajweed
                    ? TajweedText(
                      text: ayah.text,
                      fontSize: fontSize,
                      inline: true,
                    )
                    : Text(
                      ayah.text,
                      style: TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: fontSize,
                        height: 2.0,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),
      );
      widgets.add(
        InkWell(
          onLongPress: () => onAyahTap(context, ayah, surah),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _convertToArabicNumber(ayah.ayahNumber),
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: fontSize * 0.7,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      if (i < page.ayahs.length - 1) {
        widgets.add(SizedBox(width: fontSize * 0.3));
      }
    }
    return widgets;
  }

  String _convertToArabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicNumbers[int.parse(digit)])
        .join();
  }
}
