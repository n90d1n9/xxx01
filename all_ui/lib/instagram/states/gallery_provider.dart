import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_collection.dart';
import '../models/gallery_state.dart';
import '../models/media_item.dart';
import '../models/pagination.dart';

final galleryProvider = StateNotifierProvider<GalleryNotifier, GalleryState>(
  (ref) => GalleryNotifier(),
);

class GalleryNotifier extends StateNotifier<GalleryState> {
  GalleryNotifier()
    : super(GalleryState(collections: [], allMedia: [], isLoading: true)) {
    _loadCollections();
  }

  void _loadCollections() {
    Future.delayed(const Duration(seconds: 2), () {
      final collections = _generateDummyCollections();
      final allMedia =
          collections.expand((collection) => collection.allMedia).toList();

      state = state.copyWith(
        collections: collections,
        allMedia: allMedia,
        isLoading: false,
      );
    });
  }

  void selectCollection(String? collectionId) {
    state = state.copyWith(selectedCollectionId: collectionId);
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setViewMode(ViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleTag(String tag) {
    final tags = List<String>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
  }

  void toggleFavorite(String mediaId) {
    final updatedMedia =
        state.allMedia.map((item) {
          if (item.id == mediaId) {
            return item.copyWith(isFavorite: !item.isFavorite);
          }
          return item;
        }).toList();

    final updatedCollections =
        state.collections.map((collection) {
          final updatedPhotos =
              collection.photos.map((photo) {
                if (photo.id == mediaId) {
                  return photo.copyWith(isFavorite: !photo.isFavorite);
                }
                return photo;
              }).toList();

          final updatedVideos =
              collection.videos.map((video) {
                if (video.id == mediaId) {
                  return video.copyWith(isFavorite: !video.isFavorite);
                }
                return video;
              }).toList();

          return EventCollection(
            id: collection.id,
            title: collection.title,
            description: collection.description,
            coverImageUrl: collection.coverImageUrl,
            eventDate: collection.eventDate,
            location: collection.location,
            photos: updatedPhotos,
            videos: updatedVideos,
            photographer: collection.photographer,
            totalItems: collection.totalItems,
            status: collection.status,
            tags: collection.tags,
          );
        }).toList();

    state = state.copyWith(
      allMedia: updatedMedia,
      collections: updatedCollections,
    );
  }

  List<MediaItem> getFilteredMedia() {
    List<MediaItem> media;

    if (state.selectedCollectionId != null) {
      final collection = state.collections.firstWhere(
        (c) => c.id == state.selectedCollectionId,
      );
      media = collection.allMedia;
    } else {
      media = state.allMedia;
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      media =
          media
              .where(
                (item) =>
                    item.title.toLowerCase().contains(
                      state.searchQuery.toLowerCase(),
                    ) ||
                    item.description?.toLowerCase().contains(
                          state.searchQuery.toLowerCase(),
                        ) ==
                        true ||
                    item.tags.any(
                      (tag) => tag.toLowerCase().contains(
                        state.searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();
    }

    // Apply tag filter
    if (state.selectedTags.isNotEmpty) {
      media =
          media
              .where(
                (item) =>
                    state.selectedTags.every((tag) => item.tags.contains(tag)),
              )
              .toList();
    }

    // Apply sorting
    switch (state.sortBy) {
      case SortBy.newest:
        media.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
        break;
      case SortBy.oldest:
        media.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
        break;
      case SortBy.popular:
        media.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case SortBy.name:
        media.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return media;
  }

  List<EventCollection> getFilteredCollections() {
    return state.collections.where((collection) {
      if (state.searchQuery.isEmpty) return true;

      return collection.title.toLowerCase().contains(
            state.searchQuery.toLowerCase(),
          ) ||
          collection.description.toLowerCase().contains(
            state.searchQuery.toLowerCase(),
          ) ||
          collection.location.toLowerCase().contains(
            state.searchQuery.toLowerCase(),
          ) ||
          collection.tags.any(
            (tag) =>
                tag.toLowerCase().contains(state.searchQuery.toLowerCase()),
          );
    }).toList();
  }

  List<EventCollection> _generateDummyCollections() {
    final random = math.Random();

    return [
      EventCollection(
        id: '1',
        title: 'Summer Music Festival 2024',
        description:
            'An amazing three-day music festival featuring top artists from around the world.',
        coverImageUrl: 'https://picsum.photos/800/600?random=1',
        eventDate: DateTime(2024, 7, 15),
        location: 'Central Park, New York',
        photographer: 'Alex Chen',
        totalItems: 45,
        status: EventStatus.completed,
        tags: ['music', 'festival', 'summer', 'outdoor'],
        photos: List.generate(
          30,
          (index) => _generateMediaItem('1', index, MediaType.image),
        ),
        videos: List.generate(
          15,
          (index) => _generateMediaItem('1', index + 30, MediaType.video),
        ),
      ),
      EventCollection(
        id: '2',
        title: 'Corporate Annual Gala',
        description:
            'Elegant corporate event celebrating company achievements and milestones.',
        coverImageUrl: 'https://picsum.photos/800/600?random=2',
        eventDate: DateTime(2024, 9, 20),
        location: 'Grand Ballroom, Hotel Plaza',
        photographer: 'Sarah Johnson',
        totalItems: 28,
        status: EventStatus.completed,
        tags: ['corporate', 'gala', 'formal', 'indoor'],
        photos: List.generate(
          20,
          (index) => _generateMediaItem('2', index, MediaType.image),
        ),
        videos: List.generate(
          8,
          (index) => _generateMediaItem('2', index + 20, MediaType.video),
        ),
      ),
      EventCollection(
        id: '3',
        title: 'Beach Wedding Ceremony',
        description:
            'Romantic beach wedding with stunning sunset views and intimate moments.',
        coverImageUrl: 'https://picsum.photos/800/600?random=3',
        eventDate: DateTime(2024, 6, 10),
        location: 'Malibu Beach, California',
        photographer: 'Emma Rodriguez',
        totalItems: 65,
        status: EventStatus.completed,
        tags: ['wedding', 'beach', 'sunset', 'romantic'],
        photos: List.generate(
          50,
          (index) => _generateMediaItem('3', index, MediaType.image),
        ),
        videos: List.generate(
          15,
          (index) => _generateMediaItem('3', index + 50, MediaType.video),
        ),
      ),
      EventCollection(
        id: '4',
        title: 'Tech Conference 2024',
        description:
            'Leading technology conference showcasing innovations and future trends.',
        coverImageUrl: 'https://picsum.photos/800/600?random=4',
        eventDate: DateTime(2024, 11, 5),
        location: 'Convention Center, San Francisco',
        photographer: 'Michael Kim',
        totalItems: 38,
        status: EventStatus.upcoming,
        tags: ['technology', 'conference', 'innovation', 'business'],
        photos: List.generate(
          25,
          (index) => _generateMediaItem('4', index, MediaType.image),
        ),
        videos: List.generate(
          13,
          (index) => _generateMediaItem('4', index + 25, MediaType.video),
        ),
      ),
    ];
  }

  MediaItem _generateMediaItem(String eventId, int index, MediaType type) {
    final random = math.Random();
    final imageId = random.nextInt(1000) + 1;

    return MediaItem(
      id: '${eventId}_${index}',
      url: 'https://picsum.photos/800/600?random=$imageId',
      thumbnailUrl: 'https://picsum.photos/400/300?random=$imageId',
      title:
          type == MediaType.image ? 'Photo ${index + 1}' : 'Video ${index + 1}',
      author:
          ['Alex Chen', 'Sarah Johnson', 'Emma Rodriguez', 'Michael Kim'][random
              .nextInt(4)],
      likes: random.nextInt(500) + 50,
      views: random.nextInt(2000) + 100,
      type: type,
      category: ['portrait', 'landscape', 'candid', 'group'][random.nextInt(4)],
      aspectRatio: [0.67, 0.75, 1.0, 1.33, 1.5][random.nextInt(5)],
      capturedAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      eventId: eventId,
      description: 'Beautiful moment captured during the event.',
      tags: ['moment', 'beautiful', 'memory', 'event'],
      originalFileName: 'IMG_${1000 + index}.jpg',
    );
  }
}
