import 'package:flutter/material.dart';
import 'package:wayang_builder/features/workflow/components/node/widget/node_shape/rect_shape.dart';

import '../../model/schema/node_type_config.dart';
import '../../../../model/workflow_node.dart';
import '../../../../state/workflow_state.dart';

class DefaultNode extends StatelessWidget {
  final WorkflowNode node;
  final WorkflowState workflowState;
  final Color borderColor;
  final NodeConfig nodeConfig;
  final Widget child;
  final bool isSelected;
  const DefaultNode({
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
    return RectShape(
      node: node,
      workflowState: workflowState,
      borderColor: borderColor,
      nodeConfig: nodeConfig,
      child: child,
    );
  }
}
