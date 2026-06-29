import 'package:flutter/material.dart';

import '../../schema/variable/variable_scope.dart';

class AddVariableDialog extends StatefulWidget {
  const AddVariableDialog({super.key});

  @override
  State<AddVariableDialog> createState() => _AddVariableDialogState();
}

class _AddVariableDialogState extends State<AddVariableDialog> {
  final _nameController = TextEditingController();
  final _defaultValueController = TextEditingController();
  VariableType _selectedType = VariableType.string;
  VariableScope _selectedScope = VariableScope.workflow;

  @override
  void dispose() {
    _nameController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Variable'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Variable Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VariableType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: VariableType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VariableScope>(
              value: _selectedScope,
              decoration: const InputDecoration(
                labelText: 'Scope',
                border: OutlineInputBorder(),
              ),
              items: VariableScope.values.map((scope) {
                return DropdownMenuItem(value: scope, child: Text(scope.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedScope = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _defaultValueController,
              decoration: const InputDecoration(
                labelText: 'Default Value (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Add variable
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
