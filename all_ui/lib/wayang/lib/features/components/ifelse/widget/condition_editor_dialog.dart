import 'package:flutter/material.dart';

import '../model/ifelse_condition.dart';

class ConditionEditorDialog extends StatefulWidget {
  final IfElseCondition? existingCondition;
  final ValueChanged<IfElseCondition> onSave;

  const ConditionEditorDialog({
    super.key,
    this.existingCondition,
    required this.onSave,
  });

  @override
  State<ConditionEditorDialog> createState() => _ConditionEditorDialogState();
}

class _ConditionEditorDialogState extends State<ConditionEditorDialog> {
  late TextEditingController _labelController;
  late TextEditingController _expressionController;
  late TextEditingController _descriptionController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existingCondition?.label ?? '',
    );
    _expressionController = TextEditingController(
      text: widget.existingCondition?.expression ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingCondition?.description ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _expressionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    // Trim whitespace
    final label = _labelController.text.trim();
    final expression = _expressionController.text.trim();

    if (label.isEmpty || expression.isEmpty) {
      // Use context-aware error display
      if (mounted) {
        _showError('Label and expression are required');
      }
      return;
    }

    final condition = IfElseCondition(
      id:
          widget.existingCondition?.id ??
          'condition_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      expression: expression,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    widget.onSave(condition);
    if (mounted) Navigator.pop(context);
  }

  void _showError(String message) {
    // Prefer ScaffoldMessenger, but guard against missing Scaffold
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Fallback: show dialog or log
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Validation Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingCondition == null
                  ? 'Add Condition'
                  : 'Edit Condition',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _labelController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Label',
                labelStyle: TextStyle(),
                hintText: 'e.g., High Priority',
                hintStyle: TextStyle(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expressionController,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'CEL Expression',
                labelStyle: TextStyle(),
                hintText: 'input.priority == "high"',
                hintStyle: TextStyle(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(),
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(),
                hintText: 'Explain what this condition checks',
                hintStyle: TextStyle(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle()),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    //foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
