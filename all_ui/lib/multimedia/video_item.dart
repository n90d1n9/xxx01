// Video model
class VideoItem {
  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final Duration duration;
  final int likes;
  final int views;

  VideoItem({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.duration,
    required this.likes,
    required this.views,
  });
}
