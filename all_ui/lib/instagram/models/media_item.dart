enum MediaType { image, video }

class MediaItem {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String title;
  final String author;
  final int likes;
  final int views;
  final MediaType type;
  final String category;
  final double aspectRatio;
  final DateTime capturedAt;
  final String? description;
  final List<String> tags;
  final String eventId;
  final bool isFavorite;
  final String originalFileName;

  MediaItem({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.type,
    required this.category,
    required this.aspectRatio,
    required this.capturedAt,
    required this.eventId,
    this.description,
    this.tags = const [],
    this.isFavorite = false,
    required this.originalFileName,
  });

  MediaItem copyWith({bool? isFavorite, int? likes, int? views}) {
    return MediaItem(
      id: id,
      url: url,
      thumbnailUrl: thumbnailUrl,
      title: title,
      author: author,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      type: type,
      category: category,
      aspectRatio: aspectRatio,
      capturedAt: capturedAt,
      eventId: eventId,
      description: description,
      tags: tags,
      isFavorite: isFavorite ?? this.isFavorite,
      originalFileName: originalFileName,
    );
  }
}
