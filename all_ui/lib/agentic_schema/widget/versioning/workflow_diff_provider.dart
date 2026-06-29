import 'package:flutter/material.dart';

import '../../model/versioning/edge_diff.dart';
import '../../model/versioning/node_diff.dart';
import '../../model/versioning/workflow_diff.dart';
import '../../schema/workflow/workflow.dart';

class WorkflowDiffViewer extends StatelessWidget {
  final Workflow oldWorkflow;
  final Workflow newWorkflow;

  const WorkflowDiffViewer({
    super.key,
    required this.oldWorkflow,
    required this.newWorkflow,
  });

  @override
  Widget build(BuildContext context) {
    final diff = _calculateDiff();

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.compare_arrows),
                const SizedBox(width: 8),
                Text(
                  'Workflow Comparison',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary
            _buildSummary(diff),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Diff details
            Expanded(
              child: ListView(
                children: [
                  if (diff.nodeDiffs.isNotEmpty) ...[
                    Text(
                      'Node Changes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...diff.nodeDiffs.map(
                      (nodeDiff) => _buildNodeDiff(nodeDiff),
                    ),
                  ],

                  if (diff.edgeDiffs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Connection Changes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...diff.edgeDiffs.map(
                      (edgeDiff) => _buildEdgeDiff(edgeDiff),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  WorkflowDiff _calculateDiff() {
    final nodeDiffs = <NodeDiff>[];
    final edgeDiffs = <EdgeDiff>[];

    // Compare nodes
    final oldNodeIds = oldWorkflow.nodes.map((n) => n.id).toSet();
    final newNodeIds = newWorkflow.nodes.map((n) => n.id).toSet();

    // Added nodes
    for (final id in newNodeIds.difference(oldNodeIds)) {
      final node = newWorkflow.nodes.firstWhere((n) => n.id == id);
      nodeDiffs.add(NodeDiff(newNode: node, type: DiffType.added, changes: {}));
    }

    // Removed nodes
    for (final id in oldNodeIds.difference(newNodeIds)) {
      final node = oldWorkflow.nodes.firstWhere((n) => n.id == id);
      nodeDiffs.add(
        NodeDiff(oldNode: node, type: DiffType.removed, changes: {}),
      );
    }

    // Modified nodes
    for (final id in oldNodeIds.intersection(newNodeIds)) {
      final oldNode = oldWorkflow.nodes.firstWhere((n) => n.id == id);
      final newNode = newWorkflow.nodes.firstWhere((n) => n.id == id);

      final changes = <String, dynamic>{};
      if (oldNode.name != newNode.name) {
        changes['name'] = {'old': oldNode.name, 'new': newNode.name};
      }
      if (oldNode.description != newNode.description) {
        changes['description'] = {
          'old': oldNode.description,
          'new': newNode.description,
        };
      }

      if (changes.isNotEmpty) {
        nodeDiffs.add(
          NodeDiff(
            oldNode: oldNode,
            newNode: newNode,
            type: DiffType.modified,
            changes: changes,
          ),
        );
      }
    }

    return WorkflowDiff(nodeDiffs: nodeDiffs, edgeDiffs: edgeDiffs);
  }

  Widget _buildSummary(WorkflowDiff diff) {
    final added = diff.nodeDiffs.where((d) => d.type == DiffType.added).length;
    final removed = diff.nodeDiffs
        .where((d) => d.type == DiffType.removed)
        .length;
    final modified = diff.nodeDiffs
        .where((d) => d.type == DiffType.modified)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Added', added, Colors.green),
            _buildStat('Removed', removed, Colors.red),
            _buildStat('Modified', modified, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildNodeDiff(NodeDiff diff) {
    Color color;
    IconData icon;
    String label;

    switch (diff.type) {
      case DiffType.added:
        color = Colors.green;
        icon = Icons.add_circle;
        label = 'Added';
        break;
      case DiffType.removed:
        color = Colors.red;
        icon = Icons.remove_circle;
        label = 'Removed';
        break;
      case DiffType.modified:
        color = Colors.orange;
        icon = Icons.edit;
        label = 'Modified';
        break;
      case DiffType.unchanged:
        color = Colors.grey;
        icon = Icons.circle;
        label = 'Unchanged';
        break;
    }

    final node = diff.newNode ?? diff.oldNode!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(node.name),
        subtitle: diff.changes.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: diff.changes.entries.map((entry) {
                  return Text(
                    '${entry.key}: ${entry.value['old']} → ${entry.value['new']}',
                    style: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              )
            : null,
        trailing: Chip(
          label: Text(label),
          backgroundColor: color.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildEdgeDiff(EdgeDiff diff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          diff.type == DiffType.added ? Icons.add : Icons.remove,
          color: diff.type == DiffType.added ? Colors.green : Colors.red,
        ),
        title: Text(
          '${diff.newEdge?.source ?? diff.oldEdge?.source} → '
          '${diff.newEdge?.target ?? diff.oldEdge?.target}',
        ),
      ),
    );
  }
}
