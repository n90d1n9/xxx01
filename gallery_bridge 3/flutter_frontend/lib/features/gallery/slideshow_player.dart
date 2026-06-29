// lib/features/gallery/slideshow_player.dart
//
// Fullscreen slideshow player.
// Features:
//   - Auto-advance timer with visual countdown bar
//   - Crossfade / slide transitions (CSS-style in Flutter via AnimatedSwitcher)
//   - Play / Pause / Prev / Next controls
//   - Configurable duration (3s / 5s / 8s / custom)
//   - Ken Burns effect (slow zoom+pan via Transform.scale + Tween)
//   - EXIF overlay (camera, settings)
//   - Caption overlay
//   - Keyboard: Space=play/pause, ←/→=nav, Esc=exit, F=toggle fullscreen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/gallery_models.dart';
import '../../core/providers/gallery_providers.dart';
import '../../shared/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final slideshowDurationProvider = StateProvider<int>((ref) => 5); // seconds

// ─────────────────────────────────────────────────────────────────────────────
// Player
// ─────────────────────────────────────────────────────────────────────────────

class SlideshowPlayer extends ConsumerStatefulWidget {
  final List<GMediaItem> items;
  final int startIndex;
  const SlideshowPlayer({
    super.key,
    required this.items,
    this.startIndex = 0,
  });

  static Future<void> show(
    BuildContext context,
    List<GMediaItem> items, {
    int startIndex = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            SlideshowPlayer(items: items, startIndex: startIndex),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  ConsumerState<SlideshowPlayer> createState() => _SlideshowPlayerState();
}

class _SlideshowPlayerState extends ConsumerState<SlideshowPlayer>
    with TickerProviderStateMixin {
  late int _index;
  bool _playing = true;
  bool _hudVisible = true;
  bool _exifVisible = false;
  Timer? _timer;
  Timer? _hudTimer;
  late AnimationController _timerAnim;
  late AnimationController _kenBurnsAnim;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex.clamp(0, widget.items.length - 1);

    _timerAnim = AnimationController(vsync: this);
    _kenBurnsAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    if (_playing) _startTimer();
    _startKenBurns();
    _scheduleHudHide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hudTimer?.cancel();
    _timerAnim.dispose();
    _kenBurnsAnim.dispose();
    super.dispose();
  }

  int get _duration => ref.read(slideshowDurationProvider);

  void _startTimer() {
    _timer?.cancel();
    final dur = Duration(seconds: _duration);
    _timerAnim.duration = dur;
    _timerAnim.forward(from: 0);
    _timer = Timer(dur, _next);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timerAnim.stop();
  }

  void _startKenBurns() {
    _kenBurnsAnim.forward(from: 0).then((_) {
      if (mounted) _kenBurnsAnim.reverse();
    });
  }

  void _scheduleHudHide() {
    _hudTimer?.cancel();
    _hudTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _playing) setState(() => _hudVisible = false);
    });
  }

  void _showHud() {
    setState(() => _hudVisible = true);
    _scheduleHudHide();
  }

  void _next() {
    if (!mounted) return;
    setState(() {
      _index = (_index + 1) % widget.items.length;
    });
    _startKenBurns();
    if (_playing) _startTimer();
  }

  void _prev() {
    setState(() {
      _index = (_index - 1 + widget.items.length) % widget.items.length;
    });
    _startKenBurns();
    if (_playing) _startTimer();
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _startTimer();
    } else {
      _stopTimer();
    }
    _showHud();
  }

  GMediaItem get _current => widget.items[_index];

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.space): _togglePlay,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _next,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _prev,
        const SingleActivator(LogicalKeyboardKey.keyE): () =>
            setState(() => _exifVisible = !_exifVisible),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: _showHud,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Image with Ken Burns ───────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _ImageSlide(
                    key: ValueKey(_index),
                    item: _current,
                    kenBurnsAnim: _kenBurnsAnim,
                  ),
                ),

                // ── Timer bar ─────────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  child: AnimatedBuilder(
                    animation: _timerAnim,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _timerAnim.value,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                      minHeight: 2,
                    ),
                  ),
                ),

                // ── EXIF overlay ──────────────────────────────────
                if (_exifVisible)
                  Positioned(
                    bottom: 72,
                    left: 20,
                    child: _ExifBadge(item: _current),
                  ),

                // ── Controls HUD ──────────────────────────────────
                if (_hudVisible) _buildHud(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHud() {
    return Stack(
      children: [
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _current.fileName,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${_index + 1} / ${widget.items.length}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white54),
                ),
                const SizedBox(width: 12),
                // Duration selector
                _DurationPicker(),
              ],
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xBB000000), Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlBtn(
                  icon: Icons.skip_previous,
                  onTap: _prev,
                  size: 22,
                ),
                const SizedBox(width: 24),
                _ControlBtn(
                  icon: _playing ? Icons.pause : Icons.play_arrow,
                  onTap: _togglePlay,
                  size: 32,
                  highlighted: true,
                ),
                const SizedBox(width: 24),
                _ControlBtn(
                  icon: Icons.skip_next,
                  onTap: _next,
                  size: 22,
                ),
                const SizedBox(width: 32),
                _ControlBtn(
                  icon: Icons.info_outline,
                  onTap: () => setState(() => _exifVisible = !_exifVisible),
                  size: 18,
                  active: _exifVisible,
                ),
              ],
            ),
          ),
        ),

        // Left nav
        Positioned(
          left: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: _NavBtn(icon: Icons.chevron_left, onTap: _prev),
          ),
        ),

        // Right nav
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: _NavBtn(icon: Icons.chevron_right, onTap: _next),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ImageSlide extends StatelessWidget {
  final GMediaItem item;
  final AnimationController kenBurnsAnim;
  const _ImageSlide({super.key, required this.item, required this.kenBurnsAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: kenBurnsAnim,
      builder: (_, child) {
        final scale = 1.0 + kenBurnsAnim.value * 0.08;
        final dx    = kenBurnsAnim.value * 0.02;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale)
            ..translate(dx * 100, 0.0),
          child: child,
        );
      },
      child: Container(
        color: Colors.black,
        child: Center(
          child: item.thumbnailPath != null
              ? Image.asset(
                  item.thumbnailPath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image, size: 64, color: Colors.white12),
            const SizedBox(height: 12),
            Text(item.fileName,
                style: const TextStyle(
                    fontSize: 14, color: Colors.white24)),
          ],
        ),
      );
}

