import 'comment_reply.dart';

class Comment {
  final String id;
  final String text;
  final String author;
  final DateTime timestamp;
  final List<CommentReply> replies;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
    this.replies = const [],
  });
}
