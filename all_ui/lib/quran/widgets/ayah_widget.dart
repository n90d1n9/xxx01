import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';
import 'tajweed_text.dart';

class AyahWidget extends ConsumerStatefulWidget {
  final PageAyah ayah;
  final Surah surah;
  final double fontSize;
  final bool showTajweed;
  final bool showTranslation;
  final VoidCallback onLongPress;
  const AyahWidget({
    super.key,
    required this.ayah,
    required this.surah,
    required this.fontSize,
    required this.showTajweed,
    required this.showTranslation,
    required this.onLongPress,
  });
  @override
  ConsumerState<AyahWidget> createState() => _AyahWidgetState();
}

class _AyahWidgetState extends ConsumerState<AyahWidget> {
  bool _isBookmarked = false;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(12),
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
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.ayah.ayahNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.surah.englishName} ${widget.ayah.surahNumber}:${widget.ayah.ayahNumber}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (_isBookmarked)
                    Icon(
                      Icons.bookmark,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              widget.showTajweed
                  ? TajweedText(
                    text: widget.ayah.text,
                    fontSize: widget.fontSize,
                  )
                  : Text(
                    widget.ayah.text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: widget.fontSize,
                      height: 2.0,
                      letterSpacing: 0.5,
                    ),
                  ),
              if (widget.showTranslation &&
                  widget.ayah.translation != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  widget.ayah.translation!,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: widget.fontSize * 0.7,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
