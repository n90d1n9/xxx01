import 'package:flutter/material.dart';

class PageJumpDialog extends StatefulWidget {
  const PageJumpDialog({super.key});
  @override
  State<PageJumpDialog> createState() => _PageJumpDialogState();
}

class _PageJumpDialogState extends State<PageJumpDialog> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jump to Page'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Page Number (1-604)',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (value) {
          final page = int.tryParse(value);
          if (page != null && page >= 1 && page <= 604) {
            Navigator.pop(context, page);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final page = int.tryParse(_controller.text);
            if (page != null && page >= 1 && page <= 604) {
              Navigator.pop(context, page);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid page number (1-604)'),
                ),
              );
            }
          },
          child: const Text('Go'),
        ),
      ],
    );
  }
}
