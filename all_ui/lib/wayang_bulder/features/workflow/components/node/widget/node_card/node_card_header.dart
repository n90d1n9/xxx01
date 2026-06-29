import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/workflow_node.dart';
import '../../../../state/workflow_provider.dart';
import '../../../../model/workflow_node_port.dart';
import '../../model/schema/node_type_config.dart';

class NodeCardHeader extends ConsumerWidget {
  final WorkflowNode node;
  final NodeConfig nodeConfig;
  final bool isSelected;
  const NodeCardHeader({
    super.key,
    required this.node,
    required this.nodeConfig,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nodeConfig.style!.color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(nodeConfig.icon, color: nodeConfig.style!.color, size: 20),
          const SizedBox(width: 8),

          Container(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              node.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const Spacer(),
          if (node.status == NodeStatus.running)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
          if (node.status == NodeStatus.success)
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          if (node.status == NodeStatus.error)
            const Icon(Icons.error, color: Colors.red, size: 16),
          if (isSelected) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16),
              //color: const Color(0xFF2D2D2D),
              onSelected: (value) {
                switch (value) {
                  case 'duplicate':
                    ref.read(workflowProvider.notifier).duplicateNode(node.id);
                    break;
                  case 'delete':
                    ref.read(workflowProvider.notifier).deleteNode(node.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Text('Duplicate', style: TextStyle()),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
