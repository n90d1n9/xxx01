import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/workflow_node.dart';
import '../../../../state/connection_provider.dart';
import '../../../../state/workflow_provider.dart';
import '../node_port/node_card_input_port.dart';
import '../node_port/node_card_output_port.dart';

class NodeCardPort extends ConsumerWidget {
  final WorkflowNode node;
  const NodeCardPort({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input Ports
          if (node.inputs.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: node.inputs.asMap().entries.map((entry) {
                final targetPortId = entry.value.id;
                final existingConnection = workflowState.connections
                    .firstWhereOrNull(
                      (c) =>
                          c.targetNodeId == node.id &&
                          c.targetPortId == targetPortId,
                    );

                return NodeCardInputPort(
                  port: entry.value,
                  parentNodeId: node.id,
                  isConnected: existingConnection != null,
                  existingConnection: existingConnection,
                  node: node,
                  targetPortId: targetPortId,
                  //),
                );
              }).toList(),
            ),
          if (node.inputs.isNotEmpty && node.outputs.isNotEmpty)
            const SizedBox(height: 8),

          // Output Ports
          if (node.outputs.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: node.outputs.asMap().entries.map((entry) {
                final targetPortId = entry.value.id;
                return NodeCardOutputPort(
                  nodeId: node.id,
                  port: entry.value,
                  index: entry.key,
                  targetPortId: targetPortId,
                  node: node,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
