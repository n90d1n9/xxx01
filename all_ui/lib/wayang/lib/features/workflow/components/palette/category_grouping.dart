import 'package:flutter/material.dart';

import '../node/model/schema/node_type_config.dart';
import 'node_type_tile.dart';

class CategoryGrouping extends StatelessWidget {
  final String category;
  final List<NodeConfig> nodes;
  final void Function(dynamic nodeType) onNodeSelected;

  const CategoryGrouping({
    super.key,
    required this.category,
    required this.nodes,
    required this.onNodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        initiallyExpanded: true,
        maintainState: true,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final nodeType = nodes[index];
              return Draggable<NodeConfig>(
                data: nodeType,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: 200,
                    child: Opacity(
                      opacity: 0.85,
                      child: NodeTypeTile(
                        nodeType: nodeType,
                        isDragging: true,
                        onNodeSelected: onNodeSelected,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: NodeTypeTile(
                    nodeType: nodeType,
                    isDragging: false,
                    onNodeSelected: onNodeSelected,
                  ),
                ),
                child: NodeTypeTile(
                  nodeType: nodeType,
                  isDragging: false,
                  onNodeSelected: onNodeSelected,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
