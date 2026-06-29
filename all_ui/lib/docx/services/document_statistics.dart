import 'package:flutter_quill/flutter_quill.dart' as quill;

class DocumentStatistics {
  final quill.QuillController controller;

  DocumentStatistics(this.controller);

  int get wordCount {
    final text = controller.document.toPlainText().trim();
    return text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  int get characterCount => controller.document.toPlainText().length;

  int get characterCountNoSpaces {
    return controller.document
        .toPlainText()
        .replaceAll(RegExp(r'\s'), '')
        .length;
  }

  int get paragraphCount {
    return controller.document
        .toPlainText()
        .split('\n')
        .where((p) => p.trim().isNotEmpty)
        .length;
  }

  int get sentenceCount {
    final text = controller.document.toPlainText();
    return RegExp(r'[.!?]+').allMatches(text).length;
  }

  Duration get estimatedReadingTime {
    // Average reading speed: 200 words per minute
    final minutes = (wordCount / 200).ceil();
    return Duration(minutes: minutes.clamp(1, 999));
  }
}
