import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/common/position.dart';
import '../schema/workflow/workflow_node.dart';
import '../state/workflow/workflow_provider.dart';

class BulkOperationDialog extends ConsumerStatefulWidget {
  final List<WorkflowNode> selectedNodes;

  const BulkOperationDialog({Key? key, required this.selectedNodes})
    : super(key: key);

  @override
  ConsumerState<BulkOperationDialog> createState() =>
      _BulkOperationDialogState();
}

class _BulkOperationDialogState extends ConsumerState<BulkOperationDialog> {
  String _selectedOperation = 'align';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bulk Operations (${widget.selectedNodes.length} nodes)'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedOperation,
              decoration: const InputDecoration(
                labelText: 'Operation',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'align', child: Text('Align Nodes')),
                DropdownMenuItem(
                  value: 'distribute',
                  child: Text('Distribute Evenly'),
                ),
                DropdownMenuItem(value: 'group', child: Text('Group')),
                DropdownMenuItem(value: 'color', child: Text('Change Color')),
                DropdownMenuItem(value: 'delete', child: Text('Delete All')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedOperation = value);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildOperationOptions(),
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
            _applyBulkOperation();
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildOperationOptions() {
    switch (_selectedOperation) {
      case 'align':
        return Column(
          children: [
            const Text('Align selected nodes:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _align('left'),
                  icon: const Icon(Icons.align_horizontal_left),
                  label: const Text('Left'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _align('center'),
                  icon: const Icon(Icons.align_horizontal_center),
                  label: const Text('Center'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _align('right'),
                  icon: const Icon(Icons.align_horizontal_right),
                  label: const Text('Right'),
                ),
              ],
            ),
          ],
        );
      case 'distribute':
        return const Text('Distribute nodes evenly between first and last');
      case 'group':
        return const Text('Create a visual group for selected nodes');
      case 'color':
        return const Text('Apply color to all selected nodes');
      case 'delete':
        return const Text('Delete all selected nodes');
      default:
        return const SizedBox.shrink();
    }
  }

  void _align(String direction) {
    // Calculate alignment position
    double targetX = 0;

    switch (direction) {
      case 'left':
        targetX = widget.selectedNodes
            .map((n) => n.position.x)
            .reduce(math.min);
        break;
      case 'center':
        final minX = widget.selectedNodes
            .map((n) => n.position.x)
            .reduce(math.min);
        final maxX = widget.selectedNodes
            .map((n) => n.position.x)
            .reduce(math.max);
        targetX = (minX + maxX) / 2;
        break;
      case 'right':
        targetX = widget.selectedNodes
            .map((n) => n.position.x)
            .reduce(math.max);
        break;
    }

    // Apply alignment
    for (final node in widget.selectedNodes) {
      final updatedNode = node.copyWith(
        position: Position(x: targetX, y: node.position.y),
      );
      ref.read(workflowProvider.notifier).updateNode(updatedNode);
    }
  }

  void _applyBulkOperation() {
    switch (_selectedOperation) {
      case 'distribute':
        _distributeNodes();
        break;
      case 'group':
        _groupNodes();
        break;
      case 'color':
        _changeColor();
        break;
      case 'delete':
        ref.read(workflowProvider.notifier).deleteSelectedNodes();
        break;
    }
  }

  void _distributeNodes() {
    if (widget.selectedNodes.length < 3) return;

    // Sort by Y position
    final sorted = widget.selectedNodes.toList()
      ..sort((a, b) => a.position.y.compareTo(b.position.y));

    final first = sorted.first.position.y;
    final last = sorted.last.position.y;
    final spacing = (last - first) / (sorted.length - 1);

    for (var i = 1; i < sorted.length - 1; i++) {
      final node = sorted[i];
      final updatedNode = node.copyWith(
        position: Position(x: node.position.x, y: first + spacing * i),
      );
      ref.read(workflowProvider.notifier).updateNode(updatedNode);
    }
  }

  void _groupNodes() {
    // Create visual group
  }

  void _changeColor() {
    // Apply color
  }
}
