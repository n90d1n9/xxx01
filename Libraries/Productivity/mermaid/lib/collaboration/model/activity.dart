class Activity {
  final String id;
  final String userId;
  final String userName;
  final ActivityType type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const Activity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}

enum ActivityType {
  fieldAdded,
  fieldDeleted,
  fieldUpdated,
  commentAdded,
  userJoined,
  userLeft,
  formPublished,
}
