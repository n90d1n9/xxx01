class MessageReaction {
  final String emoji;
  final String userId;
  final String userName;
  final DateTime timestamp;

  MessageReaction({
    required this.emoji,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });
}
