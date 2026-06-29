enum StoryType { image, video, text }

class Story {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String mediaUrl;
  final StoryType type;
  final DateTime timestamp;
  final bool isViewed;
  final List<String> viewers;

  Story({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.mediaUrl,
    required this.type,
    required this.timestamp,
    this.isViewed = false,
    this.viewers = const [],
  });
}
