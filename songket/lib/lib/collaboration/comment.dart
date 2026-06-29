import 'comment_reply.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String fieldId;
  final String text;
  final DateTime createdAt;
  final List<String> mentions;
  final bool isResolved;
  final List<CommentReply> replies;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.fieldId,
    required this.text,
    required this.createdAt,
    this.mentions = const [],
    this.isResolved = false,
    this.replies = const [],
  });
}
