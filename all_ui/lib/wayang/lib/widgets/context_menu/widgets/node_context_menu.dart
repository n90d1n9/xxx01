import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/workflow/model/workflow_node.dart';

class NodeContextMenu extends ConsumerWidget {
  final WorkflowNode node;
  final Offset position;

  const NodeContextMenu({
    super.key,
    required this.node,
    required this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      initialValue: null,
      tooltip: 'Node Actions',
      onSelected: (value) {
        _handleMenuSelection(value, ref, context);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit Node'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Node'),
            ],
          ),
        ),
        // Add more menu items as needed
      ],
      child: Icon(Icons.more_vert),
    );
  }

  void _handleMenuSelection(String value, WidgetRef ref, BuildContext context) {
    switch (value) {
      case 'edit':
        _showEditNodeDialog(context, ref);
        break;
      case 'delete':
        _deleteNode(ref);
        break;
    }
  }

  void _showEditNodeDialog(BuildContext context, WidgetRef ref) {
    // Implement node editing UI
    final nameController = TextEditingController(text: node.label);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Node'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Node Name'),
            ),
            // Add more fields as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update node properties
              // Implement the update logic
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteNode(WidgetRef ref) {
    // Remove all connections for this node
    //ref.read(connectionsProvider.notifier).removeConnectionsForNode(node.id);

    // Remove the node
    //ref.read(nodesProvider.notifier).removeNode(node.id);
  }
}
