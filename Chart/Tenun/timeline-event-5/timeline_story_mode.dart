// TimelineStoryMode — scroll-driven narrative tour engine.
//
// Transforms the timeline into a guided, chapter-by-chapter experience.
// The user (or an auto-advance timer) steps through a curated sequence of
// events. Each step:
//   1. Animates the viewport to center the target event.
//   2. Typewriter-reveals the event title and description.
//   3. Shows a chapter header overlay with a parallax background.
//   4. Optionally auto-advances after a configurable dwell time.
//
// Architecture:
//
//   TimelineStoryScript          — ordered list of StoryChapter
//   StoryChapter                 — event reference + narrative text + dwell
//   TimelineStoryController      — drives the TickerProvider + scroll + text reveal
//   TimelineStoryOverlay         — the full-screen chapter card widget
//   TimelineStoryProgressBar     — thin indicator bar (like Instagram stories)
//   TimelineTypewriterText       — character-by-character animated text widget
//   TimelineStoryControls        — prev / pause / next / exit buttons
//
// Usage:
//   final script = TimelineStoryScript.fromHighlights(config.events);
//   // or build manually:
//   final script = TimelineStoryScript(chapters: [
//     StoryChapter(event: romeEvent, narrative: 'The empire that shaped the West…'),
//     StoryChapter(event: renaissanceEvent, dwell: Duration(seconds: 6)),
//   ]);
//
//   TimelineStoryController ctrl = TimelineStoryController(
//     script: script,
//     scrollController: chartScrollCtrl,
//   )..attach(tickerProvider);
//
//   // In your Stack:
//   TimelineStoryOverlay(controller: ctrl, isDark: isDark)

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'timeline_event.dart';
import 'timeline_physics.dart';

// ---------------------------------------------------------------------------
// StoryChapter
// ---------------------------------------------------------------------------

class StoryChapter {
  /// The event this chapter focuses on.
  final TimelineEvent event;

  /// Optional override narrative text (falls back to event.description).
  final String? narrative;

  /// Optional chapter title override (falls back to event.title).
  final String? chapterTitle;

  /// How long to dwell on this chapter in auto-advance mode.
  final Duration dwell;

  /// Zoom level when viewing this chapter (null = auto-fit).
  final double? zoom;

  /// Optional background image URL for the chapter header.
  final String? backgroundImageUrl;

  const StoryChapter({
    required this.event,
    this.narrative,
    this.chapterTitle,
    this.dwell = const Duration(seconds: 5),
    this.zoom,
    this.backgroundImageUrl,
  });

  String get displayTitle => chapterTitle ?? event.title;
  String get displayNarrative => narrative ?? event.description;
}

// ---------------------------------------------------------------------------
// TimelineStoryScript
// ---------------------------------------------------------------------------

class TimelineStoryScript {
  final List<StoryChapter> chapters;
  final String? title;
  final String? subtitle;

  const TimelineStoryScript({
    required this.chapters,
    this.title,
    this.subtitle,
  });

  int get length => chapters.length;
  bool get isEmpty => chapters.isEmpty;

  /// Auto-generate script from all highlight events, sorted by year.
  factory TimelineStoryScript.fromHighlights(
    List<TimelineEvent> events, {
    String? title,
    Duration dwell = const Duration(seconds: 5),
  }) {
    final highlights = events
        .where((e) => e.flag == 'highlight')
        .toList()
      ..sort((a, b) => a.yearFraction.compareTo(b.yearFraction));

    return TimelineStoryScript(
      title: title,
      chapters: highlights
          .map((e) => StoryChapter(event: e, dwell: dwell))
          .toList(),
    );
  }

