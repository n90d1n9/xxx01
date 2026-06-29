import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media_item.dart';

class SlideshowScreen extends StatefulWidget {
  final List<MediaItem> media;

  const SlideshowScreen({super.key, required this.media});

  @override
  State<SlideshowScreen> createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _transitionController;
  int _currentIndex = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transitionController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _startSlideshow();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _startSlideshow() {
    if (_isPlaying && widget.media.isNotEmpty) {
      _transitionController.reset();
      _transitionController.forward().then((_) {
        if (mounted && _isPlaying) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.media.length;
          });
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _startSlideshow();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transitionController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.media.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.media[index].url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  '${_currentIndex + 1} / ${widget.media.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() => _isPlaying = !_isPlaying);
                    if (_isPlaying) {
                      _startSlideshow();
                    } else {
                      _transitionController.stop();
                    }
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _transitionController.value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.media[_currentIndex].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
