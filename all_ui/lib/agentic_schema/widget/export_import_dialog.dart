import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/workflow/workflow.dart';
import '../service/export_import_service.dart';
import '../state/workflow/workflow_provider.dart';

class ExportImportDialog extends ConsumerStatefulWidget {
  const ExportImportDialog({super.key});

  @override
  ConsumerState<ExportImportDialog> createState() => _ExportImportDialogState();
}

class _ExportImportDialogState extends ConsumerState<ExportImportDialog> {
  int _selectedTab = 0;
  final _service = ExportImportService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: const Text('Export / Import'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              TabBar(
                onTap: (index) => setState(() => _selectedTab = index),
                tabs: const [
                  Tab(text: 'Export'),
                  Tab(text: 'Import'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_buildExportTab(), _buildImportTab()],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    final workflowState = ref.watch(workflowProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Export current workflow as:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildExportOption(
          icon: Icons.code,
          title: 'JSON Format',
          description: 'Export as editable JSON file',
          onTap: () => _exportAsJson(workflowState.currentWorkflow!),
        ),
        _buildExportOption(
          icon: Icons.image,
          title: 'PNG Image',
          description: 'Export as image file',
          onTap: () => _exportAsPng(workflowState.currentWorkflow!),
        ),
        _buildExportOption(
          icon: Icons.code_off,
          title: 'SVG Vector',
          description: 'Export as scalable vector graphic',
          onTap: () => _exportAsSvg(workflowState.currentWorkflow!),
        ),
        _buildExportOption(
          icon: Icons.description,
          title: 'Documentation',
          description: 'Generate markdown documentation',
          onTap: () => _exportAsMarkdown(workflowState.currentWorkflow!),
        ),
      ],
    );
  }

  Widget _buildImportTab() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Icon(Icons.upload_file, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text(
          'Import Workflow',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Import a workflow from JSON file',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _importWorkflow,
          icon: const Icon(Icons.file_open),
          label: const Text('Select File'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportAsJson(Workflow workflow) async {
    try {
      final json = await _service.exportWorkflowToJson(workflow);
      final filename = '${workflow.name.replaceAll(' ', '_')}.json';

      // Use file picker to select save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save workflow',
        fileName: filename,
      );

      if (result != null) {
        await _service.exportToFile(json, result);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Exported to $result')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _exportAsPng(Workflow workflow) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PNG export coming soon')));
  }

  Future<void> _exportAsSvg(Workflow workflow) async {
    try {
      final svg = await _service.exportAsSvg(
        workflow.nodes,
        workflow.edges ?? [],
      );
      final filename = '${workflow.name.replaceAll(' ', '_')}.svg';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save SVG',
        fileName: filename,
      );

      if (result != null) {
        await _service.exportToFile(svg, result);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Exported to $result')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _exportAsMarkdown(Workflow workflow) async {
    final buffer = StringBuffer();
    buffer.writeln('# ${workflow.name}');
    buffer.writeln();
    buffer.writeln('## Description');
    buffer.writeln(workflow.description ?? 'No description');
    buffer.writeln();
    buffer.writeln('## Nodes');
    for (final node in workflow.nodes) {
      buffer.writeln('### ${node.name}');
      buffer.writeln('- **Type**: ${node.type.displayName}');
      buffer.writeln('- **Category**: ${node.category?.name}');
      if (node.description != null) {
        buffer.writeln('- **Description**: ${node.description}');
      }
      buffer.writeln();
    }

    final filename = '${workflow.name.replaceAll(' ', '_')}.md';
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save documentation',
      fileName: filename,
    );

    if (result != null) {
      await _service.exportToFile(buffer.toString(), result);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exported to $result')));
      }
    }
  }

  Future<void> _importWorkflow() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final content = await _service.importFromFile(
          result.files.single.path!,
        );
        final workflow = _service.importWorkflowFromJson(content);

        ref.read(workflowProvider.notifier).loadWorkflow(workflow);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workflow imported successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}
