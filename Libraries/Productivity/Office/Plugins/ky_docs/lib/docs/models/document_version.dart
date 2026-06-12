class DocumentVersion {
  final String id;
  final String title;
  final DateTime timestamp;
  final String author;
  final String content;
  final String description;

  DocumentVersion({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.author,
    required this.content,
    required this.description,
  });
}
