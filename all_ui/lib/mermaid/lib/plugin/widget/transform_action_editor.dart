import 'package:flutter/material.dart';

import '../model/action/tranform_action.dart';
import '../model/action/tranform_rule.dart';

class TransformActionEditor extends StatefulWidget {
  final TransformAction action;
  final Function(TransformAction) onChanged;

  const TransformActionEditor({
    super.key,
    required this.action,
    required this.onChanged,
  });

  @override
  State<TransformActionEditor> createState() => _TransformActionEditorState();
}

class _TransformActionEditorState extends State<TransformActionEditor> {
  late List<TransformRule> _rules;

  @override
  void initState() {
    super.initState();
    _rules = List.from(widget.action.rules);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transform Rules',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._rules.map(_buildRuleCard),
        ElevatedButton.icon(
          onPressed: _addRule,
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
        ),
      ],
    );
  }

  Widget _buildRuleCard(TransformRule rule) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          '${rule.sourceField} → ${rule.targetField}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: rule.transformType != null
            ? Text(
                rule.transformType!,
                style: const TextStyle(color: Colors.white54),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            setState(() => _rules.remove(rule));
            _updateAction();
          },
        ),
      ),
    );
  }

  void _addRule() {
    showDialog(
      context: context,
      builder: (context) {
        final sourceController = TextEditingController();
        final targetController = TextEditingController();
        String? selectedTransform;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF2D2D2D),
            title: const Text(
              'Add Transform Rule',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sourceController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Source Field',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'inputs.fieldName',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Target Field',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'output.fieldName',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTransform,
                  decoration: const InputDecoration(
                    labelText: 'Transform (optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...[
                          'uppercase',
                          'lowercase',
                          'trim',
                          'toNumber',
                          'toString',
                          'toBoolean',
                          'split',
                          'join',
                          'jsonParse',
                          'jsonStringify',
                        ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedTransform = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (sourceController.text.isNotEmpty &&
                      targetController.text.isNotEmpty) {
                    setState(() {
                      _rules.add(
                        TransformRule(
                          sourceField: sourceController.text,
                          targetField: targetController.text,
                          transformType: selectedTransform,
                        ),
                      );
                    });
                    _updateAction();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateAction() {
    widget.onChanged(TransformAction(rules: _rules));
  }
}
