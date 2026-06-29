import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/surah.dart';
import '../states/quran_provider.dart';
import '../widgets/ayah_details_sheet.dart';
import '../widgets/page_jump_dialog.dart';
import '../widgets/quran_page_view.dart';

class QuranPageScreen extends ConsumerStatefulWidget {
  final int initialPage;
  final int? initialAyah;
  const QuranPageScreen({
    super.key,
    required this.initialPage,
    this.initialAyah,
  });
  @override
  ConsumerState<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends ConsumerState<QuranPageScreen> {
  late PageController _pageController;
  late int _currentPage;
  double _fontSize = 24.0;
  bool _showTajweed = false;
  bool _showTranslation = true;
  bool _showWordByWord = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAyahDetails(BuildContext context, PageAyah ayah, Surah surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahDetailsSheet(ayah: ayah, surah: surah),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Page $_currentPage'),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'word_by_word') {
                setState(() {
                  _showWordByWord = !_showWordByWord;
                  ref.read(showWordByWordProvider.notifier).state =
                      _showWordByWord;
                });
              } else if (value == 'jump') {
                showDialog(
                  context: context,
                  builder: (context) => const PageJumpDialog(),
                ).then((page) {
                  if (page != null && page >= 1 && page <= 604) {
                    _pageController.jumpToPage(page - 1);
                    setState(() => _currentPage = page);
                  }
                });
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'word_by_word',
                    child: Row(
                      children: [
                        Icon(
                          _showWordByWord
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text('Word by Word'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'jump',
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 20),
                        SizedBox(width: 12),
                        Text('Jump to Page'),
                      ],
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() => _fontSize = (_fontSize + 2).clamp(16.0, 36.0));
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() => _fontSize = (_fontSize - 2).clamp(16.0, 36.0));
            },
          ),
        ],
      ),
      body: surahsAsync.when(
        data:
            (surahs) => PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index + 1);
              },
              itemCount: 604,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                return QuranPageView(
                  pageNumber: pageNumber,
                  fontSize: _fontSize,
                  showTajweed: _showTajweed,
                  showTranslation: _showTranslation,
                  showWordByWord: _showWordByWord,
                  surahs: surahs,
                  onAyahLongPress: _showAyahDetails,
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: () {
                _pageController.jumpToPage(0);
              },
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  _currentPage > 1
                      ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      : null,
            ),
            Text(
              'Page $_currentPage of 604',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _currentPage < 604
                      ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: () {
                _pageController.jumpToPage(603);
              },
              tooltip: 'Last Page',
            ),
          ],
        ),
      ),
    );
  }
}
