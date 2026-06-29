import 'timeline_view.dart';

class HistoricalEvent {
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final List<EventCategory> categories;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? articleUrl;
  final int popularity;
  final String location;
  final List<String> relatedEventIds;
  final Map<String, dynamic>? additionalData;
  final String? quote;
  final double lat;
  final double lng;
  final int impactScore;
  final List<String> tags;
  final String? sourceUrl;

  HistoricalEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.categories,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.articleUrl,
    required this.popularity,
    required this.location,
    this.relatedEventIds = const [],
    this.additionalData,
    this.quote,
    this.lat = 0.0,
    this.lng = 0.0,
    this.impactScore = 50,
    this.tags = const [],
    this.sourceUrl,
  });
}
