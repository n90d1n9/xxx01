import 'package:flutter/material.dart';

import '../model/action/script_action.dart';

class ScriptActionEditor extends StatefulWidget {
  final ScriptAction action;
  final Function(ScriptAction) onChanged;

  const ScriptActionEditor({
    super.key,
    required this.action,
    required this.onChanged,
  });

  @override
  State<ScriptActionEditor> createState() => _ScriptActionEditorState();
}

class _ScriptActionEditorState extends State<ScriptActionEditor> {
  late TextEditingController _codeController;
  late String _language;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.action.code);
    _language = widget.action.language;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _language,
          decoration: const InputDecoration(
            labelText: 'Language',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          items: [
            'javascript',
            'python',
            'dart',
          ].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: (value) {
            setState(() => _language = value!);
            _updateAction();
          },
        ),
        const SizedBox(height: 16),
        const Text('Code', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: _codeController,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText:
                  '// Write your code here\nfunction execute(inputs, config) {\n  return { output: "result" };\n}',
              hintStyle: TextStyle(color: Colors.white38),
            ),
            onChanged: (_) => _updateAction(),
          ),
        ),
      ],
    );
  }

  void _updateAction() {
    widget.onChanged(
      ScriptAction(language: _language, code: _codeController.text),
    );
  }
}
