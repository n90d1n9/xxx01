// lib/features/compare/compare_view.dart
//
// A/B Comparison view.
// Two images side-by-side (or split-screen) with synchronised zoom/pan.
// The user picks any two items from the selection.
// Supports: Side-by-side | Split (drag divider) | Toggle (flicker)

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/models/gallery_models.dart';
import '../../core/providers/gallery_providers.dart';
import '../../shared/theme/app_theme.dart';

enum CompareMode { sideBySide, split, toggle }

final compareModeProvider = StateProvider<CompareMode>((ref) => CompareMode.sideBySide);
final compareItemsProvider = StateProvider<(int?, int?)>((ref) => (null, null));

class CompareView extends ConsumerStatefulWidget {
  const CompareView({super.key});

  @override
  ConsumerState<CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends ConsumerState<CompareView>
    with SingleTickerProviderStateMixin {
  final _controllerA = PhotoViewController();
  final _controllerB = PhotoViewController();
  double _splitPos = 0.5;
  bool _syncZoom = true;
  bool _toggleState = false;
  late AnimationController _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _controllerA.outputStateStream.listen((state) {
      if (_syncZoom) {
        _controllerB.scale = state.scale;
        _controllerB.position = state.position;
      }
    });
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _toggleAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(compareModeProvider);
    final (idA, idB) = ref.watch(compareItemsProvider);
    final items = ref.watch(mediaItemsProvider).valueOrNull ?? [];

    final itemA = idA != null ? items.where((i) => i.id == idA).firstOrNull : null;
    final itemB = idB != null ? items.where((i) => i.id == idB).firstOrNull : null;

    if (itemA == null || itemB == null) {
      return _EmptyCompare(
        onPickItems: () => _autoPickTwo(ref, items),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Column(
        children: [
          _CompareToolbar(
            itemA: itemA,
            itemB: itemB,
            mode: mode,
            syncZoom: _syncZoom,
            onModeChange: (m) =>
                ref.read(compareModeProvider.notifier).state = m,
            onSyncToggle: () => setState(() => _syncZoom = !_syncZoom),
            onSwap: () {
              final (a, b) = ref.read(compareItemsProvider);
              ref.read(compareItemsProvider.notifier).state = (b, a);
            },
            onClose: () =>
                ref.read(compareItemsProvider.notifier).state = (null, null),
          ),
          Expanded(
            child: switch (mode) {
              CompareMode.sideBySide => _SideBySide(
                  itemA: itemA, itemB: itemB,
                  ctrlA: _controllerA, ctrlB: _controllerB),
              CompareMode.split => _SplitView(
                  itemA: itemA, itemB: itemB,
                  splitPos: _splitPos,
                  onSplitChange: (p) => setState(() => _splitPos = p)),
              CompareMode.toggle => _ToggleView(
                  itemA: _toggleState ? itemB : itemA,
                  onToggle: () => setState(() => _toggleState = !_toggleState)),
            },
          ),
          _CompareFooter(itemA: itemA, itemB: itemB),
        ],
      ),
    );
  }

  void _autoPickTwo(WidgetRef ref, List<GMediaItem> items) {
    final sel = ref.read(selectionProvider).toList();
    if (sel.length >= 2) {
      ref.read(compareItemsProvider.notifier).state = (sel[0], sel[1]);
    } else if (items.length >= 2) {
      ref.read(compareItemsProvider.notifier).state =
          (items[0].id, items[1].id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CompareToolbar extends StatelessWidget {
  final GMediaItem itemA;
  final GMediaItem itemB;
  final CompareMode mode;
  final bool syncZoom;
  final ValueChanged<CompareMode> onModeChange;
  final VoidCallback onSyncToggle;
  final VoidCallback onSwap;
  final VoidCallback onClose;
  const _CompareToolbar({
    required this.itemA, required this.itemB, required this.mode,
    required this.syncZoom, required this.onModeChange,
    required this.onSyncToggle, required this.onSwap, required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppTheme.bg1,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
            onPressed: onClose,
          ),
          const Text('Compare',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(width: 16),
          _ModeBtn('⊟', 'Side by Side', mode == CompareMode.sideBySide,
              () => onModeChange(CompareMode.sideBySide)),
          _ModeBtn('◫', 'Split', mode == CompareMode.split,
              () => onModeChange(CompareMode.split)),
          _ModeBtn('⇆', 'Toggle', mode == CompareMode.toggle,
              () => onModeChange(CompareMode.toggle)),
          const Spacer(),
          _ToolChip(
            icon: Icons.sync,
            label: 'Sync Zoom',
            active: syncZoom,
            onTap: onSyncToggle,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.swap_horiz, size: 16, color: AppTheme.textSecondary),
            onPressed: onSwap,
            tooltip: 'Swap A/B',
          ),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeBtn(this.icon, this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: active ? AppTheme.accentGlow : AppTheme.bg2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
          ),
          child: Text(icon,
              style: TextStyle(
                  fontSize: 13, color: active ? AppTheme.accent : AppTheme.textSecondary)),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToolChip({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.accentGlow : AppTheme.bg2,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: active ? AppTheme.accent : AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? AppTheme.accent : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: active ? AppTheme.accent : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SideBySide extends StatelessWidget {
  final GMediaItem itemA;
  final GMediaItem itemB;
  final PhotoViewController ctrlA;
  final PhotoViewController ctrlB;
  const _SideBySide({required this.itemA, required this.itemB,
      required this.ctrlA, required this.ctrlB});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ImagePane(item: itemA, label: 'A', controller: ctrlA)),
        const VerticalDivider(width: 1, color: AppTheme.border),
        Expanded(child: _ImagePane(item: itemB, label: 'B', controller: ctrlB)),
      ],
    );
  }
}

class _SplitView extends StatelessWidget {
  final GMediaItem itemA;
  final GMediaItem itemB;
  final double splitPos;
  final ValueChanged<double> onSplitChange;
  const _SplitView({required this.itemA, required this.itemB,
      required this.splitPos, required this.onSplitChange});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final splitX = splitPos * constraints.maxWidth;
      return GestureDetector(
        onHorizontalDragUpdate: (d) =>
            onSplitChange(((splitPos * constraints.maxWidth + d.delta.dx)
                / constraints.maxWidth).clamp(0.05, 0.95)),
        child: Stack(
          children: [
            Positioned.fill(child: _buildImage(itemB)),
            Positioned(
              left: 0, top: 0, bottom: 0, width: splitX,
              child: ClipRect(child: _buildImage(itemA)),
            ),
            // Divider handle
            Positioned(
              left: splitX - 1, top: 0, bottom: 0, width: 2,
              child: Container(color: Colors.white.withOpacity(0.8)),
            ),
            Positioned(
              left: splitX - 14, top: 0, bottom: 0, width: 28,
              child: Center(
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.drag_indicator, size: 14, color: Colors.white),
                ),
              ),
            ),
            // Labels
            Positioned(top: 8, left: 8,
                child: _Label('A')),
            Positioned(top: 8, right: 8,
                child: _Label('B')),
          ],
        ),
      );
    });
  }

