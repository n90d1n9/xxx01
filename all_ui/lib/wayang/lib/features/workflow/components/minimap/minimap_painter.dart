import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/workflow_connection.dart';
import '../../model/workflow_node.dart';

enum MinimapNodeShape { circle, rectangle }

class MinimapPainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowConnection> connections;
  final Offset canvasOffset;
  final double zoom;
  final Size canvasSize;
  final MinimapNodeShape nodeShape;

  MinimapPainter({
    required this.nodes,
    required this.connections,
    required this.canvasOffset,
    required this.zoom,
    required this.canvasSize,
    this.nodeShape = MinimapNodeShape.rectangle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // Calculate bounds
    final minX = nodes.map((n) => n.position.dx).reduce(math.min);
    final maxX = nodes.map((n) => n.position.dx).reduce(math.max);
    final minY = nodes.map((n) => n.position.dy).reduce(math.min);
    final maxY = nodes.map((n) => n.position.dy).reduce(math.max);

    final contentWidth = maxX - minX + 400;
    final contentHeight = maxY - minY + 400;

    // Calculate scale to fit minimap
    final scaleX = size.width / contentWidth;
    final scaleY = size.height / contentHeight;
    final scale = math.min(scaleX, scaleY);

    // Draw connections
    drawConnection(canvas, minX, minY, scale);

    // Draw nodes
    if (nodeShape == MinimapNodeShape.circle) {
      drawNodesCircle(canvas, minX, minY, scale);
    } else {
      drawNodesRect(canvas, minX, minY, scale);
    }

    // Draw viewport rectangle
    drawViewPortRect(canvas, minX, minY, scale);
  }

  void drawConnection(Canvas canvas, double minX, double minY, double scale) {
    final connectionPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (final conn in connections) {
      final sourceNode = nodes.firstWhere((n) => n.id == conn.sourceNodeId);
      final targetNode = nodes.firstWhere((n) => n.id == conn.targetNodeId);

      final start = Offset(
        (sourceNode.position.dx - minX) * scale,
        (sourceNode.position.dy - minY) * scale,
      );
      final end = Offset(
        (targetNode.position.dx - minX) * scale,
        (targetNode.position.dy - minY) * scale,
      );

      canvas.drawLine(start, end, connectionPaint);
    }
  }

  void drawNodesRect(Canvas canvas, double minX, double minY, double scale) {
    final nodePaint = Paint()..style = PaintingStyle.fill;
    for (final comp in nodes) {
      final rect = Rect.fromLTWH(
        (comp.position.dx - minX) * scale + 10,
        (comp.position.dy - minY) * scale + 10,
        180 * scale,
        80 * scale,
      );

      nodePaint.color = _getNodeColor(comp.type);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        nodePaint,
      );
    }
  }

  void drawNodesCircle(Canvas canvas, double minX, double minY, double scale) {
    final nodePaint = Paint()..style = PaintingStyle.fill;

    for (final node in nodes) {
      final x = (node.position.dx - minX) * scale;
      final y = (node.position.dy - minY) * scale;

      nodePaint.color = _getNodeColor(node.type);
      canvas.drawCircle(Offset(x, y), 6, nodePaint);
    }
  }

  void drawViewPortRect(Canvas canvas, double minX, double minY, double scale) {
    final viewportRect = Rect.fromLTWH(
      (-canvasOffset.dx - minX) * scale,
      (-canvasOffset.dy - minY) * scale,
      (canvasSize.width / zoom) / 2 * scale,
      (canvasSize.height / zoom) / 2 * scale,
    );

    final viewportPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(viewportRect, viewportPaint);
  }

  /* Color _getNodeColor(NodeType type) {
    switch (type) {
      case NodeType.webhook:
        return Colors.green;
      case NodeType.llm:
        return Colors.purple;
      case NodeType.condition:
        return Colors.orange;
      case NodeType.api:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  } */

  Color _getNodeColor(String type) {
    switch (type) {
      case 'webhook':
        return Colors.green;
      case 'llm':
        return Colors.purple;
      case 'condition':
        return Colors.orange;
      case 'api':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  @override
  bool shouldRepaint(MinimapPainter oldDelegate) => true;
}
