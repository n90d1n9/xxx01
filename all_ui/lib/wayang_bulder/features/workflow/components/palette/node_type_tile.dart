import 'package:flutter/material.dart';

import '../node/model/schema/node_type_config.dart';
import 'node_detail.dart';

class NodeTypeTile extends StatelessWidget {
  final NodeConfig nodeType;
  final bool isDragging;
  final void Function(dynamic nodeType) onNodeSelected;
  const NodeTypeTile({
    super.key,
    required this.nodeType,
    this.isDragging = false,
    required this.onNodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: nodeType.style!.color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Material(
        child: InkWell(
          onTap: isDragging
              ? null
              : () {
                  // ✅ Call the callback when tapped
                  onNodeSelected(nodeType);
                  _showNodeDetails(nodeType, context);
                },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  nodeType.icon,
                  color: nodeType.style!.color,
                  size: isDragging ? 18 : 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nodeType.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (nodeType.description.isNotEmpty)
                        Text(
                          nodeType.description,
                          style: const TextStyle(fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNodeDetails(NodeConfig nodeType, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: NodeDetail(nodeType: nodeType),
      ),
    );
  }
}
