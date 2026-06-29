import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/memorization.dart';
import '../models/surah.dart';
import '../states/quran_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final List<MemorizationEntry> entries;
  const QuizScreen({super.key, required this.entries});
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _correctCount = 0;
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadAyahs();
  }

  Future<void> _loadAyahs() async {
    final quranData = await ref.read(quranServiceProvider).getAllQuranText();
    final List<Ayah> ayahs = [];
    for (var entry in widget.entries) {
      final surahAyahs = quranData[entry.surahNumber];
      if (surahAyahs != null && entry.ayahNumber <= surahAyahs.length) {
        ayahs.add(
          Ayah(
            number: entry.ayahNumber,
            text: surahAyahs[entry.ayahNumber - 1],
            numberInSurah: entry.ayahNumber,
            surahNumber: entry.surahNumber,
          ),
        );
      }
    }
    setState(() {
      _ayahs = ayahs;
      _isLoading = false;
    });
  }

  void _handleAnswer(bool correct) async {
    if (correct) {
      _correctCount++;
    }
    final entry = widget.entries[_currentIndex];
    await ref
        .read(memorizationServiceProvider)
        .recordReview(entry.surahNumber, entry.ayahNumber, correct: correct);
    if (_currentIndex < widget.entries.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiz Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '$_correctCount / ${widget.entries.length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_correctCount / widget.entries.length * 100).toStringAsFixed(0)}% Correct',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_ayahs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No ayahs to review')),
      );
    }
    final currentAyah = _ayahs[_currentIndex];
    final surahs = ref.watch(surahListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${_currentIndex + 1}/${widget.entries.length}'),
      ),
      body: surahs.when(
        data: (surahList) {
          final surah = surahList.firstWhere(
            (s) => s.number == currentAyah.surahNumber,
          );
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.entries.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Recite:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${surah.englishName} ${currentAyah.surahNumber}:${currentAyah.numberInSurah}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() => _showAnswer = true);
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('Show Answer'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showAnswer) ...[
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          currentAyah.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Scheherazade',
                            fontSize: 28,
                            height: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _handleAnswer(false),
                          icon: const Icon(Icons.close),
                          label: const Text('Incorrect'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _handleAnswer(true),
                          icon: const Icon(Icons.check),
                          label: const Text('Correct'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
