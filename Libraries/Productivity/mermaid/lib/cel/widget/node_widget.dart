import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/expression_node.dart';
import '../model/node_type.dart';
import '../state/expression_provider.dart';
import 'add_node_dialog.dart';

class NodeWidget extends ConsumerWidget {
  final ExpressionNode node;

  const NodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getNodeIcon(),
                const SizedBox(width: 8),
                Expanded(child: _buildNodeContent()),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => _showAddChildDialog(context, ref),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    ref.read(expressionProvider.notifier).deleteNode(node.id);
                  },
                ),
              ],
            ),
            if (node.children.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Column(
                  children: node.children
                      .map((child) => NodeWidget(node: child))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getNodeIcon() {
    IconData icon;
    Color color;

    switch (node.type) {
      case NodeType.comparison:
        icon = Icons.compare_arrows;
        color = Colors.blue;
        break;
      case NodeType.logical:
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case NodeType.arithmetic:
        icon = Icons.calculate;
        color = Colors.orange;
        break;
      case NodeType.function:
        icon = Icons.functions;
        color = Colors.green;
        break;
      case NodeType.variable:
        icon = Icons.data_object;
        color = Colors.teal;
        break;
      case NodeType.literal:
        icon = Icons.format_quote;
        color = Colors.red;
        break;
      case NodeType.member:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.list:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.map:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.ternary:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildNodeContent() {
    switch (node.type) {
      case NodeType.literal:
        return Text(
          'Literal: ${node.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.variable:
        return Text(
          'Variable: ${node.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.comparison:
        return Text(
          'Comparison: ${node.operator}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.logical:
        return Text(
          'Logical: ${node.operator}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.arithmetic:
        return Text(
          'Arithmetic: ${node.operator}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.function:
        return Text(
          'Function: ${node.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.member:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.list:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.map:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.ternary:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _showAddChildDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddNodeDialog(
        onNodeCreated: (childNode) {
          ref
              .read(expressionProvider.notifier)
              .addChildNode(node.id, childNode);
        },
      ),
    );
  }
}
