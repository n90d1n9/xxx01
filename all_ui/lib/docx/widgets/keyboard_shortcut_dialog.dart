import 'package:flutter/material.dart';

import 'shortcut_item.dart';

class KeyboardShortcutDialog extends StatelessWidget {
  const KeyboardShortcutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard),
          SizedBox(width: 8),
          Text('Keyboard Shortcuts'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShortcutItem('Ctrl + S', 'Save document'),
            ShortcutItem('Ctrl + N', 'New document'),
            ShortcutItem('Ctrl + F', 'Find in document'),
            ShortcutItem('Ctrl + H', 'Find and replace'),
            ShortcutItem('Ctrl + P', 'Print document'),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Text Formatting',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ShortcutItem('Ctrl + B', 'Bold'),
            ShortcutItem('Ctrl + I', 'Italic'),
            ShortcutItem('Ctrl + U', 'Underline'),
            ShortcutItem('Ctrl + Z', 'Undo'),
            ShortcutItem('Ctrl + Y', 'Redo'),
            ShortcutItem('Ctrl + A', 'Select all'),
            ShortcutItem('Ctrl + C', 'Copy'),
            ShortcutItem('Ctrl + V', 'Paste'),
            ShortcutItem('Ctrl + X', 'Cut'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
