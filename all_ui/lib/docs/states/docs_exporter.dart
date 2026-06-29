// Extension to help with .syirkah format
import 'dart:convert';

import 'package:flutter/material.dart';

import 'docs_provider.dart';

extension DocumentExporter on DocumentNotifier {
  Map<String, dynamic> exportToSyirkah() {
    return {
      'version': '1.0.0',
      'format': 'syirkah',
      'documentId': state.documentId,
      'metadata': {
        'title': state.title,
        'created': DateTime.now().toIso8601String(),
        'modified': state.lastModified.toIso8601String(),
        'author': state.currentUserId,
        'stats': {
          'words': state.stats.words,
          'characters': state.stats.characters,
          'paragraphs': state.stats.paragraphs,
        },
      },
      'content': jsonDecode(exportToJson()),
      'comments':
          state.comments
              .map(
                (c) => {
                  'id': c.id,
                  'text': c.text,
                  'author': c.author,
                  'timestamp': c.timestamp.toIso8601String(),
                },
              )
              .toList(),
    };
  }

  void importFromSyirkah(Map<String, dynamic> data) {
    try {
      if (data['format'] != 'syirkah') {
        throw Exception('Invalid format');
      }

      final metadata = data['metadata'] as Map<String, dynamic>;
      final content = jsonEncode(data['content']);

      loadFromTemplate(content);
      updateTitle(metadata['title'] as String);

      debugPrint('Imported from .syirkah: ${metadata['title']}');
    } catch (e) {
      debugPrint('Error importing .syirkah: $e');
    }
  }
}
