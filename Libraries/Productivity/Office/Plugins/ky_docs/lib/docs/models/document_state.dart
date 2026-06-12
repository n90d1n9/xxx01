import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'comment.dart';
import 'document_stats.dart';

class DocumentState {
  final quill.QuillController controller;
  final String title;
  final DateTime lastModified;
  final bool isSaved;
  final DocumentStats stats;
  final List<Comment> comments;
  final String documentId;

  final String currentUserId;

  DocumentState({
    required this.controller,
    required this.title,
    required this.lastModified,
    this.isSaved = true,
    required this.stats,
    this.comments = const [],
    required this.documentId,
    this.currentUserId = 'user_1',
  });

  DocumentState copyWith({
    quill.QuillController? controller,
    String? title,
    DateTime? lastModified,
    bool? isSaved,
    DocumentStats? stats,
    List<Comment>? comments,
    String? documentId,
    String? currentUserId,
  }) {
    return DocumentState(
      controller: controller ?? this.controller,
      title: title ?? this.title,
      lastModified: lastModified ?? this.lastModified,
      isSaved: isSaved ?? this.isSaved,
      stats: stats ?? this.stats,
      comments: comments ?? this.comments,
      documentId: documentId ?? this.documentId,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}
