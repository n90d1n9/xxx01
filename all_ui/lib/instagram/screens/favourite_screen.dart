import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/media_item.dart';
import '../states/gallery_provider.dart';
import '../widgets/media_item_widget.dart';
import 'photo_player_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(galleryProvider);
    final favoriteMedia =
        galleryState.allMedia.where((item) => item.isFavorite).toList();

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
              _buildHeader(),
              Expanded(
                child:
                    favoriteMedia.isEmpty
                        ? _buildEmptyState()
                        : _buildFavoritesGrid(context, ref, favoriteMedia),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your loved moments',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.favorite, color: Colors.red, size: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.white.withOpacity(0.5),
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the heart icon on photos\nto add them here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    WidgetRef ref,
    List<MediaItem> favoriteMedia,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: favoriteMedia.length,
        itemBuilder: (context, index) {
          return MediaItemWidget(
            item: favoriteMedia[index],
            index: index,
            onTap: () {
              final imageMedia =
                  favoriteMedia
                      .where((m) => m.type == MediaType.image)
                      .toList();
              final imageIndex = imageMedia.indexWhere(
                (m) => m.id == favoriteMedia[index].id,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PhotoPlayerScreen(
                        media: imageMedia,
                        initialIndex: imageIndex >= 0 ? imageIndex : 0,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
