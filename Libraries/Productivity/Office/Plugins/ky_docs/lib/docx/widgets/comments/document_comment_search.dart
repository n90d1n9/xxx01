import '../../models/document_comment.dart';

/// Describes the thread status filter used by the comments panel.
enum DocumentCommentThreadFilter {
  open,
  resolved;

  bool accepts(DocumentComment comment) {
    return switch (this) {
      DocumentCommentThreadFilter.open => comment.isOpen,
      DocumentCommentThreadFilter.resolved => comment.resolved,
    };
  }
}

/// Builds searchable comment thread data for the comments panel.
class DocumentCommentSearchModel {
  final List<DocumentComment> comments;
  final String query;
  final DocumentCommentThreadFilter filter;

  const DocumentCommentSearchModel({
    required this.comments,
    required this.query,
    required this.filter,
  });

  bool get hasQuery => query.trim().isNotEmpty;

  List<DocumentComment> get visibleComments {
    return comments
        .where(filter.accepts)
        .where(_matchesQuery)
        .toList(growable: false);
  }

  int countFor(DocumentCommentThreadFilter threadFilter) {
    return comments.where(threadFilter.accepts).where(_matchesQuery).length;
  }

  String get emptyTitle {
    if (hasQuery) return 'No matching comments';
    return switch (filter) {
      DocumentCommentThreadFilter.open => 'No open comments',
      DocumentCommentThreadFilter.resolved => 'No resolved comments',
    };
  }

  String get emptyMessage {
    if (hasQuery) return 'Try another author, phrase, or anchor text.';
    return switch (filter) {
      DocumentCommentThreadFilter.open =>
        'Add a comment to start a discussion.',
      DocumentCommentThreadFilter.resolved =>
        'Resolved threads will appear here.',
    };
  }

  bool _matchesQuery(DocumentComment comment) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchableText = [
      comment.author,
      comment.text,
      ?comment.anchorText,
    ].join(' ').toLowerCase();

    return searchableText.contains(normalizedQuery);
  }
}
