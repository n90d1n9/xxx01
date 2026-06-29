// lib/features/gallery/widgets/thumbnail_tile.dart
//
// Individual tile in the grid.
// Responsibilities:
//   - Display thumbnail (from disk cache via File widget)
//   - Show selection border + checkbox
//   - Overlay: star rating, flag, color label dot, RAW badge
//   - Context menu for quick curation
//   - Hover state
//   - Double-tap to open full detail

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../core/bridge/gallery_bridge.dart';
import '../../../shared/theme/app_theme.dart';

class ThumbnailTile extends ConsumerStatefulWidget {
  final GMediaItem item;
  const ThumbnailTile({super.key, required this.item});

  @override
  ConsumerState<ThumbnailTile> createState() => _ThumbnailTileState();
}

class _ThumbnailTileState extends ConsumerState<ThumbnailTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selection   = ref.watch(selectionProvider);
    final activeId    = ref.watch(activeItemIdProvider);
    final isSelected  = selection.contains(widget.item.id);
    final isActive    = activeId == widget.item.id;
    final item        = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _onTap(context),
        onDoubleTap: () => _onDoubleTap(context),
        onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accent
                  : isActive
                      ? AppTheme.accent.withOpacity(0.5)
                      : _hovered
                          ? AppTheme.border
                          : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
            color: AppTheme.bg2,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Thumbnail image ────────────────────────────────────
                _ThumbnailImage(item: item),

                // ── Color label bar (left edge) ────────────────────────
                if (item.colorLabel.isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 3,
                    child: Container(
                      color: AppTheme.colorLabels[item.colorLabel] ??
                          Colors.transparent,
                    ),
                  ),

                // ── Bottom metadata strip ──────────────────────────────
                if (_hovered || isSelected || item.rating > 0 || item.flag > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _MetadataStrip(item: item),
                  ),

                // ── RAW badge ─────────────────────────────────────────
                if (item.isRaw)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _Badge(label: 'RAW', color: AppTheme.flagBlue),
                  ),

                // ── Flag icon ─────────────────────────────────────────
                if (item.flag == 1)
                  const Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(Icons.flag,
                        size: 14, color: AppTheme.flagGreen),
                  )
                else if (item.flag == 2)
                  const Positioned(
                    top: 4,
                    left: 4,
                    child: Icon(Icons.close,
                        size: 14, color: AppTheme.flagRed),
                  ),

                // ── Selection checkbox (hover or selected) ─────────────
                if (_hovered || isSelected)
                  Positioned(
                    top: 4,
                    right: item.isRaw ? 30 : 4,
                    child: _SelectionCheckbox(
                      selected: isSelected,
                      onTap: () => ref
                          .read(selectionProvider.notifier)
                          .toggle(item.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final isMetaHeld = HardwareKeyboard.instance.isMetaPressed;
    final isShiftHeld = HardwareKeyboard.instance.isShiftPressed;

    if (isMetaHeld) {
      ref.read(selectionProvider.notifier).toggle(widget.item.id);
    } else if (isShiftHeld) {
      // Shift-click: range select
      final items = ref.read(mediaItemsProvider).valueOrNull ?? [];
      final activeId = ref.read(activeItemIdProvider);
      final anchorIdx = items.indexWhere((i) => i.id == activeId);
      final thisIdx   = items.indexWhere((i) => i.id == widget.item.id);
      if (anchorIdx != -1 && thisIdx != -1) {
        final lo = anchorIdx < thisIdx ? anchorIdx : thisIdx;
        final hi = anchorIdx < thisIdx ? thisIdx   : anchorIdx;
        final rangeIds = items.sublist(lo, hi + 1).map((i) => i.id).toList();
        ref.read(selectionProvider.notifier).addRange(rangeIds);
      }
    } else {
      ref.read(selectionProvider.notifier).selectOnly(widget.item.id);
      ref.read(activeItemIdProvider.notifier).state = widget.item.id;
    }
  }

  void _onDoubleTap(BuildContext context) {
    // Open full-screen detail view
    // context.go('/detail/${widget.item.id}');
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      color: AppTheme.bg2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppTheme.border)),
      items: [
        _menuItem('flag_pick',    'Pick',          Icons.flag),
        _menuItem('flag_reject',  'Reject',        Icons.close),
        _menuItem('flag_clear',   'Clear Flag',    Icons.remove),
        const PopupMenuDivider(),
        _menuItem('rate_5', '★★★★★ 5 Stars', Icons.star),
        _menuItem('rate_4', '★★★★☆ 4 Stars', Icons.star),
        _menuItem('rate_3', '★★★☆☆ 3 Stars', Icons.star),
        _menuItem('rate_0', 'Clear Rating',       Icons.star_border),
        const PopupMenuDivider(),
        _menuItem('label_red',    'Red Label',     Icons.circle),
        _menuItem('label_green',  'Green Label',   Icons.circle),
        _menuItem('label_blue',   'Blue Label',    Icons.circle),
        _menuItem('label_yellow', 'Yellow Label',  Icons.circle),
        _menuItem('label_clear',  'Clear Label',   Icons.circle_outlined),
        const PopupMenuDivider(),
        _menuItem('reveal', 'Reveal in Finder', Icons.folder_open),
      ],
    );

    if (result == null) return;
    await _handleMenuAction(result);
  }

  PopupMenuItem<String> _menuItem(String value, String label, IconData icon) =>
      PopupMenuItem(
        value: value,
        height: 32,
        child: Row(
          children: [
            Icon(icon, size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter')),
          ],
        ),
      );

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'flag_pick':
        await GalleryBridge.setFlag(widget.item.id, 1);
      case 'flag_reject':
        await GalleryBridge.setFlag(widget.item.id, 2);
      case 'flag_clear':
        await GalleryBridge.setFlag(widget.item.id, 0);
      case 'rate_5':
        await GalleryBridge.setRating(widget.item.id, 5);
      case 'rate_4':
        await GalleryBridge.setRating(widget.item.id, 4);
      case 'rate_3':
        await GalleryBridge.setRating(widget.item.id, 3);
      case 'rate_0':
        await GalleryBridge.setRating(widget.item.id, 0);
      case 'label_red':
        await GalleryBridge.setColorLabel(widget.item.id, 'red');
      case 'label_green':
        await GalleryBridge.setColorLabel(widget.item.id, 'green');
      case 'label_blue':
        await GalleryBridge.setColorLabel(widget.item.id, 'blue');
      case 'label_yellow':
        await GalleryBridge.setColorLabel(widget.item.id, 'yellow');
      case 'label_clear':
        await GalleryBridge.setColorLabel(widget.item.id, '');
    }
    // Refresh the item in state
    final updated = await GalleryBridge.getMediaItem(widget.item.id);
    if (updated != null) {
      ref.read(mediaItemsProvider.notifier).updateItem(updated);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThumbnailImage extends StatelessWidget {
  final GMediaItem item;
  const _ThumbnailImage({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.thumbnailPath != null) {
      return Image.file(
        File(item.thumbnailPath!),
        fit: BoxFit.cover,
        cacheWidth: 240,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: AppTheme.bg2,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 24, color: AppTheme.textMuted),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _MetadataStrip extends StatelessWidget {
  final GMediaItem item;
  const _MetadataStrip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Stars
          ...List.generate(
            5,
            (i) => Icon(
              i < item.rating ? Icons.star : Icons.star_border,
              size: 9,
              color: i < item.rating
                  ? AppTheme.accent
                  : AppTheme.textMuted.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          if (item.width != null && item.height != null)
            Text(
              '${item.width}×${item.height}',
              style: const TextStyle(
                  fontSize: 8,
                  color: AppTheme.textMuted,
                  fontFamily: 'JetBrains Mono'),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 8,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFamily: 'JetBrains Mono'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SelectionCheckbox extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _SelectionCheckbox({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppTheme.accent : AppTheme.bg0.withOpacity(0.6),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.textMuted,
            width: 1.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 10, color: AppTheme.bg0)
            : null,
      ),
    );
  }
}
