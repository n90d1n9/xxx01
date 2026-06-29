import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';
import '../widgets/ayah_details_sheet.dart';
import '../widgets/basmalah_widget.dart';
import '../widgets/continuous_ayah_widget.dart';
import '../widgets/surah_header.dart';

class SurahReadingScreen extends ConsumerStatefulWidget {
  final Surah surah;
  final int? initialAyah;
  const SurahReadingScreen({super.key, required this.surah, this.initialAyah});
  @override
  ConsumerState<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends ConsumerState<SurahReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTajweed = false;
  bool _showTranslation = true;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAyahDetails(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AyahDetailsSheet(
            ayah: PageAyah(
              surahNumber: ayah.surahNumber,
              ayahNumber: ayah.numberInSurah,
              text: ayah.text,
              translation: ayah.translation,
            ),
            surah: widget.surah,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(surahAyahsProvider(widget.surah.number));
    final prefsAsync = ref.watch(readingPreferencesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.englishName),
        actions: [
          IconButton(
            icon: Icon(_showTajweed ? Icons.palette : Icons.palette_outlined),
            onPressed: () {
              setState(() => _showTajweed = !_showTajweed);
            },
            tooltip: 'Toggle Tajweed',
          ),
          IconButton(
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.translate_outlined,
            ),
            onPressed: () {
              setState(() => _showTranslation = !_showTranslation);
            },
            tooltip: 'Toggle Translation',
          ),
        ],
      ),
      body: ayahsAsync.when(
        data:
            (ayahs) => prefsAsync.when(
              data:
                  (prefs) => ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: ayahs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            SurahHeader(surah: widget.surah),
                            const SizedBox(height: 16),
                            if (widget.surah.number != 1 &&
                                widget.surah.number != 9)
                              BasmalahWidget(fontSize: prefs.arabicFontSize),
                            const SizedBox(height: 8),
                          ],
                        );
                      }
                      final ayah = ayahs[index - 1];
                      return ContinuousAyahWidget(
                        ayah: ayah,
                        surah: widget.surah,
                        fontSize: prefs.arabicFontSize,
                        translationFontSize: prefs.translationFontSize,
                        showTajweed: _showTajweed,
                        showTranslation: _showTranslation,
                        onLongPress: () => _showAyahDetails(context, ayah),
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
