
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  
  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });
}



// Model for Task Comments
class TaskComment {
  final String id;
  final String authorName;
  final String text;
  final DateTime timestamp;

  TaskComment({
    required this.id,
    required this.authorName,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}