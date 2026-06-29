import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../connection/model/connection_data.dart';
import '../node/model/schema/node_data.dart';
import '../../model/workflow_connection.dart';
import '../../model/workflow_node.dart';
import 'minimap_painter.dart';

class MinimapWidget extends StatelessWidget {
  final List<WorkflowNode> nodes;
  final List<WorkflowConnection> connections;
  final Offset canvasOffset;
  final double zoom;
  final Size canvasSize;
  final Function(Offset) onNavigate;

  const MinimapWidget({
    super.key,
    required this.nodes,
    required this.connections,
    required this.canvasOffset,
    required this.zoom,
    required this.canvasSize,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: GestureDetector(
        onTapDown: (details) {
          _handleMinimapClick(details.localPosition);
        },
        onPanUpdate: (details) {
          _handleMinimapClick(details.localPosition);
        },
        child: CustomPaint(
          painter: MinimapPainter(
            nodes: nodes,
            connections: connections,
            canvasOffset: canvasOffset,
            zoom: zoom,
            canvasSize: canvasSize,
          ),
        ),
      ),
    );
  }

  void _handleMinimapClick(Offset localPosition) {
    // Calculate the bounds of all nodes
    if (nodes.isEmpty) return;

    final minX = nodes.map((n) => n.position.dx).reduce(math.min);
    final maxX = nodes.map((n) => n.position.dx).reduce(math.max);
    final minY = nodes.map((n) => n.position.dy).reduce(math.min);
    final maxY = nodes.map((n) => n.position.dy).reduce(math.max);

    final contentWidth = maxX - minX + 400;
    final contentHeight = maxY - minY + 400;

    // Calculate scale
    final scaleX = 200 / contentWidth;
    final scaleY = 150 / contentHeight;
    final scale = math.min(scaleX, scaleY);

    // Convert minimap click to canvas position
    final clickX = (localPosition.dx / scale) + minX - 200;
    final clickY = (localPosition.dy / scale) + minY - 150;

    onNavigate(Offset(-clickX, -clickY));
  }
}
