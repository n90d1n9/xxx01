import 'package:flutter/material.dart';
import '../../services/export_service.dart';

class ExportMenu extends StatelessWidget {
  final Function(ExportFormat) onExport;

  const ExportMenu({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExportFormat>(
      icon: const Icon(Icons.file_download),
      tooltip: 'Export As',
      onSelected: onExport,
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: ExportFormat.yaml, child: Text('YAML')),
            const PopupMenuItem(value: ExportFormat.json, child: Text('JSON')),
            const PopupMenuItem(
              value: ExportFormat.xml,
              child: Text('Spring XML'),
            ),
            const PopupMenuItem(
              value: ExportFormat.springDsl,
              child: Text('Spring DSL (Java)'),
            ),
            const PopupMenuItem(
              value: ExportFormat.quarkusYaml,
              child: Text('Quarkus YAML'),
            ),
            const PopupMenuItem(
              value: ExportFormat.kubernetes,
              child: Text('Kubernetes Manifest'),
            ),
            const PopupMenuItem(
              value: ExportFormat.docker,
              child: Text('Dockerfile'),
            ),
          ],
    );
  }
}
