import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';
import 'tajweed_rules_section.dart';
import 'word_card.dart';

class AyahDetailsSheet extends ConsumerStatefulWidget {
  final PageAyah ayah;
  final Surah surah;
  const AyahDetailsSheet({super.key, required this.ayah, required this.surah});
  @override
  ConsumerState<AyahDetailsSheet> createState() => _AyahDetailsSheetState();
}

class _AyahDetailsSheetState extends ConsumerState<AyahDetailsSheet> {
  bool _isBookmarked = false;
  bool _isPlaying = false;
  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await ref
        .read(bookmarkServiceProvider)
        .isBookmarked(widget.ayah.surahNumber, widget.ayah.ayahNumber);
    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await ref
          .read(bookmarkServiceProvider)
          .removeBookmark(widget.ayah.surahNumber, widget.ayah.ayahNumber);
    } else {
      await ref
          .read(bookmarkServiceProvider)
          .addBookmark(
            Bookmark(
              surahNumber: widget.ayah.surahNumber,
              ayahNumber: widget.ayah.ayahNumber,
              surahName: widget.surah.englishName,
              timestamp: DateTime.now(),
            ),
          );
    }
    setState(() => _isBookmarked = !_isBookmarked);
    ref.invalidate(bookmarksProvider);
  }

  Future<void> _shareAyah() async {
    final text = '''
${widget.ayah.text}

${widget.ayah.translation ?? ''}

— ${widget.surah.englishName} ${widget.ayah.surahNumber}:${widget.ayah.ayahNumber}
    ''';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.surah.englishName} ${widget.ayah.surahNumber}:${widget.ayah.ayahNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.surah.name,
                  style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.ayah.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: 28,
                      height: 2.0,
                    ),
                  ),
                ),
                if (widget.ayah.translation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Translation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.ayah.translation!,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleBookmark,
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      ),
                      label: Text(_isBookmarked ? 'Bookmarked' : 'Bookmark'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _shareAyah,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                '${widget.ayah.text}\n\n${widget.ayah.translation ?? ''}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                if (widget.ayah.wordByWord != null &&
                    widget.ayah.wordByWord!.isNotEmpty) ...[
                  Text(
                    'Word by Word Analysis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.end,
                    children:
                        widget.ayah.wordByWord!.map((word) {
                          return WordCard(
                            word: word,
                            fontSize: 20,
                            showTajweed: false,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
                TajweedRulesSection(text: widget.ayah.text),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'References & Resources',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildReferenceLink(
                  context,
                  'Tafsir Ibn Kathir',
                  'https://quran.com/${widget.ayah.surahNumber}/${widget.ayah.ayahNumber}',
                  Icons.book,
                ),
                _buildReferenceLink(
                  context,
                  'Related Hadith',
                  'https://sunnah.com',
                  Icons.menu_book,
                ),
                _buildReferenceLink(
                  context,
                  'Word by Word',
                  'https://corpus.quran.com/wordbyword.jsp?chapter=${widget.ayah.surahNumber}&verse=${widget.ayah.ayahNumber}',
                  Icons.translate,
                ),
                _buildReferenceLink(
                  context,
                  'Tafsir al-Jalalayn',
                  'https://quran.com/${widget.ayah.surahNumber}/${widget.ayah.ayahNumber}/tafsirs/en-tafisr-al-jalalayn',
                  Icons.book_outlined,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReferenceLink(
    BuildContext context,
    String title,
    String url,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Opening $title...')));
        },
      ),
    );
  }
}
