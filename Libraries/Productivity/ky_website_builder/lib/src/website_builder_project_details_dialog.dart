import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

class WebsiteBuilderProjectDetailsEdit {
  final String projectId;
  final String projectName;

  const WebsiteBuilderProjectDetailsEdit({
    required this.projectId,
    required this.projectName,
  });
}

class WebsiteBuilderProjectDetailsDialog extends StatefulWidget {
  final String projectId;
  final String projectName;

  const WebsiteBuilderProjectDetailsDialog({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<WebsiteBuilderProjectDetailsDialog> createState() =>
      _WebsiteBuilderProjectDetailsDialogState();
}

class _WebsiteBuilderProjectDetailsDialogState
    extends State<WebsiteBuilderProjectDetailsDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.projectName);
    _idController = TextEditingController(text: widget.projectId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        _nameController.text.trim().isNotEmpty &&
        _idController.text.trim().isNotEmpty;

    return KyBuilderDialog(
      title: const Text('Project details'),
      maxWidth: 420,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project name',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project id',
              ),
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _saveIfValid(canSave),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: canSave ? () => _saveIfValid(canSave) : null,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save'),
        ),
      ],
    );
  }

  void _saveIfValid(bool canSave) {
    if (!canSave) return;
    Navigator.of(context).pop(
      WebsiteBuilderProjectDetailsEdit(
        projectId: _idController.text,
        projectName: _nameController.text,
      ),
    );
  }
}
