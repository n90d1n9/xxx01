import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/node/node_template.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/node_template_provider.dart';

class NodeTemplateDialog extends ConsumerStatefulWidget {
  final WorkflowNode node;

  const NodeTemplateDialog({super.key, required this.node});

  @override
  ConsumerState<NodeTemplateDialog> createState() => _NodeTemplateDialogState();
}

class _NodeTemplateDialogState extends ConsumerState<NodeTemplateDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save as Template'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Template Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final template = NodeTemplate(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              type: widget.node.type,
              config: widget.node.config?.toJson() ?? {},
              description: _descriptionController.text,
            );
            ref.read(nodeTemplateProvider.notifier).addTemplate(template);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
