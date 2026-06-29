import 'package:flutter/material.dart';

import '../model/port_definition.dart';

class PortEditorDialog extends StatefulWidget {
  final PortDefinition? existingPort;
  final Function(PortDefinition) onSave;

  const PortEditorDialog({super.key, this.existingPort, required this.onSave});

  @override
  State<PortEditorDialog> createState() => _PortEditorDialogState();
}

class _PortEditorDialogState extends State<PortEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _dataType;
  late bool _required;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingPort?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingPort?.description ?? '',
    );
    _dataType = widget.existingPort?.dataType ?? 'string';
    _required = widget.existingPort?.required ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: Text(
        '${widget.existingPort == null ? "Add" : "Edit"} Port',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Name',
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
            value: _dataType,
            decoration: const InputDecoration(
              labelText: 'Data Type',
              labelStyle: TextStyle(color: Colors.white70),
            ),
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            items: [
              'string',
              'number',
              'boolean',
              'object',
              'array',
              'any',
              'file',
            ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (value) => setState(() => _dataType = value!),
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
            if (_nameController.text.isNotEmpty) {
              widget.onSave(
                PortDefinition(
                  id:
                      widget.existingPort?.id ??
                      _nameController.text.toLowerCase().replaceAll(' ', '_'),
                  name: _nameController.text,
                  description: _descriptionController.text,
                  dataType: _dataType,
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
