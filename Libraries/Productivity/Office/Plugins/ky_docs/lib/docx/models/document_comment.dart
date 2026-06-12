/// A discussion note anchored to a specific document offset.
class DocumentComment {
  final String id;
  final String author;
  final String text;
  final int offset;
  final String? anchorText;
  final DateTime createdAt;
  final bool resolved;

  const DocumentComment({
    required this.id,
    required this.author,
    required this.text,
    required this.offset,
    required this.createdAt,
    this.anchorText,
    this.resolved = false,
  });

  bool get isOpen => !resolved;

  DocumentComment copyWith({
    String? id,
    String? author,
    String? text,
    int? offset,
    String? anchorText,
    bool clearAnchorText = false,
    DateTime? createdAt,
    bool? resolved,
  }) {
    return DocumentComment(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      offset: offset ?? this.offset,
      anchorText: clearAnchorText ? null : (anchorText ?? this.anchorText),
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
    );
  }
}
