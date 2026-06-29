import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../model/plugin_definition.dart';

class PluginExportService {
  Future<void> exportToFile(PluginDefinition plugin, String path) async {
    final json = const JsonEncoder.withIndent('  ').convert(plugin.toJson());
    final file = File(path);
    await file.writeAsString(json);
  }

  Future<void> exportAndDownload(
    PluginDefinition plugin,
    BuildContext context,
  ) async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert(plugin.toJson());

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: json));

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${plugin.id}.json';
      final file = File(filePath);
      await file.writeAsString(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Plugin exported to $filePath\nDefinition copied to clipboard!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OPEN',
              onPressed: () {
                // Open file location
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<PluginDefinition?> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return PluginDefinition.fromJson(json);
      }
    } catch (e) {
      print('Import failed: $e');
    }
    return null;
  }
}
