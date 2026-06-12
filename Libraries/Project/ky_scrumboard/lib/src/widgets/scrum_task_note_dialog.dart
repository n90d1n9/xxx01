import 'package:flutter/material.dart';

import '../scrum_board_palette.dart';

Future<String?> showScrumTaskNoteDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const ScrumTaskNoteDialog(),
  );
}

class ScrumTaskNoteDialog extends StatefulWidget {
  const ScrumTaskNoteDialog({super.key});

  @override
  State<ScrumTaskNoteDialog> createState() => _ScrumTaskNoteDialogState();
}

class _ScrumTaskNoteDialogState extends State<ScrumTaskNoteDialog> {
  static const _maxNoteLength = 240;

  final TextEditingController _noteController = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleNoteChanged(String value) {
    final canSubmit = value.trim().isNotEmpty;
    if (canSubmit == _canSubmit) return;
    setState(() => _canSubmit = canSubmit);
  }

  void _submit() {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add task note'),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _noteController,
          autofocus: true,
          maxLength: _maxNoteLength,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          onChanged: _handleNoteChanged,
          decoration: InputDecoration(
            labelText: 'Note',
            hintText: 'Capture a blocker, decision, or follow-up.',
            alignLabelWithHint: true,
            filled: true,
            fillColor: ScrumBoardPalette.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _canSubmit ? _submit : null,
          icon: const Icon(Icons.add_comment_rounded),
          label: const Text('Add note'),
        ),
      ],
    );
  }
}
