import 'package:flutter/material.dart';

import '../schema/mapping_rule.dart';

class AddMappingDialog extends StatefulWidget {
  final MappingRule? mapping;
  final ValueChanged<MappingRule> onAdd;

  const AddMappingDialog({super.key, this.mapping, required this.onAdd});

  @override
  State<AddMappingDialog> createState() => _AddMappingDialogState();
}

class _AddMappingDialogState extends State<AddMappingDialog> {
  late TextEditingController _sourceController;
  late TextEditingController _targetController;
  late TextEditingController _expressionController;
  TransformFunction? _selectedFunction;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController(
      text: widget.mapping?.sourcePath ?? '',
    );
    _targetController = TextEditingController(
      text: widget.mapping?.targetPath ?? '',
    );
    _expressionController = TextEditingController(
      text: widget.mapping?.expression ?? '',
    );
    _selectedFunction = widget.mapping?.function;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mapping == null ? 'Add Mapping' : 'Edit Mapping'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source Path',
                hintText: 'e.g., user.name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Path',
                hintText: 'e.g., customer.fullName',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransformFunction>(
              value: _selectedFunction,
              decoration: const InputDecoration(
                labelText: 'Transform Function (optional)',
              ),
              items:
                  TransformFunction.values.map((func) {
                    return DropdownMenuItem(
                      value: func,
                      child: Text(func.name),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _selectedFunction = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expressionController,
              decoration: const InputDecoration(
                labelText: 'Expression (optional)',
                hintText: 'e.g., \${body.user.name} + " Smith"',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    if (_sourceController.text.isEmpty || _targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and target paths are required')),
      );
      return;
    }

    final mapping = MappingRule(
      id:
          widget.mapping?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      sourcePath: _sourceController.text,
      targetPath: _targetController.text,
      expression:
          _expressionController.text.isEmpty
              ? null
              : _expressionController.text,
      function: _selectedFunction,
    );

    widget.onAdd(mapping);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _expressionController.dispose();
    super.dispose();
  }
}
