import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart' as xml;
import 'package:uuid/uuid.dart';

import '../models/surah.dart';
import '../states/quran_provider.dart';
import 'tajweed_text.dart';

class ContinuousAyahWidget extends ConsumerStatefulWidget {
  final Ayah ayah;
  final Surah surah;
  final double fontSize;
  final double translationFontSize;
  final bool showTajweed;
  final bool showTranslation;
  final VoidCallback onLongPress;
  const ContinuousAyahWidget({
    super.key,
    required this.ayah,
    required this.surah,
    required this.fontSize,
    required this.translationFontSize,
    required this.showTajweed,
    required this.showTranslation,
    required this.onLongPress,
  });
  @override
  ConsumerState<ContinuousAyahWidget> createState() =>
      _ContinuousAyahWidgetState();
}

class _ContinuousAyahWidgetState extends ConsumerState<ContinuousAyahWidget> {
  bool _isBookmarked = false;
  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await ref
        .read(bookmarkServiceProvider)
        .isBookmarked(widget.ayah.surahNumber, widget.ayah.numberInSurah);
    if (mounted) {
      setState(() => _isBookmarked = isBookmarked);
    }
  }

  Future<void> _playAyah() async {
    if (widget.ayah.audioUrl != null) {
      await ref
          .read(audioServiceProvider)
          .playAudioUrl(
            widget.ayah.audioUrl!,
            surahNumber: widget.ayah.surahNumber,
            ayahNumber: widget.ayah.numberInSurah,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioStateAsync = ref.watch(audioStateProvider);
    final isPlaying = audioStateAsync.when(
      data:
          (state) =>
              state.isPlaying &&
              state.currentSurah == widget.ayah.surahNumber &&
              state.currentAyah == widget.ayah.numberInSurah,
      loading: () => false,
      error: (_, __) => false,
    );

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
                      '${widget.ayah.numberInSurah}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  if (widget.ayah.audioUrl != null)
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed:
                          isPlaying
                              ? () {
                                ref.read(audioServiceProvider).pause();
                              }
                              : _playAyah,
                      tooltip: 'Play Audio',
                    ),
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
                    fontSize: widget.translationFontSize,
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
