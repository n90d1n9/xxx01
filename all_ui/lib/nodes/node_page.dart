import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'node_card.dart';
import 'node.dart';
import 'node_provider.dart';

class NodeCardTestPage extends ConsumerStatefulWidget {
  const NodeCardTestPage({super.key});

  @override
  ConsumerState<NodeCardTestPage> createState() => _NodeCardTestPageState();
}

class _NodeCardTestPageState extends ConsumerState<NodeCardTestPage> {
  final List<NodeData> _nodes = [
    NodeData(
      id: '1',
      label: 'Agent',
      type: NodeType.agent,
      position: const Offset(100, 100),
      features: ['Model', 'Memory', 'Tool'],
    ),

    NodeData(
      id: '2',
      label: 'LLM',
      type: NodeType.llm,
      position: const Offset(400, 100),
      features: ['Model', 'Temperature'],
    ),
    NodeData(
      id: '3',
      label: 'Start',
      type: NodeType.start,
      position: const Offset(100, 300),
      features: ['Storage', 'Retrieval'],
    ),
  ];

  final List<Connection> _connections = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent Builder - Test Page'),
        backgroundColor: Colors.blueGrey[50],
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: _showDebugInfo),
        ],
      ),
      body: Stack(
        children: [
          // Background grid
          _buildGrid(),

          // Connection lines
          ..._buildConnectionLines(),

          // Nodes
          ..._buildNodes(),

          // Debug panel
          Positioned(top: 16, right: 16, child: _buildDebugPanel()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_node',
            onPressed: _addNewNode,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'clear',
            onPressed: _clearConnections,
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(painter: _GridPainter()),
    );
  }

  List<Widget> _buildConnectionLines() {
    return _connections.map((connection) {
      return CustomPaint(painter: _ConnectionPainter(connection: connection));
    }).toList();
  }

  List<Widget> _buildNodes() {
    return _nodes.map((node) {
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: _buildNodeWidget(node),
      );
    }).toList();
  }

  Widget _buildNodeWidget(NodeData node) {
    return NodeCard(
      data: node,
      key: Key(node.id),
      onTap: () {
        _showNodeDetails(node);
      },
      onLongPress: () {
        _showNodeContextMenu(node, context);
      },
      onDragUpdate: (offset) {
        setState(() {
          node.copyWith(position: offset);
        });
      },
      onInputPortConnected: (sourceId) {
        setState(() {
          _connections.add(Connection(sourceId: sourceId, targetId: node.id));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected $sourceId to ${node.label}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildDebugPanel() {
    final nodeState = ref.watch(nodeStateProvider);

    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Debug Info',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nodes: ${_nodes.length}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Connections: ${_connections.length}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Dragging: ${nodeState.isDragging}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Selected Features: ${nodeState.selectedFeatures.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showNodeDetails(NodeData node) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Node: ${node.label}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${node.id}'),
                Text(
                  'Position: (${node.position.dx.toInt()}, ${node.position.dy.toInt()})',
                ),
                const SizedBox(height: 16),
                const Text('Features:'),
                ...node.features.map((feature) => Text('• $feature')),
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

  void _showNodeContextMenu(NodeData node, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Node'),
              onTap: () {
                Navigator.pop(context);
                _editNode(node);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Create Connection'),
              onTap: () {
                Navigator.pop(context);
                _createConnection(node);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate Node'),
              onTap: () {
                Navigator.pop(context);
                _duplicateNode(node);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Node',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteNode(node);
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewNode() {
    setState(() {
      final newNode = NodeData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: 'New Node ${_nodes.length + 1}',
        position: const Offset(200, 200),
        features: ['Feature 1', 'Feature 2'],
      );
      _nodes.add(newNode);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('New node added!')));
  }

  void _editNode(NodeData node) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Node'),
            content: Text('Editing: ${node.label}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _createConnection(NodeData node) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Start connection from ${node.label}')),
    );
  }

  void _duplicateNode(NodeData node) {
    setState(() {
      final duplicatedNode = NodeData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: '${node.label} Copy',
        position: Offset(node.position.dx + 50, node.position.dy + 50),
        features: List.from(node.features),
      );
      _nodes.add(duplicatedNode);
    });
  }

  void _deleteNode(NodeData node) {
    setState(() {
      _nodes.remove(node);
      _connections.removeWhere(
        (conn) => conn.sourceId == node.id || conn.targetId == node.id,
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted: ${node.label}')));
  }

  void _clearConnections() {
    setState(() {
      _connections.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All connections cleared')));
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Instructions'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🧪 Test Features:'),
                  Text('• Drag nodes around'),
                  Text('• Long press for context menu'),
                  Text('• Tap feature ports to select'),
                  Text('• Drag from output port to input port'),
                  Text('• Add new nodes with FAB'),
                  Text('• Check debug panel for state'),
                  SizedBox(height: 16),
                  Text('🎯 Expected Behavior:'),
                  Text('• Smooth drag & drop'),
                  Text('• Visual feedback on interactions'),
                  Text('• Connection line drawing'),
                  Text('• State persistence with Riverpod'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectionPainter extends CustomPainter {
  final Connection connection;

  _ConnectionPainter({required this.connection});

  @override
  void paint(Canvas canvas, Size size) {
    // This would draw connection lines between nodes
    // For now, it's a placeholder
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
