import 'package:flutter/material.dart';

import '../../model/schema/node_type_config.dart';
import '../../../../model/workflow_node.dart';
import '../../../../model/workflow_node_port.dart';
import '../../../../state/workflow_state.dart';
import '../node_card/node_card_error_message.dart';
import '../node_card/node_card_header.dart';
import '../node_card/node_card_port.dart';

class RectShape extends StatelessWidget {
  final WorkflowNode node;
  final WorkflowState workflowState;
  final Color borderColor;
  final NodeConfig nodeConfig;
  final Widget child;
  final bool isSelected;
  const RectShape({
    super.key,
    required this.node,
    required this.workflowState,
    required this.borderColor,
    required this.child,
    required this.nodeConfig,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (node.status == NodeStatus.running)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node Header
          NodeCardHeader(
            node: node,
            nodeConfig: nodeConfig,
            isSelected: isSelected,
          ),
          child,

          // Node Ports
          NodeCardPort(node: node),
          if (node.error != null) NodeCardErrorMessage(error: node.error!),
        ],
      ),
    );
  }
}
