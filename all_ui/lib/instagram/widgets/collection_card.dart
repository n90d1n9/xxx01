import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/event_collection.dart';
import '../models/media_item.dart';
import '../models/pagination.dart';
import '../screens/photo_player_screen.dart';
import '../screens/slide_show_screen.dart';
import '../states/gallery_provider.dart';
import '../utils/helper.dart';

class CollectionCard extends StatelessWidget {
  final EventCollection collection;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: collection.coverImageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(
                          collection.status,
                        ).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        collection.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${collection.totalItems} items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    collection.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          collection.location,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(collection.eventDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'by ${collection.photographer}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
