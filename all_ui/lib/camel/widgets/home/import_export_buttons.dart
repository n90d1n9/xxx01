import 'package:flutter/material.dart';

class ImportExportButtons extends StatelessWidget {
  final Function(String) onExport;
  final VoidCallback onImport;

  const ImportExportButtons({
    super.key,
    required this.onExport,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.download),
          tooltip: 'Export',
          onSelected: onExport,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'yaml',
                  child: Text('Export as YAML'),
                ),
                const PopupMenuItem(
                  value: 'json',
                  child: Text('Export as JSON'),
                ),
                const PopupMenuItem(value: 'view', child: Text('View YAML')),
              ],
        ),
        IconButton(
          icon: const Icon(Icons.upload),
          onPressed: onImport,
          tooltip: 'Import',
        ),
      ],
    );
  }
}
