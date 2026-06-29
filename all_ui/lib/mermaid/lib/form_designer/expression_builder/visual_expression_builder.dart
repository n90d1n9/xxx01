import 'package:flutter/material.dart';

import 'express.dart';

class VisualExpressionBuilder extends StatefulWidget {
  final Function(String) onExpressionBuilt;

  const VisualExpressionBuilder({super.key, required this.onExpressionBuilt});

  @override
  State<VisualExpressionBuilder> createState() =>
      _VisualExpressionBuilderState();
}

class _VisualExpressionBuilderState extends State<VisualExpressionBuilder> {
  List<ExpressionNode> nodes = [];
  List<ExpressionConnection> connections = [];
  ExpressionNode? selectedNode;
  Offset? dragOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(),

          // Canvas
          Expanded(
            child: Stack(
              children: [
                // Grid background
                CustomPaint(painter: GridPainter(), child: Container()),

                // Connections
                CustomPaint(
                  painter: ConnectionPainter(connections),
                  child: Container(),
                ),

                // Nodes
                ...nodes.map((node) => _buildNode(node)),
              ],
            ),
          ),

          // Expression output
          _buildExpressionOutput(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.functions, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Expression Builder',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _ToolButton(
            icon: Icons.add_circle,
            label: 'Field',
            onPressed: () => _addNode(ExpressionNodeType.field),
          ),
          _ToolButton(
            icon: Icons.calculate,
            label: 'Operator',
            onPressed: () => _addNode(ExpressionNodeType.operator),
          ),
          _ToolButton(
            icon: Icons.numbers,
            label: 'Number',
            onPressed: () => _addNode(ExpressionNodeType.constant),
          ),
          _ToolButton(
            icon: Icons.functions,
            label: 'Function',
            onPressed: () => _addNode(ExpressionNodeType.function),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: _clearAll,
          ),
        ],
      ),
    );
  }

  Widget _buildNode(ExpressionNode node) {
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            selectedNode = node;
            dragOffset = details.localPosition;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            final index = nodes.indexWhere((n) => n.id == node.id);
            nodes[index] = node.copyWith(
              position: details.localPosition - (dragOffset ?? Offset.zero),
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            selectedNode = null;
            dragOffset = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getNodeColor(node.type),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedNode?.id == node.id ? Colors.blue : Colors.white24,
              width: selectedNode?.id == node.id ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getNodeIcon(node.type), color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                node.value ?? node.type.toString().split('.').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpressionOutput() {
    final expression = _buildExpression();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border(top: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generated Expression:',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              expression.isEmpty ? 'Build your expression...' : expression,
              style: const TextStyle(
                color: Color(0xFF4EC9B0),
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor(ExpressionNodeType type) {
    switch (type) {
      case ExpressionNodeType.field:
        return Colors.blue.withOpacity(0.8);
      case ExpressionNodeType.operator:
        return Colors.orange.withOpacity(0.8);
      case ExpressionNodeType.constant:
        return Colors.green.withOpacity(0.8);
      case ExpressionNodeType.function:
        return Colors.purple.withOpacity(0.8);
    }
  }

  IconData _getNodeIcon(ExpressionNodeType type) {
    switch (type) {
      case ExpressionNodeType.field:
        return Icons.input;
      case ExpressionNodeType.operator:
        return Icons.calculate;
      case ExpressionNodeType.constant:
        return Icons.numbers;
      case ExpressionNodeType.function:
        return Icons.functions;
    }
  }

  void _addNode(ExpressionNodeType type) {
    setState(() {
      nodes.add(
        ExpressionNode(
          id: 'node_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          value: type == ExpressionNodeType.constant ? '0' : null,
          position: Offset(
            100 + nodes.length * 20.0,
            100 + nodes.length * 20.0,
          ),
        ),
      );
    });
  }

  void _clearAll() {
    setState(() {
      nodes.clear();
      connections.clear();
    });
  }

  String _buildExpression() {
    if (nodes.isEmpty) return '';
    // Simple expression building - in real app, use connection graph
    return nodes.map((n) => n.value ?? n.type.toString()).join(' ');
  }
}

class ExpressionConnection {
  final String fromNodeId;
  final String toNodeId;
  final Offset fromPoint;
  final Offset toPoint;

  const ExpressionConnection({
    required this.fromNodeId,
    required this.toNodeId,
    required this.fromPoint,
    required this.toPoint,
  });
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const gridSize = 20.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ConnectionPainter extends CustomPainter {
  final List<ExpressionConnection> connections;

  ConnectionPainter(this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final path = Path()
        ..moveTo(conn.fromPoint.dx, conn.fromPoint.dy)
        ..cubicTo(
          conn.fromPoint.dx + 50,
          conn.fromPoint.dy,
          conn.toPoint.dx - 50,
          conn.toPoint.dy,
          conn.toPoint.dx,
          conn.toPoint.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton.icon(
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
