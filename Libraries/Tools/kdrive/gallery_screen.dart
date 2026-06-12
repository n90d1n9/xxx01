// lib/screens/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _fullscreenIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFiles = ref.watch(filesNotifierProvider);
    final images = allFiles.where((f) => f.type == FileType.image && !f.isTrashed).toList();
    final videos = allFiles.where((f) => f.type == FileType.video && !f.isTrashed).toList();
    final media = [...images, ...videos]
      ..sort((a, b) => b.dateModified.compareTo(a.dateModified));

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: _fullscreenIndex != null ? Colors.black : colorScheme.surface,
      appBar: _fullscreenIndex != null
          ? AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(
                media[_fullscreenIndex!].name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showMediaInfo(context, media[_fullscreenIndex!]),
                  icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                ),
              ],
            )
          : AppBar(
              title: const Text('Gallery'),
              backgroundColor: colorScheme.surface,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'All (${media.length})'),
                  Tab(text: 'Photos (${images.length})'),
                  Tab(text: 'Videos (${videos.length})'),
                ],
              ),
            ),
      body: _fullscreenIndex != null
          ? _FullscreenViewer(
              files: media,
              initialIndex: _fullscreenIndex!,
              onClose: () => setState(() => _fullscreenIndex = null),
              onIndexChanged: (i) => setState(() => _fullscreenIndex = i),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _GalleryGrid(files: media, onTap: (i) => setState(() => _fullscreenIndex = i)),
                _GalleryGrid(files: images, onTap: (i) => setState(() => _fullscreenIndex = i)),
                _GalleryGrid(files: videos, onTap: (i) => setState(() => _fullscreenIndex = i)),
              ],
            ),
    );
  }

  void _showMediaInfo(BuildContext context, FileItem file) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(file.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            _InfoRow('Type', FileUtils.getFileTypeName(file.type)),
            _InfoRow('Size', file.displaySize),
            _InfoRow('Modified', FileUtils.formatFullDate(file.dateModified)),
            _InfoRow('Created', FileUtils.formatFullDate(file.dateCreated)),
            if (file.isStarred)
              _InfoRow('Starred', 'Yes'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(filesNotifierProvider.notifier).toggleStar(file.id);
                      Navigator.pop(ctx);
                    },
                    icon: Icon(file.isStarred
                      ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: file.isStarred ? Colors.amber : null),
                    label: Text(file.isStarred ? 'Unstar' : 'Star'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
          Expanded(child: Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}

// ─── Gallery Grid ─────────────────────────────────────────────────────────────

class _GalleryGrid extends ConsumerWidget {
  final List<FileItem> files;
  final ValueChanged<int> onTap;
  const _GalleryGrid({required this.files, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (files.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 56,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('No media files',
              style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: files.length,
      itemBuilder: (_, i) {
        final file = files[i];
        final color = FileUtils.getFileColor(file.type);
        return GestureDetector(
          onTap: () => onTap(i),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: color.withOpacity(0.08),
                child: Icon(
                  FileUtils.getFileIcon(file.type),
                  color: color.withOpacity(0.6),
                  size: 40,
                ),
              ),
              // Video badge
              if (file.type == FileType.video)
                Positioned(
                  bottom: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 10),
                        Text('VIDEO', style: TextStyle(color: Colors.white, fontSize: 8,
                          fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              // Star badge
              if (file.isStarred)
                Positioned(
                  top: 6, right: 6,
                  child: Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 14),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Fullscreen Viewer ────────────────────────────────────────────────────────

class _FullscreenViewer extends StatefulWidget {
  final List<FileItem> files;
  final int initialIndex;
  final VoidCallback onClose;
  final ValueChanged<int> onIndexChanged;

  const _FullscreenViewer({
    required this.files,
    required this.initialIndex,
    required this.onClose,
    required this.onIndexChanged,
  });

  @override
  State<_FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends State<_FullscreenViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.files.length,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
              widget.onIndexChanged(i);
            },
            itemBuilder: (_, i) {
              final file = widget.files[i];
              final color = FileUtils.getFileColor(file.type);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(FileUtils.getFileIcon(file.type), size: 80, color: color),
                    ),
                    const SizedBox(height: 24),
                    Text(file.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('${file.displaySize} · ${FileUtils.formatDate(file.dateModified)}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              );
            },
          ),

          // Prev/Next buttons
          if (_currentIndex > 0)
            Positioned(
              left: 12,
              top: 0, bottom: 0,
              child: Center(
                child: _NavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut),
                ),
              ),
            ),
          if (_currentIndex < widget.files.length - 1)
            Positioned(
              right: 12,
              top: 0, bottom: 0,
              child: Center(
                child: _NavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut),
                ),
              ),
            ),

          // Counter
          Positioned(
            bottom: 32,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.files.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
