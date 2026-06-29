import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/media_item.dart';
import '../states/gallery_provider.dart';

class PhotoPlayerScreen extends ConsumerStatefulWidget {
  final List<MediaItem> media;
  final int initialIndex;

  const PhotoPlayerScreen({
    super.key,
    required this.media,
    required this.initialIndex,
  });

  @override
  ConsumerState<PhotoPlayerScreen> createState() => _PhotoPlayerScreenState();
}

class _PhotoPlayerScreenState extends ConsumerState<PhotoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.media.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.media[index].url,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: widget.media[index].id,
                ),
              );
            },
          ),
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _buildTopBar(),
          ),
          AnimatedOpacity(
            opacity: _showUI ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _buildBottomBar(),
          ),
          GestureDetector(
            onTap: () => setState(() => _showUI = !_showUI),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
            const Spacer(),
            Text(
              '${_currentIndex + 1} of ${widget.media.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _sharePhoto(),
              icon: const Icon(Icons.share, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final currentPhoto = widget.media[_currentIndex];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.media.length > 1)
              Container(
                height: 8,
                margin: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.media.length,
                    effect: WormEffect(
                      dotColor: Colors.white.withOpacity(0.3),
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPhoto.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${currentPhoto.author}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      if (currentPhoto.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentPhoto.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _toggleFavorite(currentPhoto.id),
                      icon: Icon(
                        currentPhoto.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            currentPhoto.isFavorite ? Colors.red : Colors.white,
                        size: 28,
                      ),
                    ),
                    Text(
                      '${currentPhoto.likes}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _downloadPhoto(),
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method
  void _toggleFavorite(String mediaId) {
    ref.read(galleryProvider.notifier).toggleFavorite(mediaId);
  }

  void _sharePhoto() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing photo...')));
  }

  void _downloadPhoto() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Photo saved to gallery')));
  }
}
