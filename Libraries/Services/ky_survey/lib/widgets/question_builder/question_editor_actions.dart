import 'package:flutter/material.dart';

class QuestionEditorActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const QuestionEditorActions({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        const SizedBox(width: 12),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Save'),
          onPressed: onSave,
        ),
      ],
    );
  }
}
