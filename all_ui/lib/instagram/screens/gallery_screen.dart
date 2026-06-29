import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../models/media_item.dart';
import '../states/gallery_provider.dart';
import '../widgets/media_item_widget.dart';
import 'photo_player_screen.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(galleryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(ref),
              _buildSearchAndFilters(ref),
              Expanded(
                child:
                    galleryState.isLoading
                        ? _buildLoadingGrid()
                        : _buildMediaGrid(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All your memories in one place',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showViewOptions(ref),
            icon: const Icon(Icons.tune, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextField(
              onChanged:
                  (query) =>
                      ref.read(galleryProvider.notifier).setSearchQuery(query),
              decoration: InputDecoration(
                hintText: 'Search photos and videos...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.2),
            child: Container(
              height: (index % 3 + 2) * 80.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaGrid(WidgetRef ref) {
    final media = ref.read(galleryProvider.notifier).getFilteredMedia();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: media.length,
        itemBuilder: (context, index) {
          return MediaItemWidget(
            item: media[index],
            index: index,
            onTap: () => _openPhotoPlayer(context, media, index),
          );
        },
      ),
    );
  }

  void _showViewOptions(WidgetRef ref) {
    // Implementation for view options
  }

  void _openPhotoPlayer(
    BuildContext context,
    List<MediaItem> media,
    int initialIndex,
  ) {
    final imageMedia = media.where((m) => m.type == MediaType.image).toList();
    final imageIndex = imageMedia.indexWhere(
      (m) => m.id == media[initialIndex].id,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PhotoPlayerScreen(
              media: imageMedia,
              initialIndex: imageIndex >= 0 ? imageIndex : 0,
            ),
      ),
    );
  }
}