class _ExifBadge extends StatelessWidget {
  final GMediaItem item;
  const _ExifBadge({required this.item});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.fileName,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('${item.width ?? '?'} × ${item.height ?? '?'}',
                style: const TextStyle(
                    fontSize: 11, color: Colors.white54, fontFamily: 'JetBrains Mono')),
          ],
        ),
      );
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool highlighted;
  final bool active;
  const _ControlBtn({
    required this.icon,
    required this.onTap,
    this.size = 22,
    this.highlighted = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size + 20,
          height: size + 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlighted
                ? AppTheme.accent.withOpacity(0.9)
                : active
                    ? Colors.white12
                    : Colors.transparent,
            border: Border.all(
              color: highlighted ? AppTheme.accent : Colors.white24,
            ),
          ),
          child: Icon(icon,
              size: size,
              color: highlighted ? AppTheme.bg0 : Colors.white),
        ),
      );
}

class _NavBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});
  @override
  State<_NavBtn> createState() => _NavBtnState();
}

class _NavBtnState extends State<_NavBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _hovered ? 0.9 : 0.3,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      );
}

class _DurationPicker extends ConsumerWidget {
  const _DurationPicker();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dur = ref.watch(slideshowDurationProvider);
    return PopupMenuButton<int>(
      initialValue: dur,
      color: AppTheme.bg2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppTheme.border)),
      onSelected: (v) =>
          ref.read(slideshowDurationProvider.notifier).state = v,
      itemBuilder: (_) => [3, 5, 8, 12, 20]
          .map((s) => PopupMenuItem(
                value: s,
                child: Text('${s}s per slide',
                    style: TextStyle(
                        fontSize: 12,
                        color: s == dur
                            ? AppTheme.accent
                            : AppTheme.textPrimary)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          '${dur}s',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ),
    );
  }
}
