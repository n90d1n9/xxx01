import 'package:flutter/material.dart';

import '../model/config_field_definition.dart';

class ConfigFieldEditorDialog extends StatefulWidget {
  final ConfigFieldDefinition? existingField;
  final Function(ConfigFieldDefinition) onSave;

  const ConfigFieldEditorDialog({
    super.key,
    this.existingField,
    required this.onSave,
  });

  @override
  State<ConfigFieldEditorDialog> createState() =>
      _ConfigFieldEditorDialogState();
}

class _ConfigFieldEditorDialogState extends State<ConfigFieldEditorDialog> {
  late TextEditingController _labelController;
  late TextEditingController _descriptionController;
  late String _fieldType;
  late bool _required;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existingField?.label ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingField?.description ?? '',
    );
    _fieldType = widget.existingField?.fieldType ?? 'text';
    _required = widget.existingField?.required ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: Text(
        '${widget.existingField == null ? "Add" : "Edit"} Config Field',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Label',
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _fieldType,
            decoration: const InputDecoration(
              labelText: 'Field Type',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            items: [
              'text',
              'number',
              'boolean',
              'select',
              'textarea',
              'password',
              'json',
              'url',
              'email',
            ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (value) => setState(() => _fieldType = value!),
          ),
          CheckboxListTile(
            title: const Text(
              'Required',
              style: TextStyle(color: Colors.white),
            ),
            value: _required,
            onChanged: (value) => setState(() => _required = value!),
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
            if (_labelController.text.isNotEmpty) {
              widget.onSave(
                ConfigFieldDefinition(
                  key:
                      widget.existingField?.key ??
                      _labelController.text.toLowerCase().replaceAll(' ', '_'),
                  label: _labelController.text,
                  description: _descriptionController.text,
                  fieldType: _fieldType,
                  required: _required,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
