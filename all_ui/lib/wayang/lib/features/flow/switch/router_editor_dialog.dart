import 'package:flutter/material.dart';

import '../router/router_route.dart';
import '../router/router_strategy.dart';

class RouterEditorDialog extends StatefulWidget {
  final RouterRoute? existingRoute;
  final RouterStrategy strategy;
  final Function(RouterRoute) onSave;

  const RouterEditorDialog({
    Key? key,
    this.existingRoute,
    required this.strategy,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RouterEditorDialog> createState() => _RouterEditorDialogState();
}

class _RouterEditorDialogState extends State<RouterEditorDialog> {
  late TextEditingController _labelController;
  late TextEditingController _conditionController;
  late TextEditingController _weightController;
  late TextEditingController _priorityController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existingRoute?.label ?? '',
    );
    _conditionController = TextEditingController(
      text: widget.existingRoute?.condition ?? '',
    );
    _weightController = TextEditingController(
      text: widget.existingRoute?.weight.toString() ?? '1',
    );
    _priorityController = TextEditingController(
      text: widget.existingRoute?.priority.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _conditionController.dispose();
    _weightController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: Text(
        widget.existingRoute == null ? 'Add Route' : 'Edit Route',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Route Label',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.strategy == RouterStrategy.custom) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _conditionController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'CEL Condition',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'input.type == "premium"',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (widget.strategy == RouterStrategy.weightedRandom) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  labelStyle: TextStyle(color: Colors.white70),
                  helperText: 'Higher weight = more likely to be selected',
                  helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (widget.strategy == RouterStrategy.priority) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _priorityController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  labelStyle: TextStyle(color: Colors.white70),
                  helperText: 'Higher priority = selected first',
                  helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (_labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Label is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final route = RouterRoute(
      id:
          widget.existingRoute?.id ??
          'route_${DateTime.now().millisecondsSinceEpoch}',
      label: _labelController.text,
      condition: _conditionController.text.isEmpty
          ? null
          : _conditionController.text,
      weight: int.tryParse(_weightController.text) ?? 1,
      priority: int.tryParse(_priorityController.text) ?? 0,
    );

    widget.onSave(route);
  }
}
