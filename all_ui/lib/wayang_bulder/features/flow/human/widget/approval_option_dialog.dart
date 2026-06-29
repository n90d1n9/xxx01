import 'package:flutter/material.dart';

import '../model/human_approval_option.dart';

class ApprovalOptionEditorDialog extends StatefulWidget {
  final HumanApprovalOption? existingOption;
  final Function(HumanApprovalOption) onSave;

  const ApprovalOptionEditorDialog({
    Key? key,
    this.existingOption,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ApprovalOptionEditorDialog> createState() =>
      _ApprovalOptionEditorDialogState();
}

class _ApprovalOptionEditorDialogState
    extends State<ApprovalOptionEditorDialog> {
  late TextEditingController _labelController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existingOption?.label ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingOption?.description ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: Text(
        widget.existingOption == null ? 'Add Option' : 'Edit Option',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Label',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'e.g., Approve for Publication',
              hintStyle: TextStyle(color: Colors.white38),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Explain what this option means',
              hintStyle: TextStyle(color: Colors.white38),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (_labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Label is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final option = HumanApprovalOption(
      id:
          widget.existingOption?.id ??
          'option_${DateTime.now().millisecondsSinceEpoch}',
      label: _labelController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    );

    widget.onSave(option);
  }
}
