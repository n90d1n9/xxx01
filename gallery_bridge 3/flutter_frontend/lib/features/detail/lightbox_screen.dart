// lib/features/detail/lightbox_screen.dart
//
// Full-screen lightbox viewer.
// Features:
//   - PhotoView for pinch-zoom + pan
//   - Previous / Next navigation (keyboard ← → or swipe)
//   - Overlay HUD: filename, EXIF badge strip, rating/flag controls
//   - Histogram panel (slide-in from bottom)
//   - Keyboard: Escape=close, ←/→=navigate, P=pick, X=reject, 0-5=rate
//   - Hero animation from grid tile

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/models/gallery_models.dart';
import '../../core/providers/gallery_providers.dart';
import '../../core/bridge/gallery_bridge.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/histogram_panel.dart';

class LightboxScreen extends ConsumerStatefulWidget {
  final int initialItemId;
  const LightboxScreen({super.key, required this.initialItemId});

  @override
  ConsumerState<LightboxScreen> createState() => _LightboxScreenState();
}

class _LightboxScreenState extends ConsumerState<LightboxScreen>
    with SingleTickerProviderStateMixin {
  late int _currentId;
  bool _hudVisible = true;
  bool _histogramVisible = false;
  late AnimationController _hudAnim;

  @override
  void initState() {
    super.initState();
    _currentId = widget.initialItemId;
    _hudAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _hudAnim.dispose();
    super.dispose();
  }

  List<GMediaItem> get _items =>
      ref.read(mediaItemsProvider).valueOrNull ?? [];

  int get _currentIndex => _items.indexWhere((i) => i.id == _currentId);

  GMediaItem? get _currentItem {
    final idx = _currentIndex;
    return idx >= 0 ? _items[idx] : null;
  }

  void _navigate(int delta) {
    final items = _items;
    if (items.isEmpty) return;
    final newIdx = (_currentIndex + delta).clamp(0, items.length - 1);
    setState(() => _currentId = items[newIdx].id);
    ref.read(activeItemIdProvider.notifier).state = _currentId;
  }

  void _toggleHud() {
    setState(() => _hudVisible = !_hudVisible);
    if (_hudVisible) {
      _hudAnim.forward();
    } else {
      _hudAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final items = _items;
    final idx = _currentIndex;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _navigate(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _navigate(1),
        const SingleActivator(LogicalKeyboardKey.keyP): () =>
            _setFlag(item, 1),
        const SingleActivator(LogicalKeyboardKey.keyX): () =>
            _setFlag(item, 2),
        const SingleActivator(LogicalKeyboardKey.keyH): () =>
            setState(() => _histogramVisible = !_histogramVisible),
        const SingleActivator(LogicalKeyboardKey.digit0): () =>
            _setRating(item, 0),
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            _setRating(item, 1),
        const SingleActivator(LogicalKeyboardKey.digit2): () =>
            _setRating(item, 2),
        const SingleActivator(LogicalKeyboardKey.digit3): () =>
            _setRating(item, 3),
        const SingleActivator(LogicalKeyboardKey.digit4): () =>
            _setRating(item, 4),
        const SingleActivator(LogicalKeyboardKey.digit5): () =>
            _setRating(item, 5),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.bg0,
          body: Stack(
            children: [
              // ── Main image viewer ────────────────────────────────
              GestureDetector(
                onTap: _toggleHud,
                child: item == null
                    ? const Center(
                        child: Icon(Icons.broken_image,
                            size: 48, color: AppTheme.textMuted))
                    : PageView.builder(
                        itemCount: items.length,
                        controller: PageController(initialPage: idx),
                        onPageChanged: (i) {
                          setState(() => _currentId = items[i].id);
                          ref.read(activeItemIdProvider.notifier).state =
                              items[i].id;
                        },
                        itemBuilder: (_, i) => _ImagePage(item: items[i]),
                      ),
              ),

              // ── Top HUD ──────────────────────────────────────────
              if (_hudVisible)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _hudAnim,
                    child: _TopHud(
                      item: item,
                      index: idx,
                      total: items.length,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),

              // ── Bottom HUD ────────────────────────────────────────
              if (_hudVisible && item != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _hudAnim,
                    child: _BottomHud(
                      item: item,
                      histogramVisible: _histogramVisible,
                      onToggleHistogram: () => setState(
                          () => _histogramVisible = !_histogramVisible),
                      onRating: (r) => _setRating(item, r),
                      onFlag: (f) => _setFlag(item, f),
                    ),
                  ),
                ),

              // ── Nav arrows ────────────────────────────────────────
              if (_hudVisible) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: _NavArrow(
                    icon: Icons.chevron_left,
                    enabled: idx > 0,
                    onTap: () => _navigate(-1),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: _NavArrow(
                    icon: Icons.chevron_right,
                    enabled: idx < items.length - 1,
                    onTap: () => _navigate(1),
                  ),
                ),
              ],

              // ── Histogram panel ────────────────────────────────────
              if (_histogramVisible && item != null)
                Positioned(
                  bottom: 80,
                  left: 16,
                  child: HistogramPanel(item: item),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setRating(GMediaItem? item, int r) async {
    if (item == null) return;
    await GalleryBridge.setRating(item.id, r);
    final updated = await GalleryBridge.getMediaItem(item.id);
    if (updated != null) {
      ref.read(mediaItemsProvider.notifier).updateItem(updated);
    }
    setState(() {});
  }

  void _setFlag(GMediaItem? item, int f) async {
    if (item == null) return;
    await GalleryBridge.setFlag(item.id, f);
    final updated = await GalleryBridge.getMediaItem(item.id);
    if (updated != null) {
      ref.read(mediaItemsProvider.notifier).updateItem(updated);
    }
    setState(() {});
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ImagePage extends StatelessWidget {
  final GMediaItem item;
  const _ImagePage({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.thumbnailPath != null) {
      return PhotoView(
        imageProvider: FileImage(File(item.thumbnailPath!)),
        backgroundDecoration:
            const BoxDecoration(color: AppTheme.bg0),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 8,
        heroAttributes:
            PhotoViewHeroAttributes(tag: 'thumb_${item.id}'),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(
              color: AppTheme.accent, strokeWidth: 1.5),
        ),
      );
    }
    return const Center(
      child: Icon(Icons.image_not_supported_outlined,
          size: 48, color: AppTheme.textMuted),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TopHud extends StatelessWidget {
  final GMediaItem? item;
  final int index;
  final int total;
  final VoidCallback onClose;
  const _TopHud(
      {required this.item,
      required this.index,
      required this.total,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: onClose,
            tooltip: 'Close (Esc)',
          ),
          const SizedBox(width: 8),
          if (item != null)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item!.fileName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  Text('${item!.aspectRatio} · ${item!.fileSizeFormatted}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white60)),
                ],
              ),
            ),
          Text(
            '${index + 1} / $total',
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BottomHud extends StatelessWidget {
  final GMediaItem item;
  final bool histogramVisible;
  final VoidCallback onToggleHistogram;
  final ValueChanged<int> onRating;
  final ValueChanged<int> onFlag;
  const _BottomHud({
    required this.item,
    required this.histogramVisible,
    required this.onToggleHistogram,
    required this.onRating,
    required this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Stars
          ...List.generate(5, (i) {
            final lit = i < item.rating;
            return GestureDetector(
              onTap: () => onRating(item.rating == i + 1 ? 0 : i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  lit ? Icons.star : Icons.star_border,
                  size: 22,
                  color: lit ? AppTheme.accent : Colors.white38,
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
          // Flag
          _HudBtn(
            icon: Icons.flag,
            active: item.flag == 1,
            activeColor: AppTheme.flagGreen,
            onTap: () => onFlag(item.flag == 1 ? 0 : 1),
          ),
          const SizedBox(width: 8),
          _HudBtn(
            icon: Icons.close,
            active: item.flag == 2,
            activeColor: AppTheme.flagRed,
            onTap: () => onFlag(item.flag == 2 ? 0 : 2),
          ),
          const Spacer(),
          // Histogram toggle
          _HudBtn(
            icon: Icons.bar_chart,
            active: histogramVisible,
            activeColor: AppTheme.accent,
            onTap: onToggleHistogram,
            tooltip: 'Histogram (H)',
          ),
        ],
      ),
    );
  }
}

class _HudBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final String? tooltip;
  const _HudBtn({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? activeColor.withOpacity(0.25)
                : Colors.transparent,
            border: Border.all(
              color: active ? activeColor : Colors.white24,
              width: 1,
            ),
          ),
          child: Icon(icon,
              size: 16,
              color: active ? activeColor : Colors.white54),
        ),
      ),
    );
  }
}

class _NavArrow extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavArrow(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  State<_NavArrow> createState() => _NavArrowState();
}

class _NavArrowState extends State<_NavArrow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: Center(
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: !widget.enabled
                ? 0.0
                : _hovered
                    ? 1.0
                    : 0.35,
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
      ),
    );
  }
}