  Widget _buildImage(GMediaItem item) {
    if (item.thumbnailPath != null) {
      return Image.file(File(item.thumbnailPath!), fit: BoxFit.cover,
          width: double.infinity, height: double.infinity);
    }
    return Container(
      color: AppTheme.bg2,
      child: const Center(child: Icon(Icons.image, size: 32, color: AppTheme.textMuted)),
    );
  }
}

class _ToggleView extends StatelessWidget {
  final GMediaItem itemA;
  final VoidCallback onToggle;
  const _ToggleView({required this.itemA, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Stack(
        children: [
          Positioned.fill(child: _ImagePane(item: itemA, label: 'Tap to toggle')),
        ],
      ),
    );
  }
}

class _ImagePane extends StatelessWidget {
  final GMediaItem item;
  final String label;
  final PhotoViewController? controller;
  const _ImagePane({required this.item, required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (item.thumbnailPath != null)
          PhotoView(
            imageProvider: FileImage(File(item.thumbnailPath!)),
            controller: controller,
            backgroundDecoration: const BoxDecoration(color: AppTheme.bg0),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 8,
          )
        else
          Container(
            color: AppTheme.bg2,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  size: 32, color: AppTheme.textMuted),
            ),
          ),
        Positioned(top: 8, left: 8, child: _Label(label)),
        Positioned(
          bottom: 8, left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(item.fileName,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bg0.withOpacity(0.75),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accent)),
    );
  }
}

class _CompareFooter extends StatelessWidget {
  final GMediaItem itemA;
  final GMediaItem itemB;
  const _CompareFooter({required this.itemA, required this.itemB});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppTheme.bg1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FooterTag('A', itemA),
          const Spacer(),
          _FooterTag('B', itemB),
        ],
      ),
    );
  }
}

class _FooterTag extends StatelessWidget {
  final String side;
  final GMediaItem item;
  const _FooterTag(this.side, this.item);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            color: AppTheme.accentGlow,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppTheme.accent),
          ),
          child: Center(
            child: Text(side,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accent)),
          ),
        ),
        const SizedBox(width: 6),
        Text('${item.fileName}  ·  ${item.width}×${item.height}  ·  ${item.fileSizeFormatted}',
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontFamily: 'JetBrains Mono')),
      ],
    );
  }
}

class _EmptyCompare extends StatelessWidget {
  final VoidCallback onPickItems;
  const _EmptyCompare({required this.onPickItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.compare, size: 36, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          const Text('Select two images to compare',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('Shift+click to multi-select, then open Compare',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPickItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bg3,
              foregroundColor: AppTheme.textPrimary,
            ),
            child: const Text('Auto-pick two images'),
          ),
        ],
      ),
    );
  }
}
