// lib/core/providers/gallery_providers.dart
//
// Central Riverpod providers.
// Manages: folder list, current folder, items page, selection,
//          filters, indexing progress, search, view mode.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bridge/gallery_bridge.dart';
import '../models/gallery_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Engine init
// ─────────────────────────────────────────────────────────────────────────────

/// Completes once the Rust engine is initialized.
final engineInitProvider = FutureProvider<void>((ref) async {
  await GalleryBridge.init();
});

// ─────────────────────────────────────────────────────────────────────────────
// Folder list
// ─────────────────────────────────────────────────────────────────────────────

class FolderListNotifier extends AsyncNotifier<List<GFolder>> {
  @override
  Future<List<GFolder>> build() => GalleryBridge.listFolders();

  Future<void> addFolder(String path) async {
    await GalleryBridge.addFolder(path);
    ref.invalidateSelf();
  }

  Future<void> removeFolder(int folderId) async {
    await GalleryBridge.removeFolder(folderId);
    ref.invalidateSelf();
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

final folderListProvider =
    AsyncNotifierProvider<FolderListNotifier, List<GFolder>>(
        FolderListNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Current folder selection
// ─────────────────────────────────────────────────────────────────────────────

final currentFolderIdProvider = StateProvider<int?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Filters
// ─────────────────────────────────────────────────────────────────────────────

class GalleryFilter {
  final int? flagFilter;     // null=all, 0=unflagged, 1=picked, 2=rejected
  final int? ratingMin;      // null=any, 1..5
  final String? colorLabel;  // null=any, "red"|"yellow"|etc.
  final String? searchQuery;

  const GalleryFilter({
    this.flagFilter,
    this.ratingMin,
    this.colorLabel,
    this.searchQuery,
  });

  GalleryFilter copyWith({
    Object? flagFilter = _sentinel,
    Object? ratingMin = _sentinel,
    Object? colorLabel = _sentinel,
    Object? searchQuery = _sentinel,
  }) =>
      GalleryFilter(
        flagFilter:   flagFilter  == _sentinel ? this.flagFilter  : flagFilter  as int?,
        ratingMin:    ratingMin   == _sentinel ? this.ratingMin   : ratingMin   as int?,
        colorLabel:   colorLabel  == _sentinel ? this.colorLabel  : colorLabel  as String?,
        searchQuery:  searchQuery == _sentinel ? this.searchQuery : searchQuery as String?,
      );

  bool get isActive =>
      flagFilter != null ||
      ratingMin != null ||
      colorLabel != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

const _sentinel = Object();

final galleryFilterProvider = StateProvider<GalleryFilter>(
  (ref) => const GalleryFilter(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Media items (paginated, filtered)
// ─────────────────────────────────────────────────────────────────────────────

const int _pageSize = 200;

class MediaItemsNotifier extends AsyncNotifier<List<GMediaItem>> {
  @override
  Future<List<GMediaItem>> build() async {
    final folderId = ref.watch(currentFolderIdProvider);
    final filter   = ref.watch(galleryFilterProvider);

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      return GalleryBridge.searchMediaItems(filter.searchQuery!, 500);
    }

    return GalleryBridge.listMediaItems(
      folderId: folderId,
      flagFilter: filter.flagFilter,
      ratingMin: filter.ratingMin,
      colorLabel: filter.colorLabel,
      pageSize: _pageSize,
      pageIndex: 0,
    );
  }

  Future<void> loadMore(int pageIndex) async {
    final folderId = ref.read(currentFolderIdProvider);
    final filter   = ref.read(galleryFilterProvider);
    final more = await GalleryBridge.listMediaItems(
      folderId: folderId,
      flagFilter: filter.flagFilter,
      ratingMin: filter.ratingMin,
      colorLabel: filter.colorLabel,
      pageSize: _pageSize,
      pageIndex: pageIndex,
    );
    state = AsyncData([...?state.valueOrNull, ...more]);
  }

  void updateItem(GMediaItem updated) {
    final items = state.valueOrNull;
    if (items == null) return;
    final idx = items.indexWhere((i) => i.id == updated.id);
    if (idx == -1) return;
    final copy = [...items];
    copy[idx] = updated;
    state = AsyncData(copy);
  }

  void prependItem(GMediaItem item) {
    state = AsyncData([item, ...?state.valueOrNull]);
  }

  Future<void> refresh() => build().then((v) => state = AsyncData(v));
}

final mediaItemsProvider =
    AsyncNotifierProvider<MediaItemsNotifier, List<GMediaItem>>(
        MediaItemsNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Selection
// ─────────────────────────────────────────────────────────────────────────────

class SelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void selectOnly(int id) => state = {id};

  void addRange(List<int> ids) => state = {...state, ...ids};

  void clear() => state = {};

  void selectAll(List<int> ids) => state = ids.toSet();
}

final selectionProvider =
    NotifierProvider<SelectionNotifier, Set<int>>(SelectionNotifier.new);

/// The single "active" item (last clicked, shown in detail panel).
final activeItemIdProvider = StateProvider<int?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// View mode
// ─────────────────────────────────────────────────────────────────────────────

enum ViewMode { grid, list, filmstrip }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

// Grid thumbnail size (cross-axis count)
final gridColumnsProvider = StateProvider<int>((ref) => 5);

// ─────────────────────────────────────────────────────────────────────────────
// Indexing progress
// ─────────────────────────────────────────────────────────────────────────────

class IndexingState {
  final bool isIndexing;
  final String? currentFolder;
  final int indexed;
  final int total;
  final String? currentFile;
  final List<String> warnings;

  const IndexingState({
    this.isIndexing = false,
    this.currentFolder,
    this.indexed = 0,
    this.total = 0,
    this.currentFile,
    this.warnings = const [],
  });

  double get progress => total > 0 ? indexed / total : 0;

  IndexingState copyWith({
    bool? isIndexing,
    String? currentFolder,
    int? indexed,
    int? total,
    String? currentFile,
    List<String>? warnings,
  }) =>
      IndexingState(
        isIndexing:    isIndexing    ?? this.isIndexing,
        currentFolder: currentFolder ?? this.currentFolder,
        indexed:       indexed       ?? this.indexed,
        total:         total         ?? this.total,
        currentFile:   currentFile   ?? this.currentFile,
        warnings:      warnings      ?? this.warnings,
      );
}

class IndexingNotifier extends Notifier<IndexingState> {
  Timer? _pollTimer;

  @override
  IndexingState build() => const IndexingState();

  Future<void> startIndexing(String folderPath, String thumbCacheDir) async {
    state = IndexingState(isIndexing: true, currentFolder: folderPath);

    await GalleryBridge.startIndexing(
      folderPath: folderPath,
      thumbnailCacheDir: thumbCacheDir,
      forceReindex: false,
      generateThumbnails: true,
    );

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 150), (_) async {
      final events = await GalleryBridge.pollIndexEvents();
      for (final e in events) {
        _handleEvent(e);
      }
    });
  }

  void _handleEvent(GIndexEvent e) {
    switch (e.kind) {
      case 'progress':
        state = state.copyWith(
          indexed: e.indexed ?? state.indexed,
          total: e.total ?? state.total,
          currentFile: e.currentFile,
        );
      case 'item_ready':
        // Trigger a media list refresh to show new items incrementally
        if (e.itemId != null) {
          _refreshItem(e.itemId!);
        }
      case 'completed':
        state = state.copyWith(isIndexing: false);
        _pollTimer?.cancel();
        ref.read(folderListProvider.notifier).refresh();
        ref.read(mediaItemsProvider.notifier).refresh();
      case 'warning':
        if (e.message != null) {
          state = state.copyWith(
            warnings: [...state.warnings, e.message!],
          );
        }
      case 'error':
        state = state.copyWith(isIndexing: false);
        _pollTimer?.cancel();
    }
  }

  void _refreshItem(int itemId) async {
    final item = await GalleryBridge.getMediaItem(itemId);
    if (item != null) {
      ref.read(mediaItemsProvider.notifier).prependItem(item);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final indexingProvider =
    NotifierProvider<IndexingNotifier, IndexingState>(IndexingNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Active item EXIF (lazy-loaded)
// ─────────────────────────────────────────────────────────────────────────────

final activeExifProvider = FutureProvider<GExifData?>((ref) async {
  final id = ref.watch(activeItemIdProvider);
  if (id == null) return null;
  return GalleryBridge.getExifData(id);
});

// Stats
final galleryStatsProvider = FutureProvider<GGalleryStats>((ref) async {
  ref.watch(mediaItemsProvider); // re-fetch after items change
  return GalleryBridge.getGalleryStats();
});
