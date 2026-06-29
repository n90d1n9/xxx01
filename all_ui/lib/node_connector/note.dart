// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

void main() {
  runApp(const ProviderScope(child: NodeConnectorApp()));
}

class NodeConnectorApp extends StatelessWidget {
  const NodeConnectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Node Connector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NodeCanvasScreen(),
    );
  }
}

// Models
class NodeModel {
  final String id;
  final String title;
  final Offset position;
  final Size size;
  final List<ConnectionPort> ports;
  final NodeType type;

  NodeModel({
    required this.id,
    required this.title,
    required this.position,
    required this.size,
    required this.ports,
    required this.type,
  });

  NodeModel copyWith({
    String? id,
    String? title,
    Offset? position,
    Size? size,
    List<ConnectionPort>? ports,
    NodeType? type,
  }) {
    return NodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      size: size ?? this.size,
      ports: ports ?? this.ports,
      type: type ?? this.type,
    );
  }
}

enum NodeType { event, tool, memory, email, database, sendEvent, openAI }

enum PortPosition { left, right, top, bottom }

class ConnectionPort {
  final String id;
  final Offset relativePosition;
  final bool isInput;
  final String? connectedToId;
  final double portRadius = 12.5;
  final PortPosition position;

  ConnectionPort({
    required this.id,
    required this.relativePosition,
    required this.isInput,
    required this.position,
    this.connectedToId,
  });

  ConnectionPort copyWith({
    String? id,
    Offset? relativePosition,
    bool? isInput,
    String? connectedToId,
    PortPosition? position,
  }) {
    return ConnectionPort(
      id: id ?? this.id,
      relativePosition: relativePosition ?? this.relativePosition,
      isInput: isInput ?? this.isInput,
      connectedToId: connectedToId ?? this.connectedToId,
      position: position ?? this.position,
    );
  }

  Offset getAbsolutePosition(Offset nodePosition) {
    return nodePosition + relativePosition;
  }
}

class Connection {
  final String id;
  final String sourcePortId;
  final String targetPortId;
  final String sourceNodeId;
  final String targetNodeId;

  Connection({
    required this.id,
    required this.sourcePortId,
    required this.targetPortId,
    required this.sourceNodeId,
    required this.targetNodeId,
  });
}

// Providers
final nodesProvider = StateNotifierProvider<NodesNotifier, List<NodeModel>>((
  ref,
) {
  return NodesNotifier();
});

final connectionsProvider =
    StateNotifierProvider<ConnectionsNotifier, List<Connection>>((ref) {
      return ConnectionsNotifier();
    });

final draggedPortProvider = StateProvider<ConnectionPort?>((ref) => null);
final activeNodeIdProvider = StateProvider<String?>((ref) => null);
final temporaryConnectionProvider = StateProvider<Map<String, Offset>>(
  (ref) => {},
);

class NodesNotifier extends StateNotifier<List<NodeModel>> {
  NodesNotifier() : super(_initialNodes);

