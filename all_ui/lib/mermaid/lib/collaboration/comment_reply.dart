class CommentReply {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const CommentReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });
}
