import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/integration/integration_pattern_template.dart';
import '../../state/workflow/workflow_provider.dart';

class PatternDetailsDialog extends ConsumerWidget {
  final IntegrationPatternTemplate pattern;

  const PatternDetailsDialog({super.key, required this.pattern});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Text(pattern.icon!),
          const SizedBox(width: 8),
          Expanded(child: Text(pattern.name)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pattern.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Pattern Type: ${pattern.pattern}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${pattern.category}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Nodes: ${pattern.template?.nodes?.length ?? 0}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (pattern.template?.nodes != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pattern.template!.nodes!.map((node) {
                  return Chip(
                    avatar: Icon(node.type.icon, size: 16),
                    label: Text(node.name),
                    backgroundColor: node.type.color.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _applyPattern(context, ref, pattern);
          },
          icon: const Icon(Icons.add),
          label: const Text('Apply to Canvas'),
        ),
      ],
    );
  }

  void _applyPattern(
    BuildContext context,
    WidgetRef ref,
    IntegrationPatternTemplate pattern,
  ) {
    final workflowState = ref.read(workflowProvider);
    if (workflowState.currentWorkflow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a workflow first')),
      );
      return;
    }

    // Add pattern nodes to workflow
    final nodes = pattern.template?.nodes ?? [];
    for (final node in nodes) {
      ref
          .read(workflowProvider.notifier)
          .addNode(
            node.type,
            Offset(node.position.x + 100, node.position.y + 100),
          );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Applied pattern: ${pattern.name}')));
  }
}
