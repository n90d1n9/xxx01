// lib/features/gallery/widgets/metadata_panel.dart
//
// Right panel: shows EXIF data, filename, dimensions, rating/flag controls
// for the active (last-clicked) item.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../core/bridge/gallery_bridge.dart';
import '../../../shared/theme/app_theme.dart';

class MetadataPanel extends ConsumerWidget {
  const MetadataPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId   = ref.watch(activeItemIdProvider);
    final items      = ref.watch(mediaItemsProvider).valueOrNull ?? [];
    final activeItem = activeId != null
        ? items.where((i) => i.id == activeId).firstOrNull
        : null;

    return Container(
      color: AppTheme.bg1,
      child: activeItem == null
          ? _buildEmpty()
          : _buildContent(context, ref, activeItem),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 28, color: AppTheme.textMuted),
            SizedBox(height: 8),
            Text('No selection',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontFamily: 'Inter')),
          ],
        ),
      );

  Widget _buildContent(
      BuildContext context, WidgetRef ref, GMediaItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header with filename ─────────────────────────────────────
        _PanelSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.fileName,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter'),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.filePath.replaceAll(item.fileName, ''),
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    fontFamily: 'Inter'),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const _Divider(),

        // ── Rating ──────────────────────────────────────────────────
        _PanelSection(
          label: 'RATING',
          child: _RatingControl(item: item),
        ),
        const _Divider(),

        // ── Flag ────────────────────────────────────────────────────
        _PanelSection(
          label: 'FLAG',
          child: _FlagControl(item: item),
        ),
        const _Divider(),

        // ── Color label ─────────────────────────────────────────────
        _PanelSection(
          label: 'COLOR LABEL',
          child: _ColorLabelControl(item: item),
        ),
        const _Divider(),

        // ── File info ───────────────────────────────────────────────
        _PanelSection(
          label: 'FILE',
          child: Column(
            children: [
              _MetaRow('Size', item.fileSizeFormatted),
              _MetaRow('Type', item.mimeType),
              if (item.width != null)
                _MetaRow('Dimensions', item.aspectRatio),
              if (item.isRaw) _MetaRow('RAW', 'Yes'),
            ],
          ),
        ),
        const _Divider(),

        // ── EXIF ────────────────────────────────────────────────────
        Expanded(
          child: _ExifSection(itemId: item.id),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RatingControl extends ConsumerWidget {
  final GMediaItem item;
  const _RatingControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () async {
            final newRating = item.rating == star ? 0 : star;
            await GalleryBridge.setRating(item.id, newRating);
            final updated = await GalleryBridge.getMediaItem(item.id);
            if (updated != null) {
              ref.read(mediaItemsProvider.notifier).updateItem(updated);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              i < item.rating ? Icons.star : Icons.star_border,
              size: 20,
              color: i < item.rating ? AppTheme.accent : AppTheme.textMuted,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FlagControl extends ConsumerWidget {
  final GMediaItem item;
  const _FlagControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _FlagBtn(
          icon: Icons.flag,
          label: 'Pick',
          color: AppTheme.flagGreen,
          active: item.flag == 1,
          onTap: () => _setFlag(ref, item.flag == 1 ? 0 : 1),
        ),
        const SizedBox(width: 8),
        _FlagBtn(
          icon: Icons.close,
          label: 'Reject',
          color: AppTheme.flagRed,
          active: item.flag == 2,
          onTap: () => _setFlag(ref, item.flag == 2 ? 0 : 2),
        ),
      ],
    );
  }

  void _setFlag(WidgetRef ref, int flag) async {
    await GalleryBridge.setFlag(item.id, flag);
    final updated = await GalleryBridge.getMediaItem(item.id);
    if (updated != null) {
      ref.read(mediaItemsProvider.notifier).updateItem(updated);
    }
  }
}

class _FlagBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  const _FlagBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : AppTheme.bg2,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? color : AppTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? color : AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: active ? color : AppTheme.textSecondary,
                  fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ColorLabelControl extends ConsumerWidget {
  final GMediaItem item;
  const _ColorLabelControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        for (final entry in AppTheme.colorLabels.entries)
          GestureDetector(
            onTap: () => _setLabel(
                ref, item.colorLabel == entry.key ? '' : entry.key),
            child: Tooltip(
              message: entry.key[0].toUpperCase() + entry.key.substring(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.value,
                  border: Border.all(
                    color: item.colorLabel == entry.key
                        ? Colors.white
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        // Clear button
        if (item.colorLabel.isNotEmpty)
          GestureDetector(
            onTap: () => _setLabel(ref, ''),
            child: const Icon(Icons.cancel_outlined,
                size: 14, color: AppTheme.textMuted),
          ),
      ],
    );
  }

  void _setLabel(WidgetRef ref, String label) async {
    await GalleryBridge.setColorLabel(item.id, label);
    final updated = await GalleryBridge.getMediaItem(item.id);
    if (updated != null) {
      ref.read(mediaItemsProvider.notifier).updateItem(updated);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ExifSection extends ConsumerWidget {
  final int itemId;
  const _ExifSection({required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exifAsync = ref.watch(activeExifProvider);
    return exifAsync.when(
      loading: () => const _PanelSection(
          label: 'EXIF',
          child: LinearProgressIndicator(color: AppTheme.accent)),
      error: (_, __) => const _PanelSection(
          label: 'EXIF',
          child: Text('No EXIF data',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
      data: (exif) {
        if (exif == null) {
          return const _PanelSection(
              label: 'EXIF',
              child: Text('No EXIF data',
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.textMuted)));
        }
        return Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EXIF',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                        fontFamily: 'Inter')),
                const SizedBox(height: 8),
                if (exif.cameraMake != null)
                  _MetaRow('Make', exif.cameraMake!),
                if (exif.cameraModel != null)
                  _MetaRow('Model', exif.cameraModel!),
                if (exif.lens != null) _MetaRow('Lens', exif.lens!),
                if (exif.iso != null)
                  _MetaRow('ISO', exif.iso.toString()),
                if (exif.shutterSpeed != null)
                  _MetaRow('Shutter', exif.shutterSpeed!),
                if (exif.apertureFormatted != null)
                  _MetaRow('Aperture', exif.apertureFormatted!),
                if (exif.focalLengthFormatted != null)
                  _MetaRow('Focal', exif.focalLengthFormatted!),
                if (exif.flash != null)
                  _MetaRow('Flash', exif.flash! ? 'Yes' : 'No'),
                if (exif.colorSpace != null)
                  _MetaRow('Color Space', exif.colorSpace!),
                if (exif.whiteBalance != null)
                  _MetaRow('White Balance', exif.whiteBalance!),
                if (exif.hasGps) ...[
                  _MetaRow('Lat', exif.latitude!.toStringAsFixed(6)),
                  _MetaRow('Lng', exif.longitude!.toStringAsFixed(6)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _PanelSection extends StatelessWidget {
  final String? label;
  final Widget child;
  const _PanelSection({this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter'),
            ),
            const SizedBox(height: 6),
          ],
          child,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppTheme.border);
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  fontFamily: 'Inter'),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontFamily: 'JetBrains Mono'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
