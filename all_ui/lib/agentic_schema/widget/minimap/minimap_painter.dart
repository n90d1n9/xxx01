import 'package:flutter/material.dart';

import '../../schema/workflow/workflow_edge.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/canvas_provider.dart';

class MinimapPainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final CanvasState canvasState;
  final Size viewportSize;

  MinimapPainter({
    required this.nodes,
    required this.edges,
    required this.canvasState,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final bounds = _calculateBounds();
    final scale = _calculateScale(bounds, size);

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.grey.shade100,
    );

    canvas.save();
    canvas.translate(-bounds.left * scale, -bounds.top * scale);
    canvas.scale(scale);

    // Draw edges
    for (final edge in edges) {
      _drawEdge(canvas, edge);
    }

    // Draw nodes
    for (final node in nodes) {
      _drawNode(canvas, node);
    }

    canvas.restore();

    // Draw viewport rectangle
    _drawViewport(canvas, bounds, scale, size);
  }

  void _drawNode(Canvas canvas, WorkflowNode node) {
    final rect = Rect.fromLTWH(node.position.x, node.position.y, 200, 100);

    canvas.drawRect(
      rect,
      Paint()
        ..color = node.type.color.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..color = node.type.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawEdge(Canvas canvas, WorkflowEdge edge) {
    final sourceNode = nodes.firstWhere((n) => n.id == edge.source);
    final targetNode = nodes.firstWhere((n) => n.id == edge.target);

    final start = Offset(
      sourceNode.position.x + 100,
      sourceNode.position.y + 50,
    );
    final end = Offset(targetNode.position.x + 100, targetNode.position.y + 50);

    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1.5,
    );
  }

  void _drawViewport(Canvas canvas, Rect bounds, double scale, Size size) {
    final viewportRect = Rect.fromLTWH(
      (-canvasState.panOffset.dx / canvasState.zoom - bounds.left) * scale,
      (-canvasState.panOffset.dy / canvasState.zoom - bounds.top) * scale,
      (viewportSize.width / canvasState.zoom) * scale,
      (viewportSize.height / canvasState.zoom) * scale,
    );

    canvas.drawRect(
      viewportRect,
      Paint()
        ..color = Colors.blue.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      viewportRect,
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  Rect _calculateBounds() {
    if (nodes.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = node.position.x < minX ? node.position.x : minX;
      minY = node.position.y < minY ? node.position.y : minY;
      maxX = node.position.x + 200 > maxX ? node.position.x + 200 : maxX;
      maxY = node.position.y + 100 > maxY ? node.position.y + 100 : maxY;
    }

    // Add padding
    const padding = 50.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  double _calculateScale(Rect bounds, Size size) {
    final scaleX = size.width / bounds.width;
    final scaleY = size.height / bounds.height;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  @override
  bool shouldRepaint(MinimapPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.canvasState != canvasState;
  }
}
