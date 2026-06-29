import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayang_builder/features/workflow/components/node/widget/node_shape/start_shape.dart';
import '../../../../../../dummy.dart';

import '../../model/schema/node_type_config.dart';
import '../../../../model/workflow_node.dart';
import '../../../../state/workflow_state.dart';
import '../../../../state/workflow_provider.dart';
import '../../../../model/workflow_node_port.dart';
import '../node_ui_registry.dart';
import 'default_node.dart';

class NodeCard extends ConsumerStatefulWidget {
  final WorkflowNode node;
  final WorkflowState workflowState;
  const NodeCard({super.key, required this.node, required this.workflowState});

  @override
  ConsumerState<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends ConsumerState<NodeCard> {
  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);

    final allNodes = nodeTypesByCategory.values.expand((list) => list).toList();
    final nodeConfig = allNodes.firstWhere((t) => t.type == widget.node.type);
    final isSelected = workflowState.selectedNodeId == widget.node.id;
    final position = widget.node.position + workflowState.canvasOffset;

    Color borderColor = nodeConfig.style!.color.withValues(alpha: 0.3);
    if (isSelected) {
      borderColor = nodeConfig.style!.color;
    } else if (widget.node.status == NodeStatus.running) {
      borderColor = Colors.blue;
    } else if (widget.node.status == NodeStatus.success) {
      borderColor = Colors.green;
    } else if (widget.node.status == NodeStatus.error) {
      borderColor = Colors.red;
    }

    return Positioned(
      left: position.dx * workflowState.zoom,
      top: position.dy * workflowState.zoom,
      child: Transform.scale(
        scale: workflowState.zoom,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 220,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                ref.read(draggingNodeProvider.notifier).state = true;
              });
              ref.read(workflowProvider.notifier).selectNode(widget.node.id);

              // Use improved drag method
              ref.read(workflowProvider.notifier).startNodeDrag(widget.node.id);
            },
            onPanUpdate: (details) {
              ref
                  .read(workflowProvider.notifier)
                  .updateNodePosition(
                    widget.node.id,
                    widget.node.position + details.delta / workflowState.zoom,
                  );
            },
            onPanEnd: (details) {
              setState(() {
                ref.read(draggingNodeProvider.notifier).state = false;
              });

              // Use improved drag method
              ref.read(workflowProvider.notifier).endNodeDrag();
            },
            onPanCancel: () {
              setState(() {
                ref.read(draggingNodeProvider.notifier).state = false;
              });

              // Use improved drag method
              ref.read(workflowProvider.notifier).endNodeDrag();
            },
            onTap: () {
              ref.read(workflowProvider.notifier).selectNode(widget.node.id);
            },
            child: _buildNodeBody(
              nodeConfig,
              widget.node,
              workflowState,
              borderColor,
            ),
          ),
        ),
      ),
    );
  }

  _buildNodeBody(
    NodeConfig nodeConfig,
    WorkflowNode node,
    WorkflowState workflowState,
    Color borderColor,
  ) {
    switch (nodeConfig.category) {
      case 'Triggers':
        /* return StartShape(
          node: node,
          workflowState: workflowState,
          nodeConfig: nodeConfig,
          child: buildNodeBody(widget.node, widget.workflowState),
        ); */
        return DefaultNode(
          node: node,
          workflowState: workflowState,
          borderColor: borderColor,
          nodeConfig: nodeConfig,
          isSelected: workflowState.selectedNodeId == node.id,
          child: buildNodeBody(widget.node, widget.workflowState),
        );
      default:
        return DefaultNode(
          node: node,
          workflowState: workflowState,
          borderColor: borderColor,
          nodeConfig: nodeConfig,
          isSelected: workflowState.selectedNodeId == node.id,
          child: buildNodeBody(widget.node, widget.workflowState),
        );
    }
  }
}
