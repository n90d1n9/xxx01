import 'package:flutter/material.dart';

import '../models/surah.dart';

class SurahHeader extends StatelessWidget {
  final Surah surah;
  const SurahHeader({super.key, required this.surah});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            style: const TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${surah.englishName} - ${surah.englishNameTranslation}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '${surah.revelationType} • ${surah.numberOfAyahs} Ayahs',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
