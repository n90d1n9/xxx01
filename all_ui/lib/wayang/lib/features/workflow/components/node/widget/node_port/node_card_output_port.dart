import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/workflow_connection.dart';
import '../../../../model/workflow_node.dart';
import '../../../../model/workflow_node_port.dart';
import '../../../../state/connection_provider.dart';
import '../../../../state/workflow_provider.dart';
import '../../../connection/widget/connection_painter.dart';

class NodeCardOutputPort extends ConsumerStatefulWidget {
  final String nodeId;
  final WorkflowNodePort port;
  final int index;
  final bool isConnected;
  final WorkflowConnection? existingConnection;
  final WorkflowNode node;
  final String? targetPortId;

  const NodeCardOutputPort({
    super.key,
    required this.nodeId,
    required this.port,
    required this.index,

    this.isConnected = false,
    this.existingConnection,
    required this.node,
    this.targetPortId,
  });

  @override
  ConsumerState<NodeCardOutputPort> createState() => _NodeCardOutputPortState();
}

class _NodeCardOutputPortState extends ConsumerState<NodeCardOutputPort> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        if (ref.read(draggingNodeProvider)) return;

        ref.read(connectingFromNodeProvider.notifier).state = widget.node.id;
        ref.read(connectingFromPortProvider.notifier).state =
            widget.targetPortId; //entry.value.id;
      },
      onPanUpdate: (details) {
        // 🔑 Convert global drag position → canvas coordinates
        final globalPos = details.globalPosition;
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPos = renderBox.globalToLocal(globalPos);
        final workflowState = ref.watch(workflowProvider);

        // Transform to canvas space: undo zoom and offset
        final canvasPos =
            (localPos / workflowState.zoom) - workflowState.canvasOffset;

        ref
            .read(workflowProvider.notifier)
            .setConnectionDragEndpoint(canvasPos);
      },
      onPanEnd: (_) {
        ref.read(workflowProvider.notifier).clearConnectionDrag();
      },
      onPanCancel: () {
        ref.read(connectingFromNodeProvider.notifier).state = null;
        ref.read(connectingFromPortProvider.notifier).state = null;
        ref.read(workflowProvider.notifier).clearConnectionDrag();
      },
      onTap: () {
        // Start connection from this output port
        ref.read(connectingFromNodeProvider.notifier).state = widget.node.id;
        ref.read(connectingFromPortProvider.notifier).state =
            widget.targetPortId;
        //entry.value.id;
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Flexible(
              child: Text(
                port.label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6), */
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
