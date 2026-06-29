import 'package:flutter/material.dart';

import '../../schema/node/node_type.dart';

class PaletteNodeItem extends StatelessWidget {
  final NodeType type;

  const PaletteNodeItem({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Draggable<NodeType>(
      data: type,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: type.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                type.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(type.icon, color: type.color, size: 20),
          ),
          title: Text(type.displayName),
          subtitle: Text(
            _getNodeDescription(type),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          dense: true,
        ),
      ),
    );
  }

  String _getNodeDescription(NodeType type) {
    switch (type) {
      case NodeType.llm:
        return 'LLM processing node';
      case NodeType.splitter:
        return 'Split message into parts';
      case NodeType.aggregator:
        return 'Combine messages';
      case NodeType.router:
        return 'Route based on conditions';
      default:
        return type.category.name;
    }
  }
}
