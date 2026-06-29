import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../model/workflow_connection.dart';
import '../../../../model/workflow_node.dart';
import '../../../../state/connection_provider.dart';
import '../../../../state/workflow_provider.dart';
import '../../../../model/workflow_node_port.dart';
import '../../../connection/widget/connection_painter.dart';

class NodeCardInputPort extends ConsumerStatefulWidget {
  final WorkflowNodePort port;
  final String parentNodeId;
  final bool isConnected;
  final WorkflowConnection? existingConnection;
  final WorkflowNode node;
  final String? targetPortId;

  const NodeCardInputPort({
    super.key,
    required this.port,
    required this.parentNodeId,
    this.isConnected = false,
    this.existingConnection,
    required this.node,
    this.targetPortId,
  });

  @override
  ConsumerState<NodeCardInputPort> createState() => _NodeCardInputPortState();
}

class _NodeCardInputPortState extends ConsumerState<NodeCardInputPort> {
  String _selectedConnectionId = '';
  @override
  Widget build(BuildContext context) {
    // Base color: green if connected, blue otherwise
    final baseColor = widget.isConnected ? Colors.green : Colors.grey;

    // Hover state
    final isHovered =
        ref.watch(workflowProvider).hoveredInputNodeId == widget.parentNodeId &&
        ref.watch(workflowProvider).hoveredInputPortId == widget.port.id;

    return MouseRegion(
      onEnter: (_) {
        ref
            .read(workflowProvider.notifier)
            .setHoveredInputPort(widget.parentNodeId, widget.port.id);
      },
      onExit: (_) {
        ref.read(workflowProvider.notifier).setHoveredInputPort(null, null);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final fromNodeId = ref.watch(connectingFromNodeProvider);
          final fromPortId = ref.watch(connectingFromPortProvider);

          if (fromNodeId != null && fromPortId != null) {
            // 🟢 Create new connection (only if not self-loop)
            if (fromNodeId != widget.node.id) {
              ref
                  .read(workflowProvider.notifier)
                  .addConnection(
                    fromNodeId,
                    widget.node.id,
                    fromPortId,
                    widget.targetPortId!,
                    //entry.value.id,
                  );
              // Clear connection state
              ref.read(connectingFromNodeProvider.notifier).state = null;
              ref.read(connectingFromPortProvider.notifier).state = null;
              ref
                  .read(workflowProvider.notifier)
                  .setHoveredInputPort(null, null);
            }
          } else {
            // 🔴 Disconnect if already connected
            if (widget.existingConnection != null) {
              ref
                  .read(workflowProvider.notifier)
                  .deleteConnection(widget.existingConnection!.id);
            }
          }
        },
        onSecondaryTap: () {
          _showConnectionContextMenu(widget.existingConnection!, context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHovered
                ? baseColor.withValues(alpha: 0.4)
                : baseColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHovered
                  ? Colors.white
                  : baseColor.withValues(alpha: 0.7),
              width: isHovered ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: baseColor, // ✅ Use baseColor, not hardcoded blue
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.port.label,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPropertiesPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Properties'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Text('Connection ID: ${widget.connectionId}'),
            Text(
              'Line Type: ${_getLineTypeName(ref.watch(connectionProvider).lineType)}',
            ),
            Text(
              'Start: (${widget.start.dx.toStringAsFixed(1)}, ${widget.start.dy.toStringAsFixed(1)})',
            ),
            Text(
              'End: (${widget.end.dx.toStringAsFixed(1)}, ${widget.end.dy.toStringAsFixed(1)})',
            ), */
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleRightClick(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          child: const Text("Change Line Type"),
          onTap: () => _showLineTypeDialog(context),
        ),
        PopupMenuItem(
          child: const Text("Delete Connection"),
          onTap: () => _deleteConnection(),
        ),
        PopupMenuItem(
          child: const Text("Properties"),
          onTap: () => _showPropertiesPanel(),
        ),
      ],
    );
  }

  void _showLineTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Connection Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ConnectionLineType.values.map((type) {
            return ListTile(
              title: Text(_getLineTypeName(type)),
              trailing: ref.watch(connectionProvider).lineType == type
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _changeLineType(type);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _changeLineType(ConnectionLineType newType) {
    // You can implement this to update the connection type in your state
    // print('Changing connection ${widget.connectionId} to $newType');
    // ref.read(workflowProvider.notifier).updateConnectionType(widget.connectionId, newType);
  }

  void _deleteConnection() {
    // You can implement this to delete the connection
    // print('Deleting connection ${widget.connectionId}');
    // ref.read(workflowProvider.notifier).deleteConnection(widget.connectionId);
  }

  void _showConnectionContextMenu(
    WorkflowConnection connection,
    BuildContext context,
  ) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
        100,
        100,
        0,
        0,
      ), // Adjust position as needed
      items: [
        PopupMenuItem(
          child: const Text("Change Line Type"),
          onTap: () => _changeConnectionLineType(connection),
        ),
        PopupMenuItem(
          child: const Text("Delete Connection"),
          onTap: () {
            ref.read(workflowProvider.notifier).deleteConnection(connection.id);
            _deselectConnection();
          },
        ),
        PopupMenuItem(
          child: const Text("Properties"),
          onTap: () => _showConnectionProperties(connection),
        ),
      ],
    );
  }

  void _deselectConnection() {
    setState(() {
      _selectedConnectionId = '';
    });
  }

  ConnectionLineType _getConnectionLineType(WorkflowConnection connection) {
    // You can store line type in connection data or use a default
    // For now, using curved as default
    return ConnectionLineType.curved;
  }

  void _selectConnection(String connectionId) {
    setState(() {
      _selectedConnectionId = connectionId;
    });
    // Also deselect any selected node
    ref.read(workflowProvider.notifier).selectNode(null);
  }

  void _showConnectionProperties(WorkflowConnection connection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Properties'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${connection.id}'),
            Text('Source: ${connection.sourceNodeId}'),
            Text('Target: ${connection.targetNodeId}'),
            Text('Source Port: ${connection.sourcePortId}'),
            Text('Target Port: ${connection.targetPortId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _changeConnectionLineType(WorkflowConnection connection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Line Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ConnectionLineType.values.map((type) {
            return ListTile(
              title: Text(_getLineTypeName(type)),
              onTap: () {
                Navigator.pop(context);
                // Implement connection line type change in your state
                // ref.read(workflowProvider.notifier).updateConnectionLineType(connection.id, type);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLineTypeName(ConnectionLineType type) {
    switch (type) {
      case ConnectionLineType.straight:
        return 'Straight Line';
      case ConnectionLineType.curved:
        return 'Curved Line';
      case ConnectionLineType.elbow:
        return 'Elbow Line';
      case ConnectionLineType.stepped:
        return 'Stepped Line';
      case ConnectionLineType.bezier:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
