import 'dart:io';

import 'package:path/path.dart' as path;

import '../../schema/common/ai_agen_builder_model.dart';
import 'template_engine.dart';

abstract class CodeGenerator {
  final TemplateEngine templateEngine;
  final String outputDirectory;

  CodeGenerator({required this.templateEngine, required this.outputDirectory});

  Future<Map<String, String>> generate(AIAgentBuilderModel model);

  Future<void> writeToFiles(Map<String, String> files) async {
    for (final entry in files.entries) {
      final filePath = path.join(outputDirectory, entry.key);
      final file = File(filePath);

      await file.parent.create(recursive: true);
      await file.writeAsString(entry.value);
      print('Generated: $filePath');
    }
  }
}
