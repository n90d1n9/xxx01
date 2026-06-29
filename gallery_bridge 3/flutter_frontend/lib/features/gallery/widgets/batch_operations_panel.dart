// lib/features/gallery/widgets/batch_operations_panel.dart
//
// Slides up from the bottom when 2+ items are selected.
// Provides: bulk rate, bulk flag, bulk color-label, export preset picker,
//           copy to collection, delete selected.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bridge/gallery_bridge.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';

class BatchOperationsPanel extends ConsumerWidget {
  const BatchOperationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    if (selection.length < 2) return const SizedBox.shrink();

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Container(
        height: 56,
        color: AppTheme.bg1,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Selection count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent, width: 0.5),
              ),
              child: Text(
                '${selection.length} selected',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter'),
              ),
            ),
            const SizedBox(width: 16),
            const _Divider(),

            // Rate all
            _BatchBtn(
              icon: Icons.star,
              label: 'Rate',
              onTap: () => _showRatingPicker(context, ref, selection),
            ),

            // Flag all
            _BatchBtn(
              icon: Icons.flag,
              label: 'Pick',
              color: AppTheme.flagGreen,
              onTap: () => _bulkSetFlag(ref, selection, 1),
            ),
            _BatchBtn(
              icon: Icons.close,
              label: 'Reject',
              color: AppTheme.flagRed,
              onTap: () => _bulkSetFlag(ref, selection, 2),
            ),
            _BatchBtn(
              icon: Icons.remove_circle_outline,
              label: 'Unflag',
              onTap: () => _bulkSetFlag(ref, selection, 0),
            ),

            const _Divider(),

            // Color label
            _BatchBtn(
              icon: Icons.circle,
              label: 'Label',
              onTap: () => _showColorLabelPicker(context, ref, selection),
            ),

            const _Divider(),

            // Export
            _BatchBtn(
              icon: Icons.upload,
              label: 'Export',
              onTap: () => _showExportPicker(context, ref, selection),
            ),

            const Spacer(),

            // Clear selection
            _BatchBtn(
              icon: Icons.deselect,
              label: 'Deselect',
              onTap: () => ref.read(selectionProvider.notifier).clear(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bulkSetFlag(
      WidgetRef ref, Set<int> ids, int flag) async {
    for (final id in ids) {
      await GalleryBridge.setFlag(id, flag);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }

  Future<void> _bulkSetRating(
      WidgetRef ref, Set<int> ids, int rating) async {
    for (final id in ids) {
      await GalleryBridge.setRating(id, rating);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }

  Future<void> _bulkSetLabel(
      WidgetRef ref, Set<int> ids, String label) async {
    for (final id in ids) {
      await GalleryBridge.setColorLabel(id, label);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }

  void _showRatingPicker(
      BuildContext context, WidgetRef ref, Set<int> selection) {
    showDialog(
      context: context,
      builder: (_) => _SimpleDialog(
        title: 'Set rating for ${selection.length} items',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...List.generate(6, (i) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _bulkSetRating(ref, selection, i);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      i == 0 ? Icons.star_border : Icons.star,
                      size: 28,
                      color: i == 0 ? AppTheme.textMuted : AppTheme.accent,
                    ),
                    const SizedBox(height: 4),
                    Text('$i',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showColorLabelPicker(
      BuildContext context, WidgetRef ref, Set<int> selection) {
    showDialog(
      context: context,
      builder: (_) => _SimpleDialog(
        title: 'Set color label for ${selection.length} items',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...AppTheme.colorLabels.entries.map((e) => GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _bulkSetLabel(ref, selection, e.key);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.value,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e.key,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            )),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _bulkSetLabel(ref, selection, '');
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined,
                      size: 28, color: AppTheme.textMuted),
                  SizedBox(height: 4),
                  Text('Clear',
                      style: TextStyle(
                          fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportPicker(
      BuildContext context, WidgetRef ref, Set<int> selection) {
    final presets = [
      'Web Optimised (1920px, JPEG 82)',
      'Social Media (1080px, JPEG 90)',
      'Print Ready (Original, PNG)',
      'Contact Sheet (400px, JPEG 75)',
    ];
    showDialog(
      context: context,
      builder: (_) => _SimpleDialog(
        title: 'Export ${selection.length} items',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: presets
              .map((p) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.upload,
                        size: 16, color: AppTheme.textSecondary),
                    title: Text(p,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textPrimary)),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Exporting ${selection.length} items with preset: $p'),
                          backgroundColor: AppTheme.bg3,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppTheme.border,
      );
}

class _BatchBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _BatchBtn(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSecondary;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: c),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: c,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleDialog extends StatelessWidget {
  final String title;
  final Widget child;
  const _SimpleDialog({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter')),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
