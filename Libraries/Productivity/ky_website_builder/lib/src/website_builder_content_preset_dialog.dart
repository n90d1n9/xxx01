import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

class WebsiteBuilderContentPresetDialog extends StatefulWidget {
  final String initialName;
  final String title;
  final String actionLabel;
  final IconData actionIcon;

  const WebsiteBuilderContentPresetDialog({
    super.key,
    required this.initialName,
    this.title = 'Save content preset',
    this.actionLabel = 'Save preset',
    this.actionIcon = Icons.bookmark_add_outlined,
  });

  @override
  State<WebsiteBuilderContentPresetDialog> createState() =>
      _WebsiteBuilderContentPresetDialogState();
}

class _WebsiteBuilderContentPresetDialogState
    extends State<WebsiteBuilderContentPresetDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty;

    return KyBuilderDialog(
      title: Text(widget.title),
      maxWidth: 380,
      content: TextField(
        key: const ValueKey('website-builder-content-preset-name'),
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Preset name',
        ),
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _saveIfValid(canSave),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: canSave ? () => _saveIfValid(canSave) : null,
          icon: Icon(widget.actionIcon),
          label: Text(widget.actionLabel),
        ),
      ],
    );
  }

  void _saveIfValid(bool canSave) {
    if (!canSave) return;
    Navigator.of(context).pop(_nameController.text.trim());
  }
}
