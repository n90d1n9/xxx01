// lib/features/gallery/widgets/media_grid.dart
//
// Virtualized media grid.
// Uses SliverGrid so only visible tiles are in the widget tree.
// Supports variable column counts, selection, inline curation.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';
import 'thumbnail_tile.dart';

class MediaGrid extends ConsumerStatefulWidget {
  const MediaGrid({super.key});

  @override
  ConsumerState<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends ConsumerState<MediaGrid> {
  final ScrollController _scroll = ScrollController();
  int _loadedPages = 1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) {
      _loadMore();
    }
  }

  void _loadMore() {
    final items = ref.read(mediaItemsProvider).valueOrNull;
    if (items == null) return;
    // Only load more if current page is "full"
    if (items.length == _loadedPages * 200) {
      _loadedPages++;
      ref.read(mediaItemsProvider.notifier).loadMore(_loadedPages - 1);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(mediaItemsProvider);
    final columns    = ref.watch(gridColumnsProvider);
    final viewMode   = ref.watch(viewModeProvider);

    return itemsAsync.when(
      loading: () => _buildShimmerGrid(columns),
      error: (e, _) => _buildError(e),
      data: (items) {
        if (items.isEmpty) return _buildEmpty();
        return viewMode == ViewMode.list
            ? _buildListView(items)
            : _buildGridView(items, columns);
      },
    );
  }

  Widget _buildGridView(List<GMediaItem> items, int columns) {
    return Scrollbar(
      controller: _scroll,
      child: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ThumbnailTile(item: items[index]),
                childCount: items.length,
                addRepaintBoundaries: true,
                addAutomaticKeepAlives: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<GMediaItem> items) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: items.length,
      itemExtent: 56, // fixed height for performance
      itemBuilder: (context, index) => _ListTile(item: items[index]),
    );
  }

  Widget _buildShimmerGrid(int columns) {
    return Shimmer.fromColors(
      baseColor: AppTheme.bg2,
      highlightColor: AppTheme.bg3,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 30,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppTheme.bg2,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 48, color: AppTheme.textMuted),
          SizedBox(height: 16),
          Text(
            'No images found',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontFamily: 'Inter'),
          ),
          SizedBox(height: 6),
          Text(
            'Add a folder from the sidebar to start indexing.',
            style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Text(
        'Error loading images:\n$error',
        style: const TextStyle(color: AppTheme.flagRed, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List row for list view mode
// ─────────────────────────────────────────────────────────────────────────────

class _ListTile extends ConsumerWidget {
  final GMediaItem item;
  const _ListTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final isSelected = selection.contains(item.id);

    return GestureDetector(
      onTap: () {
        ref.read(activeItemIdProvider.notifier).state = item.id;
        ref.read(selectionProvider.notifier).selectOnly(item.id);
      },
      child: Container(
        color: isSelected ? AppTheme.bg3 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 44,
                height: 44,
                child: item.thumbnailPath != null
                    ? Image.file(
                        scale: 1,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        // File(item.thumbnailPath!)
                        colorBlendMode: BlendMode.src,
                        color: Colors.transparent,
                      )
                    : Container(color: AppTheme.bg2),
              ),
            ),
            const SizedBox(width: 12),
            // File name
            Expanded(
              flex: 3,
              child: Text(
                item.fileName,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Dimensions
            SizedBox(
              width: 100,
              child: Text(
                item.aspectRatio,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontFamily: 'JetBrains Mono'),
              ),
            ),
            // Size
            SizedBox(
              width: 70,
              child: Text(
                item.fileSizeFormatted,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontFamily: 'JetBrains Mono'),
              ),
            ),
            // Rating stars
            _StarRow(rating: item.rating),
            const SizedBox(width: 12),
            // Flag
            _FlagDot(flag: item.flag),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 10,
          color: i < rating ? AppTheme.accent : AppTheme.textMuted,
        ),
      ),
    );
  }
}

class _FlagDot extends StatelessWidget {
  final int flag;
  const _FlagDot({required this.flag});

  @override
  Widget build(BuildContext context) {
    if (flag == 0) return const SizedBox(width: 10);
    return Icon(
      flag == 1 ? Icons.flag : Icons.close,
      size: 12,
      color: flag == 1 ? AppTheme.flagGreen : AppTheme.flagRed,
    );
  }
}