  /// Auto-generate from top-N events by importance.
  factory TimelineStoryScript.fromTopEvents(
    List<TimelineEvent> events, {
    int count = 10,
    String? title,
  }) {
    final sorted = [...events]
      ..sort((a, b) => b.importance.compareTo(a.importance));
    final top = sorted.take(count).toList()
      ..sort((a, b) => a.yearFraction.compareTo(b.yearFraction));

    return TimelineStoryScript(
      title: title,
      chapters: top.map((e) => StoryChapter(event: e)).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// StoryPlayState
// ---------------------------------------------------------------------------

enum StoryPlayStatus { idle, playing, paused, finished }

class StoryPlayState {
  final int chapterIndex;
  final StoryPlayStatus status;
  final double chapterProgress; // 0..1 within current chapter dwell
  final double typewriterProgress; // 0..1 text reveal

  const StoryPlayState({
    this.chapterIndex = 0,
    this.status = StoryPlayStatus.idle,
    this.chapterProgress = 0,
    this.typewriterProgress = 0,
  });

  bool get isPlaying => status == StoryPlayStatus.playing;
  bool get isPaused => status == StoryPlayStatus.paused;
  bool get isFinished => status == StoryPlayStatus.finished;

  StoryPlayState copyWith({
    int? chapterIndex,
    StoryPlayStatus? status,
    double? chapterProgress,
    double? typewriterProgress,
  }) =>
      StoryPlayState(
        chapterIndex: chapterIndex ?? this.chapterIndex,
        status: status ?? this.status,
        chapterProgress: chapterProgress ?? this.chapterProgress,
        typewriterProgress: typewriterProgress ?? this.typewriterProgress,
      );
}

// ---------------------------------------------------------------------------
// TimelineStoryController
// ---------------------------------------------------------------------------

class TimelineStoryController extends ValueNotifier<StoryPlayState> {
  final TimelineStoryScript script;
  final TimelineScrollController scrollController;

  // Typewriter: chars per second
  final double typewriterSpeed;
  // Delay before auto-advance starts (after text finishes)
  final Duration dwellAfterText;

  Ticker? _ticker;
  Duration? _lastTick;
  double _dwellAccum = 0;
  double _typeAccum = 0;
  bool _navigationInProgress = false;

  TimelineStoryController({
    required this.script,
    required this.scrollController,
    this.typewriterSpeed = 40,
    this.dwellAfterText = const Duration(seconds: 1),
  }) : super(const StoryPlayState());

  StoryChapter? get currentChapter {
    final idx = value.chapterIndex;
    if (idx < 0 || idx >= script.length) return null;
    return script.chapters[idx];
  }

  bool get hasNext => value.chapterIndex < script.length - 1;
  bool get hasPrev => value.chapterIndex > 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void attach(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick)..start();
  }

  void detach() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  void play() {
    if (script.isEmpty) return;
    if (value.isFinished) {
      value = const StoryPlayState(status: StoryPlayStatus.playing);
      _navigateTo(0);
    } else {
      value = value.copyWith(status: StoryPlayStatus.playing);
    }
  }

  void pause() => value = value.copyWith(status: StoryPlayStatus.paused);

  void next() {
    if (!hasNext) {
      value = value.copyWith(status: StoryPlayStatus.finished);
      return;
    }
    _goTo(value.chapterIndex + 1);
  }

  void previous() {
    if (!hasPrev) return;
    _goTo(value.chapterIndex - 1);
  }

  void jumpTo(int index) {
    if (index < 0 || index >= script.length) return;
    _goTo(index);
  }

  void exit() {
    value = value.copyWith(status: StoryPlayStatus.idle);
    _dwellAccum = 0;
    _typeAccum = 0;
  }

  void _goTo(int index) {
    _dwellAccum = 0;
    _typeAccum = 0;
    value = value.copyWith(
      chapterIndex: index,
      chapterProgress: 0,
      typewriterProgress: 0,
    );
    _navigateTo(index);
  }

  void _navigateTo(int index) {
    if (index < 0 || index >= script.length) return;
    final chapter = script.chapters[index];
    final ev = chapter.event;
    final zoom = chapter.zoom ?? _autoZoom(ev);
    _navigationInProgress = true;
    scrollController.animateToYear(
      ev.yearFraction,
      yearsVisible: zoom,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      _navigationInProgress = false;
    });
  }

  double _autoZoom(TimelineEvent ev) {
    // Show ±50 years around important events, ±500 for less important
    return ev.importance >= 8 ? 100 : 500;
  }

  // ── Ticker ────────────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_lastTick == null) { _lastTick = elapsed; return; }
    final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;

    if (!value.isPlaying || _navigationInProgress) return;
    final chapter = currentChapter;
    if (chapter == null) return;

    // Typewriter advance
    final narrative = chapter.displayNarrative;
    final totalChars = narrative.isEmpty ? 1 : narrative.length.toDouble();
    if (value.typewriterProgress < 1.0) {
      _typeAccum += typewriterSpeed * dt;
      final newProgress = (_typeAccum / totalChars).clamp(0.0, 1.0);
      value = value.copyWith(typewriterProgress: newProgress);
      return; // don't start dwell until text is done
    }

    // Post-text dwell
    _dwellAccum += dt;
    final totalDwell = chapter.dwell.inMilliseconds / 1000.0 +
        dwellAfterText.inMilliseconds / 1000.0;
    final progress = (_dwellAccum / totalDwell).clamp(0.0, 1.0);
    value = value.copyWith(chapterProgress: progress);

    if (_dwellAccum >= totalDwell) {
      next();
    }
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// TimelineStoryOverlay — full chapter display
// ---------------------------------------------------------------------------

class TimelineStoryOverlay extends StatelessWidget {
  final TimelineStoryController controller;
  final bool isDark;
  final VoidCallback? onExit;

  const TimelineStoryOverlay({
    super.key,
    required this.controller,
    this.isDark = false,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StoryPlayState>(
      valueListenable: controller,
      builder: (ctx, state, _) {
        if (state.status == StoryPlayStatus.idle) return const SizedBox.shrink();

        final chapter = controller.currentChapter;
        if (chapter == null) return const SizedBox.shrink();

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: _ChapterCard(
            key: ValueKey(state.chapterIndex),
            chapter: chapter,
            state: state,
            controller: controller,
            isDark: isDark,
            onExit: onExit ?? controller.exit,
            chapterIndex: state.chapterIndex,
            totalChapters: controller.script.length,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _ChapterCard
// ---------------------------------------------------------------------------

class _ChapterCard extends StatelessWidget {
  final StoryChapter chapter;
  final StoryPlayState state;
  final TimelineStoryController controller;
  final bool isDark;
  final VoidCallback onExit;
  final int chapterIndex;
  final int totalChapters;

  const _ChapterCard({
    super.key,
    required this.chapter,
    required this.state,
    required this.controller,
    required this.isDark,
    required this.onExit,
    required this.chapterIndex,
    required this.totalChapters,
  });

  @override
  Widget build(BuildContext context) {
    final event = chapter.event;
    final color = event.effectiveColor;
    final bg = isDark
        ? Colors.black.withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.92);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.25 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              TimelineStoryProgressBar(
                controller: controller,
                color: color,
                isDark: isDark,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chapter number + category
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Chapter ${chapterIndex + 1} of $totalChapters',
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.category.label,
                        style: TextStyle(fontSize: 10, color: subColor),
                      ),
                    ]),

                    const SizedBox(height: 10),

                    // Year
                    Text(
                      _yearLabel(event),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Title
                    Text(
                      chapter.displayTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Divider with color
                    Container(
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Typewriter narrative
                    if (chapter.displayNarrative.isNotEmpty)
                      TimelineTypewriterText(
                        text: chapter.displayNarrative,
                        progress: state.typewriterProgress,
                        style: TextStyle(
                          fontSize: 13,
                          color: subColor,
                          height: 1.6,
                        ),
                        maxLines: 4,
                      ),
                  ],
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: TimelineStoryControls(
                  controller: controller,
                  state: state,
                  color: color,
                  isDark: isDark,
                  onExit: onExit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _yearLabel(TimelineEvent e) {
    final y = e.year.toInt();
    return y < 0 ? '${-y} BC' : '$y AD';
  }
}

// ---------------------------------------------------------------------------
// TimelineStoryProgressBar
// ---------------------------------------------------------------------------

/// Segmented progress bar: one segment per chapter, current segment fills.
class TimelineStoryProgressBar extends StatelessWidget {
  final TimelineStoryController controller;
  final Color color;
  final bool isDark;

  const TimelineStoryProgressBar({
    super.key,
    required this.controller,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StoryPlayState>(
      valueListenable: controller,
      builder: (_, state, __) {
        final count = controller.script.length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: List.generate(count, (i) {
              double fill = 0;
              if (i < state.chapterIndex) fill = 1;
              if (i == state.chapterIndex) fill = state.chapterProgress;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < count - 1 ? 3 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(children: [
                      Container(
                        height: 2.5,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      FractionallySizedBox(
                        widthFactor: fill,
                        child: Container(height: 2.5, color: color),
                      ),
                    ]),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineTypewriterText
// ---------------------------------------------------------------------------

/// Reveals [text] character by character based on [progress] (0..1).
class TimelineTypewriterText extends StatelessWidget {
  final String text;
  final double progress; // 0..1
  final TextStyle? style;
  final int maxLines;

  const TimelineTypewriterText({
    super.key,
    required this.text,
    required this.progress,
    this.style,
    this.maxLines = 6,
  });

  @override
  Widget build(BuildContext context) {
    final visibleChars = (progress * text.length).round().clamp(0, text.length);
    final visible = text.substring(0, visibleChars);
    final hidden = text.substring(visibleChars);

    return Text.rich(
      TextSpan(children: [
        TextSpan(text: visible, style: style),
        // Ghost text to preserve layout height (invisible)
        TextSpan(
          text: hidden,
          style: style?.copyWith(color: Colors.transparent) ??
              const TextStyle(color: Colors.transparent),
        ),
      ]),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineStoryControls
// ---------------------------------------------------------------------------

class TimelineStoryControls extends StatelessWidget {
  final TimelineStoryController controller;
  final StoryPlayState state;
  final Color color;
  final bool isDark;
  final VoidCallback onExit;

  const TimelineStoryControls({
    super.key,
    required this.controller,
    required this.state,
    required this.color,
    required this.isDark,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final dim = isDark ? Colors.white30 : Colors.black26;
    final active = isDark ? Colors.white70 : Colors.black54;

    return Row(children: [
      // Exit
      _Btn(
        icon: Icons.close,
        color: dim,
        onTap: onExit,
        tooltip: 'Exit story',
      ),
      const Spacer(),
      // Previous
      _Btn(
        icon: Icons.skip_previous_rounded,
        color: controller.hasPrev ? active : dim,
        onTap: controller.hasPrev ? controller.previous : null,
        tooltip: 'Previous',
      ),
      const SizedBox(width: 4),
      // Play / Pause
      GestureDetector(
        onTap: state.isPlaying ? controller.pause : controller.play,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            state.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      const SizedBox(width: 4),
      // Next
      _Btn(
        icon: Icons.skip_next_rounded,
        color: controller.hasNext ? active : dim,
        onTap: controller.hasNext ? controller.next : null,
        tooltip: 'Next',
      ),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;

  const _Btn({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      );
}