  static List<NodeModel> get _initialNodes => [
    // Event Node - Left side
    NodeModel(
      id: 'event1',
      title: 'Event',
      position: const Offset(100, 100),
      size: const Size(200, 180),
      type: NodeType.event,
      ports: [
        ConnectionPort(
          id: 'event1_out',
          relativePosition: const Offset(200, 90),
          isInput: false,
          position: PortPosition.right,
        ),
      ],
    ),
    // OpenAI Node - Center top
    NodeModel(
      id: 'openai1',
      title: 'OpenAI',
      position: const Offset(400, 50),
      size: const Size(482, 180),
      type: NodeType.openAI,
      ports: [
        ConnectionPort(
          id: 'openai1_in1',
          relativePosition: const Offset(0, 90),
          isInput: true,
          position: PortPosition.left,
        ),
        ConnectionPort(
          id: 'openai1_out1',
          relativePosition: const Offset(482, 90),
          isInput: false,
          position: PortPosition.right,
        ),
        ConnectionPort(
          id: 'openai1_bottom1',
          relativePosition: const Offset(191, 180),
          isInput: false,
          position: PortPosition.bottom,
        ),
        ConnectionPort(
          id: 'openai1_bottom2',
          relativePosition: const Offset(379, 180),
          isInput: false,
          position: PortPosition.bottom,
        ),
      ],
    ),
    // Send Event Node - Right side
    NodeModel(
      id: 'send_event1',
      title: 'Send Event',
      position: const Offset(957, 100),
      size: const Size(200, 180),
      type: NodeType.sendEvent,
      ports: [
        ConnectionPort(
          id: 'send_event1_in',
          relativePosition: const Offset(0, 90),
          isInput: true,
          position: PortPosition.left,
        ),
      ],
    ),
    // Email Node - Bottom left
    NodeModel(
      id: 'email1',
      title: 'Email',
      position: const Offset(400, 450),
      size: const Size(303, 154),
      type: NodeType.email,
      ports: [
        ConnectionPort(
          id: 'email1_in',
          relativePosition: const Offset(152, 0),
          isInput: true,
          position: PortPosition.top,
        ),
      ],
    ),
    // Vector Database Node - Bottom right
    NodeModel(
      id: 'database1',
      title: 'Vector Database',
      position: const Offset(717, 450),
      size: const Size(303, 154),
      type: NodeType.database,
      ports: [
        ConnectionPort(
          id: 'database1_in',
          relativePosition: const Offset(152, 0),
          isInput: true,
          position: PortPosition.top,
        ),
      ],
    ),
  ];

  void moveNode(String id, Offset delta) {
    state =
        state.map((node) {
          if (node.id == id) {
            return node.copyWith(position: node.position + delta);
          }
          return node;
        }).toList();
  }

  void setActiveNode(String id) {
    // Move the active node to the end of the list to ensure it's drawn on top
    final index = state.indexWhere((node) => node.id == id);
    if (index != -1) {
      final activeNode = state[index];
      final newState = [...state];
      newState.removeAt(index);
      newState.add(activeNode);
      state = newState;
    }
  }
}

class ConnectionsNotifier extends StateNotifier<List<Connection>> {
  ConnectionsNotifier() : super(_initialConnections);

  static List<Connection> get _initialConnections => [
    // Event to OpenAI
    Connection(
      id: 'conn1',
      sourcePortId: 'event1_out',
      targetPortId: 'openai1_in1',
      sourceNodeId: 'event1',
      targetNodeId: 'openai1',
    ),
    // OpenAI to Send Event
    Connection(
      id: 'conn2',
      sourcePortId: 'openai1_out1',
      targetPortId: 'send_event1_in',
      sourceNodeId: 'openai1',
      targetNodeId: 'send_event1',
    ),
    // OpenAI to Email
    Connection(
      id: 'conn3',
      sourcePortId: 'openai1_bottom1',
      targetPortId: 'email1_in',
      sourceNodeId: 'openai1',
      targetNodeId: 'email1',
    ),
    // OpenAI to Database
    Connection(
      id: 'conn4',
      sourcePortId: 'openai1_bottom2',
      targetPortId: 'database1_in',
      sourceNodeId: 'openai1',
      targetNodeId: 'database1',
    ),
  ];

  void addConnection(
    String sourceNodeId,
    String sourcePortId,
    String targetNodeId,
    String targetPortId,
  ) {
    final connection = Connection(
      id: 'conn_${state.length + 1}',
      sourcePortId: sourcePortId,
      targetPortId: targetPortId,
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
    );
    state = [...state, connection];
  }

  void removeConnection(String connectionId) {
    state = state.where((connection) => connection.id != connectionId).toList();
  }
}

// Screens
class NodeCanvasScreen extends ConsumerStatefulWidget {
  const NodeCanvasScreen({super.key});

  @override
  ConsumerState<NodeCanvasScreen> createState() => _NodeCanvasScreenState();
}

