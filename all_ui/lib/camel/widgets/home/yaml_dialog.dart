import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YamlDialog extends StatelessWidget {
  final String yaml;
  const YamlDialog({super.key, required this.yaml});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generated YAML'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: SingleChildScrollView(
          child: SelectableText(
            yaml,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: yaml));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard!')),
            );
          },
          child: const Text('Copy'),
        ),
      ],
    );
  }
}
