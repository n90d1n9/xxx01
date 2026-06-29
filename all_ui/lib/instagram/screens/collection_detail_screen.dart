import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/event_collection.dart';
import '../models/media_item.dart';
import '../models/pagination.dart';
import '../states/gallery_provider.dart';
import 'photo_player_screen.dart';
import 'slide_show_screen.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final EventCollection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildCollectionInfo()),
          SliverToBoxAdapter(child: _buildActionButtons(context, ref)),
          SliverToBoxAdapter(child: _buildMediaGrid(context, ref)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF667eea),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: collection.coverImageUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing collection...')),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collection.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            collection.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  collection.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                _formatDate(collection.eventDate),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'by ${collection.photographer}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                collection.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Color(0xFF667eea),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startSlideshow(context),
              icon: const Icon(Icons.slideshow, color: Colors.white),
              label: const Text(
                'Slideshow',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _downloadCollection(context),
              icon: const Icon(Icons.download, color: Color(0xFF667eea)),
              label: const Text(
                'Download',
                style: TextStyle(color: Color(0xFF667eea)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF667eea)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Media (${collection.totalItems})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showSortOptions(context, ref),
                    icon: const Icon(Icons.sort),
                  ),
                  IconButton(
                    onPressed: () => _toggleViewMode(ref),
                    icon: const Icon(Icons.view_module),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMasonryGrid(context, ref),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(BuildContext context, WidgetRef ref) {
    final media = collection.allMedia;

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: media.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openPhotoPlayer(context, media, index),
          child: Hero(
            tag: media[index].id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: media[index].thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  if (media[index].type == MediaType.video)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap:
                          () => ref
                              .read(galleryProvider.notifier)
                              .toggleFavorite(media[index].id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          media[index].isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              media[index].isFavorite
                                  ? Colors.red
                                  : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startSlideshow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SlideshowScreen(
              media:
                  collection.allMedia
                      .where((m) => m.type == MediaType.image)
                      .toList(),
            ),
      ),
    );
  }

  void _downloadCollection(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Download Collection'),
            content: const Text(
              'This will download all photos and videos from this collection to your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download started...')),
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...SortBy.values.map(
                  (sort) => ListTile(
                    title: Text(_getSortTitle(sort)),
                    onTap: () {
                      ref.read(galleryProvider.notifier).setSortBy(sort);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _toggleViewMode(WidgetRef ref) {
    final currentMode = ref.read(galleryProvider).viewMode;
    final nextMode =
        ViewMode.values[(ViewMode.values.indexOf(currentMode) + 1) %
            ViewMode.values.length];
    ref.read(galleryProvider.notifier).setViewMode(nextMode);
  }

  void _openPhotoPlayer(
    BuildContext context,
    List<MediaItem> media,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PhotoPlayerScreen(
              media: media.where((m) => m.type == MediaType.image).toList(),
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  String _getSortTitle(SortBy sort) {
    switch (sort) {
      case SortBy.newest:
        return 'Newest First';
      case SortBy.oldest:
        return 'Oldest First';
      case SortBy.popular:
        return 'Most Popular';
      case SortBy.name:
        return 'Name (A-Z)';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
