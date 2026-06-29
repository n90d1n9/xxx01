import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/legacy.dart';

import '../models/comment.dart';
import '../models/document_state.dart';
import '../models/document_stats.dart';

final documentControllerProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
      return DocumentNotifier();
    });

class DocumentNotifier extends StateNotifier<DocumentState> {
  Timer? _autoSaveTimer;

  DocumentNotifier()
    : super(
        DocumentState(
          controller: quill.QuillController.basic(),
          title: 'Untitled Document',
          lastModified: DateTime.now(),
          stats: DocumentStats(
            words: 0,
            characters: 0,
            charactersNoSpaces: 0,
            paragraphs: 0,
            readingTime: 0,
          ),
          documentId: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      ) {
    state.controller.addListener(_onDocumentChanged);
    _startAutoSave();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!state.isSaved) {
        saveDocument();
      }
    });
  }

  void _onDocumentChanged() {
    final text = state.controller.document.toPlainText();
    final stats = _calculateStats(text);

    state = state.copyWith(
      lastModified: DateTime.now(),
      isSaved: false,
      stats: stats,
    );
  }

  DocumentStats _calculateStats(String text) {
    final trimmed = text.trim();
    final words =
        trimmed.isEmpty
            ? 0
            : trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final characters = text.length;
    final charactersNoSpaces = text.replaceAll(RegExp(r'\s+'), '').length;
    final paragraphs =
        text.split('\n').where((p) => p.trim().isNotEmpty).length;
    final readingTime = (words / 200).ceil(); // Assuming 200 words per minute

    return DocumentStats(
      words: words,
      characters: characters,
      charactersNoSpaces: charactersNoSpaces,
      paragraphs: paragraphs,
      readingTime: readingTime,
    );
  }

  void updateTitle(String newTitle) {
    state = state.copyWith(
      title: newTitle,
      lastModified: DateTime.now(),
      isSaved: false,
    );
  }

  void saveDocument() {
    // Simulate save operation - in real app, save to database/cloud
    state = state.copyWith(isSaved: true);
    debugPrint('Document saved: ${state.documentId}');
  }

  void newDocument() {
    final newController = quill.QuillController.basic();
    newController.addListener(_onDocumentChanged);

    state = DocumentState(
      controller: newController,
      title: 'Untitled Document',
      lastModified: DateTime.now(),
      stats: DocumentStats(
        words: 0,
        characters: 0,
        charactersNoSpaces: 0,
        paragraphs: 0,
        readingTime: 0,
      ),
      documentId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  void insertBlock(String blockType) {
    final index = state.controller.selection.baseOffset;

    switch (blockType) {
      case 'heading1':
        state.controller.formatSelection(quill.Attribute.h1);
        break;
      case 'heading2':
        state.controller.formatSelection(quill.Attribute.h2);
        break;
      case 'heading3':
        state.controller.formatSelection(quill.Attribute.h3);
        break;
      case 'bullet':
        state.controller.formatSelection(quill.Attribute.ul);
        break;
      case 'numbered':
        state.controller.formatSelection(quill.Attribute.ol);
        break;
      case 'quote':
        state.controller.formatSelection(quill.Attribute.blockQuote);
        break;
      case 'code':
        state.controller.formatSelection(quill.Attribute.codeBlock);
        break;
      case 'divider':
        state.controller.document.insert(index, '\n───────────────────────\n');
        break;
      case 'table':
        state.controller.document.insert(
          index,
          '\n| Column 1 | Column 2 | Column 3 |\n|----------|----------|----------|\n| Cell 1   | Cell 2   | Cell 3   |\n',
        );
        break;
      case 'callout':
        state.controller.document.insert(index, '\n💡 Callout: ');
        break;
      case 'checkbox':
        state.controller.document.insert(index, '\n☐ ');
        break;
    }
  }

  void addComment(String text) {
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: 'Current User',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(comments: [...state.comments, comment]);
  }

  String exportToJson() {
    return jsonEncode(state.controller.document.toDelta().toJson());
  }

  String exportToMarkdown() {
    return state.controller.document.toPlainText();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    state.controller.removeListener(_onDocumentChanged);
    state.controller.dispose();
    super.dispose();
  }

  void loadFromTemplate(String content) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(content));
      final newController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      newController.addListener(_onDocumentChanged);

      state = state.copyWith(
        controller: newController,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error loading template: $e');
    }
  }
}
