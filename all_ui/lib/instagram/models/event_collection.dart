import 'media_item.dart';

enum EventStatus { upcoming, ongoing, completed }

class EventCollection {
  final String id;
  final String title;
  final String description;
  final String coverImageUrl;
  final DateTime eventDate;
  final String location;
  final List<MediaItem> photos;
  final List<MediaItem> videos;
  final String photographer;
  final int totalItems;
  final EventStatus status;
  final List<String> tags;

  EventCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.eventDate,
    required this.location,
    required this.photos,
    required this.videos,
    required this.photographer,
    required this.totalItems,
    required this.status,
    required this.tags,
  });

  List<MediaItem> get allMedia => [...photos, ...videos];
}
