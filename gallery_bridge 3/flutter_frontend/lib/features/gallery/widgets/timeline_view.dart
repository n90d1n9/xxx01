// lib/features/gallery/widgets/timeline_view.dart
//
// Timeline view: images grouped by calendar date with sticky section headers.
// Uses SliverList + SliverGrid interleaved inside a CustomScrollView.
// Each date group shows a date label then a responsive grid of thumbnails.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';
import 'thumbnail_tile.dart';

class TimelineView extends ConsumerWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(mediaItemsProvider);
    final columns    = ref.watch(gridColumnsProvider);

    return itemsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppTheme.accent, strokeWidth: 1.5)),
      error: (e, _) => Center(
          child: Text('$e',
              style: const TextStyle(
                  color: AppTheme.flagRed, fontSize: 12))),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
              child: Text('No images',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13)));
        }
        final groups = _groupByDate(items);
        return Scrollbar(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              for (final group in groups) ...[
                // Date header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DateHeaderDelegate(
                    date: group.label,
                    count: group.items.length,
                  ),
                ),
                // Grid for this date
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ThumbnailTile(item: group.items[i]),
                      childCount: group.items.length,
                      addRepaintBoundaries: true,
                      addAutomaticKeepAlives: false,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<GMediaItem> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final ta = a.createdAt ?? a.modifiedAt;
      final tb = b.createdAt ?? b.modifiedAt;
      return tb.compareTo(ta);
    });

    final map = <String, List<GMediaItem>>{};
    for (final item in sorted) {
      final ms = item.createdAt ?? item.modifiedAt;
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      final key = DateFormat('yyyy-MM-dd').format(dt);
      map.putIfAbsent(key, () => []).add(item);
    }

    return map.entries
        .map((e) => _DateGroup(
              rawKey: e.key,
              label: _formatDateLabel(e.key),
              items: e.value,
            ))
        .toList()
      ..sort((a, b) => b.rawKey.compareTo(a.rawKey));
  }

  String _formatDateLabel(String key) {
    try {
      final dt = DateTime.parse(key);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today';
      }
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day - 1) {
        return 'Yesterday';
      }
      if (dt.year == now.year) {
        return DateFormat('MMMM d').format(dt);
      }
      return DateFormat('MMMM d, yyyy').format(dt);
    } catch (_) {
      return key;
    }
  }
}

class _DateGroup {
  final String rawKey;
  final String label;
  final List<GMediaItem> items;
  const _DateGroup(
      {required this.rawKey, required this.label, required this.items});
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String date;
  final int count;
  const _DateHeaderDelegate({required this.date, required this.count});

  @override
  double get minExtent => 32;
  @override
  double get maxExtent => 32;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.bg0,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count item${count == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_DateHeaderDelegate old) =>
      old.date != date || old.count != count;
}