class _NodeCanvasScreenState extends ConsumerState<NodeCanvasScreen> {
  Offset? _dragStartPosition;
  String? _draggingNodeId;
  ConnectionPort? _draggedPort;
  Offset _dragCurrentPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(nodesProvider);
    final connections = ref.watch(connectionsProvider);
    final tempConnection = ref.watch(temporaryConnectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Node Connector')),
      body: GestureDetector(
        onTapDown: (details) {
          // Deselect any active node when tapping the canvas
          ref.read(activeNodeIdProvider.notifier).state = null;
          // Clear any temporary connection
          if (tempConnection.isNotEmpty) {
            ref.read(temporaryConnectionProvider.notifier).state = {};
          }
        },
        child: Stack(
          children: [
            // Canvas background
            Container(color: Colors.grey[100]),

            // Connections
            CustomPaint(
              size: Size.infinite,
              painter: ConnectionPainter(
                nodes: nodes,
                connections: connections,
                tempConnection: tempConnection,
              ),
            ),

            // Nodes
            ...nodes.map(
              (node) => NodeWidget(
                node: node,
                onDragStart: (position) {
                  _dragStartPosition = position;
                  _draggingNodeId = node.id;
                  ref.read(activeNodeIdProvider.notifier).state = node.id;
                  ref.read(nodesProvider.notifier).setActiveNode(node.id);
                },
                onDragUpdate: (position) {
                  if (_draggingNodeId == node.id &&
                      _dragStartPosition != null) {
                    final delta = position - _dragStartPosition!;
                    _dragStartPosition = position;
                    ref.read(nodesProvider.notifier).moveNode(node.id, delta);
                  }
                },
                onDragEnd: () {
                  _dragStartPosition = null;
                  _draggingNodeId = null;
                },
                onPortDragStart: (port, position) {
                  _draggedPort = port;
                  _dragCurrentPosition = position;
                  ref.read(temporaryConnectionProvider.notifier).state = {
                    port.id: position,
                  };
                },
                onPortDragUpdate: (position) {
                  _dragCurrentPosition = position;
                  if (_draggedPort != null) {
                    ref.read(temporaryConnectionProvider.notifier).state = {
                      _draggedPort!.id: _dragCurrentPosition,
                    };
                  }
                },
                onPortDragEnd: (targetPort, targetNodeId) {
                  if (_draggedPort != null) {
                    // Add connection if an appropriate port was found
                    if (targetPort != null && targetNodeId != null) {
                      final sourceNodeId =
                          nodes
                              .firstWhere(
                                (n) => n.ports.any(
                                  (p) => p.id == _draggedPort!.id,
                                ),
                                orElse: () => nodes.first,
                              )
                              .id;

                      if (_draggedPort!.isInput) {
                        ref
                            .read(connectionsProvider.notifier)
                            .addConnection(
                              targetNodeId,
                              targetPort.id,
                              sourceNodeId,
                              _draggedPort!.id,
                            );
                      } else {
                        ref
                            .read(connectionsProvider.notifier)
                            .addConnection(
                              sourceNodeId,
                              _draggedPort!.id,
                              targetNodeId,
                              targetPort.id,
                            );
                      }
                    }
                  }

                  _draggedPort = null;
                  ref.read(temporaryConnectionProvider.notifier).state = {};
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality to add new nodes
          showDialog(
            context: context,
            builder:
                (context) => const AlertDialog(
                  title: Text("Feature Coming Soon"),
                  content: Text(
                    "Adding new nodes will be available in the next update.",
                  ),
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widgets
class NodeWidget extends ConsumerWidget {
  final NodeModel node;
  final Function(Offset) onDragStart;
  final Function(Offset) onDragUpdate;
  final Function() onDragEnd;
  final Function(ConnectionPort, Offset) onPortDragStart;
  final Function(Offset) onPortDragUpdate;
  final Function(ConnectionPort?, String?) onPortDragEnd;

  const NodeWidget({
    super.key,
    required this.node,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onPortDragStart,
    required this.onPortDragUpdate,
    required this.onPortDragEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNodeId = ref.watch(activeNodeIdProvider);
    final isActive = activeNodeId == node.id;

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          onDragStart(details.globalPosition);
        },
        onPanUpdate: (details) {
          onDragUpdate(details.globalPosition);
        },
        onPanEnd: (details) {
          onDragEnd();
        },
        onTap: () {
          ref.read(activeNodeIdProvider.notifier).state = node.id;
          ref.read(nodesProvider.notifier).setActiveNode(node.id);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Node body
            Material(
              color: Colors.transparent,
              elevation: isActive ? 8 : 2,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: node.size.width,
                height: node.size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color:
                        isActive ? Colors.blue : Colors.blue.withOpacity(0.5),
                    width: isActive ? 2.5 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    node.title,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),

            // Ports
            ...node.ports.map(
              (port) => PortWidget(
                port: port,
                nodePosition: node.position,
                onDragStart: (position) {
                  onPortDragStart(port, position);
                },
                onDragUpdate: onPortDragUpdate,
                onDragEnd: onPortDragEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PortWidget extends ConsumerWidget {
  final ConnectionPort port;
  final Offset nodePosition;
  final Function(Offset) onDragStart;
  final Function(Offset) onDragUpdate;
  final Function(ConnectionPort?, String?) onDragEnd;

  const PortWidget({
    super.key,
    required this.port,
    required this.nodePosition,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(nodesProvider);
    final portPosition = port.relativePosition;
    final portSize = port.portRadius * 2;

    return Positioned(
      left: portPosition.dx - port.portRadius,
      top: portPosition.dy - port.portRadius,
      width: portSize,
      height: portSize,
      child: GestureDetector(
        onPanStart: (details) {
          // Pass the center of the port as the start position
          final portCenter = nodePosition + portPosition;
          onDragStart(portCenter);
        },
        onPanUpdate: (details) {
          onDragUpdate(details.globalPosition);
        },
        onPanEnd: (details) {
          // Try to find a compatible port
          ConnectionPort? targetPort;
          String? targetNodeId;

          final absolutePortPosition = nodePosition + portPosition;

          for (final node in nodes) {
            for (final p in node.ports) {
              if (p.id == port.id) continue; // Skip self

              final absoluteTargetPosition = node.position + p.relativePosition;
              final distance =
                  (absoluteTargetPosition - absolutePortPosition).distance;

              // Check if we're close enough and ports are compatible (input connects to output)
              if (distance < 30 && p.isInput != port.isInput) {
                targetPort = p;
                targetNodeId = node.id;
                break;
              }
            }
            if (targetPort != null) break;
          }

          onDragEnd(targetPort, targetNodeId);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[700]!, width: 1),
          ),
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final List<Connection> connections;
  final Map<String, Offset> tempConnection;

  ConnectionPainter({
    required this.nodes,
    required this.connections,
    required this.tempConnection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final dashPaint =
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Draw permanent connections
    for (final connection in connections) {
      final sourceNode = nodes.firstWhere(
        (node) => node.id == connection.sourceNodeId,
      );
      final targetNode = nodes.firstWhere(
        (node) => node.id == connection.targetNodeId,
      );

      final sourcePort = sourceNode.ports.firstWhere(
        (port) => port.id == connection.sourcePortId,
      );
      final targetPort = targetNode.ports.firstWhere(
        (port) => port.id == connection.targetPortId,
      );

      final p1 = sourceNode.position + sourcePort.relativePosition;
      final p2 = targetNode.position + targetPort.relativePosition;

      _drawConnection(
        canvas,
        p1,
        p2,
        sourcePort.position,
        targetPort.position,
        paint,
      );
    }

    // Draw temporary connection if dragging
    if (tempConnection.isNotEmpty) {
      final entry = tempConnection.entries.first;
      final portId = entry.key;
      final dragPoint = entry.value;

      // Find the source point and its position type
      for (final node in nodes) {
        final port = node.ports.firstWhere(
          (p) => p.id == portId,
          orElse:
              () => ConnectionPort(
                id: '',
                relativePosition: Offset.zero,
                isInput: false,
                position: PortPosition.right,
              ),
        );

        if (port.id == portId) {
          final p1 = node.position + port.relativePosition;
          // For temporary connections, we don't know the target port position, so we use a default
          _drawDashedLine(
            canvas,
            p1,
            dragPoint,
            port.position,
            port.isInput ? PortPosition.right : PortPosition.left,
            dashPaint,
          );
          break;
        }
      }
    }
  }

  void _drawConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    PortPosition startPosition,
    PortPosition endPosition,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Adjust control points based on port positions
    double firstControlX, firstControlY, secondControlX, secondControlY;

    // Determine control point offsets based on the port positions
    switch (startPosition) {
      case PortPosition.left:
        firstControlX = start.dx - 50;
        break;
      case PortPosition.right:
        firstControlX = start.dx + 50;
        break;
      case PortPosition.top:
        firstControlX = start.dx;
        break;
      case PortPosition.bottom:
        firstControlX = start.dx;
        break;
    }

    switch (endPosition) {
      case PortPosition.left:
        secondControlX = end.dx - 50;
        break;
      case PortPosition.right:
        secondControlX = end.dx + 50;
        break;
      case PortPosition.top:
        secondControlX = end.dx;
        break;
      case PortPosition.bottom:
        secondControlX = end.dx;
        break;
    }

    // Vertical control points
    switch (startPosition) {
      case PortPosition.left:
      case PortPosition.right:
        firstControlY = start.dy;
        break;
      case PortPosition.top:
        firstControlY = start.dy - 50;
        break;
      case PortPosition.bottom:
        firstControlY = start.dy + 50;
        break;
    }

    switch (endPosition) {
      case PortPosition.left:
      case PortPosition.right:
        secondControlY = end.dy;
        break;
      case PortPosition.top:
        secondControlY = end.dy - 50;
        break;
      case PortPosition.bottom:
        secondControlY = end.dy + 50;
        break;
    }

    // Draw the Bezier curve with calculated control points
    path.cubicTo(
      firstControlX,
      firstControlY,
      secondControlX,
      secondControlY,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    PortPosition startPosition,
    PortPosition endPosition,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Similar control point logic as in _drawConnection
    double firstControlX, firstControlY, secondControlX, secondControlY;

    switch (startPosition) {
      case PortPosition.left:
        firstControlX = start.dx - 50;
        break;
      case PortPosition.right:
        firstControlX = start.dx + 50;
        break;
      case PortPosition.top:
        firstControlX = start.dx;
        break;
      case PortPosition.bottom:
        firstControlX = start.dx;
        break;
    }

    // For end point, we just use a generic approach since we don't know its type yet
    if (end.dx > start.dx) {
      secondControlX = end.dx - 50;
    } else {
      secondControlX = end.dx + 50;
    }

    switch (startPosition) {
      case PortPosition.left:
      case PortPosition.right:
        firstControlY = start.dy;
        break;
      case PortPosition.top:
        firstControlY = start.dy - 50;
        break;
      case PortPosition.bottom:
        firstControlY = start.dy + 50;
        break;
    }

    // For temporary connection end point
    if (end.dy > start.dy) {
      secondControlY = end.dy - 20;
    } else {
      secondControlY = end.dy + 20;
    }

    path.cubicTo(
      firstControlX,
      firstControlY,
      secondControlX,
      secondControlY,
      end.dx,
      end.dy,
    );

    final dashWidth = 6;
    final dashSpace = 4;
    final pathMetrics = path.computeMetrics().first;
    var distance = 0.0;

    while (distance < pathMetrics.length) {
      final start = distance;
      final end = distance + dashWidth;

      if (end > pathMetrics.length) {
        break;
      }

      final extractPath = pathMetrics.extractPath(start, end);
      canvas.drawPath(extractPath, paint);

      distance = end + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
