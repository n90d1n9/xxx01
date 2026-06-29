import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/node_card.dart';
import '../models/canvas_transform.dart';
import '../models/node_connection.dart';
import '../states/connection_provider.dart';

class ConnectionPainter extends CustomPainter {
  final List<NodeCard> nodes;
  final String? selectedNodeId;
  final Set<String> selectedNodeIds;
  final CanvasTransform transform;
  final ConnectionRoutingMode routingMode;

  ConnectionPainter({
    required this.nodes,
    required this.selectedNodeId,
    required this.selectedNodeIds,
    required this.transform,
    required this.routingMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Build a map of nodes by ID for easy lookup
    final nodeMap = <String, NodeCard>{};
    for (final node in nodes) {
      nodeMap[node.id] = node;
    }

    // Draw all connections
    for (final node in nodes) {
      for (final connection in node.connections) {
        final targetNode = nodeMap[connection.targetNodeId];
        if (targetNode != null) {
          _drawConnection(canvas, node, targetNode, connection, transform);
        }
      }
    }
  }

  void _drawConnection(
    Canvas canvas,
    NodeCard sourceNode,
    NodeCard targetNode,
    NodeConnection connection,
    CanvasTransform transform,
  ) {
    // Convert canvas positions to screen positions
    final sourceScreenPos = _canvasToScreen(sourceNode.position, transform);
    final targetScreenPos = _canvasToScreen(targetNode.position, transform);

    // Adjust positions to node widget boundaries (NodeWidget is 120x80)
    final sourceCenter = sourceScreenPos;
    final targetCenter = targetScreenPos;

    // Calculate direction vector
    final direction = targetCenter - sourceCenter;
    final distance = direction.distance;

    if (distance < 1.0) return; // Skip if too close

    final normalizedDirection = direction / distance;

    // Calculate connection start and end points (edge of nodes)
    final nodeRadius = 40.0 * transform.scale; // Approximate node radius
    final sourcePoint = sourceCenter + normalizedDirection * nodeRadius;
    final targetPoint = targetCenter - normalizedDirection * nodeRadius;

    // Determine connection color based on selection state
    Color connectionColor;
    final strokeWidth = 2.0 * transform.scale;

    if (selectedNodeId == sourceNode.id || selectedNodeId == targetNode.id) {
      connectionColor = Colors.orange;
    } else if (selectedNodeIds.contains(sourceNode.id) ||
        selectedNodeIds.contains(targetNode.id)) {
      connectionColor = Colors.amber;
    } else {
      connectionColor = Colors.grey.withOpacity(0.7);
    }

    final paint =
        Paint()
          ..color = connectionColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Draw connection based on routing mode
    switch (routingMode) {
      case ConnectionRoutingMode.straight:
        _drawStraightConnection(canvas, sourcePoint, targetPoint, paint);
        break;
      case ConnectionRoutingMode.bezier:
        _drawBezierConnection(canvas, sourcePoint, targetPoint, paint);
        break;
      case ConnectionRoutingMode.orthogonal:
        _drawOrthogonalConnection(canvas, sourcePoint, targetPoint, paint);
        break;
    }

    // Draw arrow head
    _drawArrowHead(canvas, targetPoint, normalizedDirection, paint);
  }

  void _drawStraightConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    canvas.drawLine(start, end, paint);
  }

  void _drawBezierConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final controlPoint1 = start + Offset((end.dx - start.dx) * 0.5, start.dy);
    final controlPoint2 = end + Offset((start.dx - end.dx) * 0.5, end.dy);

    final path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            end.dx,
            end.dy,
          );

    canvas.drawPath(path, paint);
  }

  void _drawOrthogonalConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final midX = start.dx + (end.dx - start.dx) / 2;
    final midY = start.dy + (end.dy - start.dy) / 2;

    final path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(midX, start.dy) // Horizontal to middle X
          ..lineTo(midX, end.dy) // Vertical to target Y
          ..lineTo(end.dx, end.dy); // Horizontal to target X

    canvas.drawPath(path, paint);
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset position,
    Offset direction,
    Paint paint,
  ) {
    const arrowSize = 10.0;
    final arrowPaint =
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.fill;

    // Calculate arrow points
    final arrowEnd = position;
    final perpendicular = Offset(-direction.dy, direction.dx);
    final arrowPoint1 =
        position - direction * arrowSize + perpendicular * arrowSize * 0.5;
    final arrowPoint2 =
        position - direction * arrowSize - perpendicular * arrowSize * 0.5;

    final path =
        Path()
          ..moveTo(arrowPoint1.dx, arrowPoint1.dy)
          ..lineTo(arrowEnd.dx, arrowEnd.dy)
          ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
          ..close();

    canvas.drawPath(path, arrowPaint);
  }

  Offset _canvasToScreen(Offset canvasPos, CanvasTransform transform) {
    return canvasPos * transform.scale + transform.offset;
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return nodes != oldDelegate.nodes ||
        selectedNodeId != oldDelegate.selectedNodeId ||
        selectedNodeIds != oldDelegate.selectedNodeIds ||
        transform != oldDelegate.transform ||
        routingMode != oldDelegate.routingMode;
  }
}
