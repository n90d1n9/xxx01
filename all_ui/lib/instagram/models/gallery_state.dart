import 'event_collection.dart';
import 'media_item.dart';
import 'pagination.dart';

class GalleryState {
  final List<EventCollection> collections;
  final List<MediaItem> allMedia;
  final String? selectedCollectionId;
  final SortBy sortBy;
  final ViewMode viewMode;
  final bool isLoading;
  final String searchQuery;
  final List<String> selectedTags;

  GalleryState({
    required this.collections,
    required this.allMedia,
    this.selectedCollectionId,
    this.sortBy = SortBy.newest,
    this.viewMode = ViewMode.masonry,
    this.isLoading = true,
    this.searchQuery = '',
    this.selectedTags = const [],
  });

  GalleryState copyWith({
    List<EventCollection>? collections,
    List<MediaItem>? allMedia,
    String? selectedCollectionId,
    SortBy? sortBy,
    ViewMode? viewMode,
    bool? isLoading,
    String? searchQuery,
    List<String>? selectedTags,
  }) {
    return GalleryState(
      collections: collections ?? this.collections,
      allMedia: allMedia ?? this.allMedia,
      selectedCollectionId: selectedCollectionId ?? this.selectedCollectionId,
      sortBy: sortBy ?? this.sortBy,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}
