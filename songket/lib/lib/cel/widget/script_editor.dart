import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/expression_provider.dart';

class ScriptEditor extends ConsumerStatefulWidget {
  const ScriptEditor({super.key});

  @override
  ConsumerState<ScriptEditor> createState() => _ScriptEditorState();
}

class _ScriptEditorState extends ConsumerState<ScriptEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(expressionProvider).script,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CEL Script Editor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Enter CEL expression...\nExample: user.age >= 18 && user.verified == true',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              onChanged: (value) {
                ref.read(expressionProvider.notifier).updateScript(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
