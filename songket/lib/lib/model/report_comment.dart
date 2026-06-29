class ReportComment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final String? cellReference; // e.g., "row:5,col:3"
  final List<String>? mentions;

  ReportComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.cellReference,
    this.mentions,
  });
}
