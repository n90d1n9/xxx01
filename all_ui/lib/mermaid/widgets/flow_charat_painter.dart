import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_edge.dart';
import '../models/diagram_node.dart';
import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';
import '../models/node_shape.dart';

class FlowchartPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const FlowchartPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    if (diagram.nodes.isEmpty) {
      return const Center(child: Text('No nodes to display'));
    }

    return CustomPaint(
      size: const Size(1200, 800),
      painter: _FlowchartCustomPainter(diagram),
    );
  }
}

class _FlowchartCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _FlowchartCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    for (final edge in diagram.edges) {
      final fromNode = diagram.nodes.firstWhere((n) => n.id == edge.from);
      final toNode = diagram.nodes.firstWhere((n) => n.id == edge.to);

      _drawEdge(canvas, fromNode, toNode, edge);
    }

    // Draw nodes
    for (final node in diagram.nodes) {
      _drawNode(canvas, node);
    }
  }

  void _drawNode(Canvas canvas, DiagramNode node) {
    final paint =
        Paint()
          ..color = node.fillColor ?? Colors.lightBlue[100]!
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = node.strokeColor ?? Colors.blue
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(node.position.dx, node.position.dy, 150, 80);

    switch (node.shape) {
      case NodeShape.rectangle:
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, borderPaint);
        break;

      case NodeShape.rounded:
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
        canvas.drawRRect(rrect, paint);
        canvas.drawRRect(rrect, borderPaint);
        break;

      case NodeShape.stadium:
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(40));
        canvas.drawRRect(rrect, paint);
        canvas.drawRRect(rrect, borderPaint);
        break;

      case NodeShape.subroutine:
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, borderPaint);
        canvas.drawLine(
          Offset(rect.left + 10, rect.top),
          Offset(rect.left + 10, rect.bottom),
          borderPaint,
        );
        canvas.drawLine(
          Offset(rect.right - 10, rect.top),
          Offset(rect.right - 10, rect.bottom),
          borderPaint,
        );
        break;

      case NodeShape.cylindrical:
        final path =
            Path()
              ..addOval(Rect.fromLTWH(rect.left, rect.top, rect.width, 20))
              ..moveTo(rect.left, rect.top + 10)
              ..lineTo(rect.left, rect.bottom - 10)
              ..arcToPoint(
                Offset(rect.right, rect.bottom - 10),
                radius: Radius.circular(rect.width / 2),
              )
              ..lineTo(rect.right, rect.top + 10);
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        canvas.drawOval(
          Rect.fromLTWH(rect.left, rect.top, rect.width, 20),
          borderPaint,
        );
        break;

      case NodeShape.circle:
        canvas.drawCircle(rect.center, 45, paint);
        canvas.drawCircle(rect.center, 45, borderPaint);
        break;

      case NodeShape.rhombus:
        final path =
            Path()
              ..moveTo(rect.center.dx, rect.top)
              ..lineTo(rect.right, rect.center.dy)
              ..lineTo(rect.center.dx, rect.bottom)
              ..lineTo(rect.left, rect.center.dy)
              ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;

      case NodeShape.hexagon:
        final w = rect.width * 0.2;
        final path =
            Path()
              ..moveTo(rect.left + w, rect.top)
              ..lineTo(rect.right - w, rect.top)
              ..lineTo(rect.right, rect.center.dy)
              ..lineTo(rect.right - w, rect.bottom)
              ..lineTo(rect.left + w, rect.bottom)
              ..lineTo(rect.left, rect.center.dy)
              ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;

      case NodeShape.parallelogram:
        final offset = 20.0;
        final path =
            Path()
              ..moveTo(rect.left + offset, rect.top)
              ..lineTo(rect.right, rect.top)
              ..lineTo(rect.right - offset, rect.bottom)
              ..lineTo(rect.left, rect.bottom)
              ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;

      case NodeShape.trapezoid:
        final offset = 20.0;
        final path =
            Path()
              ..moveTo(rect.left + offset, rect.top)
              ..lineTo(rect.right - offset, rect.top)
              ..lineTo(rect.right, rect.bottom)
              ..lineTo(rect.left, rect.bottom)
              ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;

      case NodeShape.doubleCircle:
        canvas.drawCircle(rect.center, 45, paint);
        canvas.drawCircle(rect.center, 45, borderPaint);
        canvas.drawCircle(rect.center, 38, borderPaint);
        break;

      case NodeShape.asymmetric:
        final path =
            Path()
              ..moveTo(rect.left + 20, rect.top)
              ..lineTo(rect.right, rect.top)
              ..lineTo(rect.right - 20, rect.bottom)
              ..lineTo(rect.left, rect.bottom)
              ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;

      case NodeShape.note:
        // Note shape with folded corner
        final path =
            Path()
              ..moveTo(rect.left, rect.top)
              ..lineTo(rect.right - 15, rect.top)
              ..lineTo(rect.right, rect.top + 15)
              ..lineTo(rect.right, rect.bottom)
              ..lineTo(rect.left, rect.bottom)
              ..close();

        // Folded corner triangle
        final cornerPath =
            Path()
              ..moveTo(rect.right - 15, rect.top)
              ..lineTo(rect.right, rect.top)
              ..lineTo(rect.right, rect.top + 15)
              ..close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        canvas.drawPath(cornerPath, Paint()..color = Colors.grey[300]!);
        canvas.drawPath(cornerPath, borderPaint);
        break;

      case NodeShape.actor:
        // Actor/stick figure shape
        final centerX = rect.center.dx;
        final headRadius = 15.0;
        final bodyTop = rect.top + headRadius * 2;
        final bodyBottom = rect.bottom - 20;

        // Head
        canvas.drawCircle(
          Offset(centerX, rect.top + headRadius),
          headRadius,
          paint,
        );
        canvas.drawCircle(
          Offset(centerX, rect.top + headRadius),
          headRadius,
          borderPaint,
        );

        // Body
        canvas.drawLine(
          Offset(centerX, bodyTop),
          Offset(centerX, bodyBottom),
          borderPaint,
        );

        // Arms
        canvas.drawLine(
          Offset(centerX - 20, bodyTop + 20),
          Offset(centerX + 20, bodyTop + 20),
          borderPaint,
        );

        // Legs
        canvas.drawLine(
          Offset(centerX, bodyBottom),
          Offset(centerX - 15, rect.bottom),
          borderPaint,
        );
        canvas.drawLine(
          Offset(centerX, bodyBottom),
          Offset(centerX + 15, rect.bottom),
          borderPaint,
        );
        break;

      case NodeShape.ellipse:
        // Ellipse shape (oval)
        final ellipseRect = Rect.fromCenter(
          center: rect.center,
          width: rect.width,
          height: rect.height * 0.7,
        );
        canvas.drawOval(ellipseRect, paint);
        canvas.drawOval(ellipseRect, borderPaint);
        break;

      case NodeShape.database:
        // Database shape (cylinder-like)
        final topOval = Rect.fromLTWH(rect.left, rect.top, rect.width, 20);
        final bodyRect = Rect.fromLTWH(
          rect.left,
          rect.top + 10,
          rect.width,
          rect.height - 10,
        );

        // Draw body
        final bodyPath =
            Path()
              ..moveTo(rect.left, rect.top + 10)
              ..lineTo(rect.left, rect.bottom - 10)
              ..arcToPoint(
                Offset(rect.right, rect.bottom - 10),
                radius: Radius.circular(rect.width / 2),
              )
              ..lineTo(rect.right, rect.top + 10);

        canvas.drawPath(bodyPath, paint);
        canvas.drawPath(bodyPath, borderPaint);

        // Draw top and bottom ovals
        canvas.drawOval(topOval, paint);
        canvas.drawOval(topOval, borderPaint);

        final bottomOval = Rect.fromLTWH(
          rect.left,
          rect.bottom - 10,
          rect.width,
          20,
        );
        canvas.drawOval(bottomOval, borderPaint);
        break;

      case NodeShape.cloud:
        // Cloud shape with multiple arcs
        final cloudPath =
            Path()
              ..moveTo(rect.left + 30, rect.top + 20)
              ..cubicTo(
                rect.left + 10,
                rect.top,
                rect.left,
                rect.top + 20,
                rect.left + 10,
                rect.top + 40,
              )
              ..cubicTo(
                rect.left,
                rect.top + 60,
                rect.left + 20,
                rect.bottom,
                rect.left + 50,
                rect.bottom - 10,
              )
              ..cubicTo(
                rect.left + 80,
                rect.bottom,
                rect.right,
                rect.bottom - 30,
                rect.right - 20,
                rect.top + 40,
              )
              ..cubicTo(
                rect.right,
                rect.top + 20,
                rect.right - 30,
                rect.top,
                rect.right - 50,
                rect.top + 10,
              )
              ..cubicTo(
                rect.right - 70,
                rect.top,
                rect.left + 30,
                rect.top - 10,
                rect.left + 30,
                rect.top + 20,
              )
              ..close();

        canvas.drawPath(cloudPath, paint);
        canvas.drawPath(cloudPath, borderPaint);
        break;

      case NodeShape.roundedRectangle:
        // Rounded rectangle with larger radius
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
        canvas.drawRRect(rrect, paint);
        canvas.drawRRect(rrect, borderPaint);
        break;

      case NodeShape.diamond:
        // Diamond shape (similar to rhombus but different proportions)
        final path =
            Path()
              ..moveTo(rect.center.dx, rect.top)
              ..lineTo(rect.right - 10, rect.center.dy)
              ..lineTo(rect.center.dx, rect.bottom)
              ..lineTo(rect.left + 10, rect.center.dy)
              ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
        break;
    }

    _drawText(canvas, node.label, rect.center, 140);
  }

  void _drawEdge(
    Canvas canvas,
    DiagramNode from,
    DiagramNode to,
    DiagramEdge edge,
  ) {
    final paint =
        Paint()
          ..color = Colors.black87
          ..strokeWidth = edge.type == EdgeType.thick ? 3.5 : 2.0
          ..style = PaintingStyle.stroke;

    final startOffset = _getNodeEdgePoint(from, to.position);
    final endOffset = _getNodeEdgePoint(to, from.position);

    final path = Path()..moveTo(startOffset.dx, startOffset.dy);

    if (edge.type == EdgeType.dotted) {
      _drawDashedLine(canvas, startOffset, endOffset, paint);
    } else {
      canvas.drawLine(startOffset, endOffset, paint);
    }

    // Draw arrow
    if (!edge.bidirectional) {
      _drawArrow(canvas, startOffset, endOffset, paint.color);
    } else {
      _drawArrow(canvas, startOffset, endOffset, paint.color);
      _drawArrow(canvas, endOffset, startOffset, paint.color);
    }

    // Draw label
    if (edge.label != null && edge.label!.isNotEmpty) {
      final midPoint = Offset(
        (startOffset.dx + endOffset.dx) / 2,
        (startOffset.dy + endOffset.dy) / 2 - 10,
      );
      _drawText(
        canvas,
        edge.label!,
        midPoint,
        120,
        fontSize: 11,
        bgColor: Colors.white,
      );
    }
  }

  Offset _getNodeEdgePoint(DiagramNode node, Offset targetPos) {
    final center = Offset(node.position.dx + 75, node.position.dy + 40);
    final angle = math.atan2(
      targetPos.dy - center.dy,
      targetPos.dx - center.dx,
    );

    double radius = 75;
    if (node.shape == NodeShape.circle ||
        node.shape == NodeShape.doubleCircle) {
      radius = 45;
    } else if (node.shape == NodeShape.rhombus) {
      radius = 60;
    }

    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.fill;

    const arrowSize = 12.0;
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);

    final path =
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(
            to.dx - arrowSize * math.cos(angle - math.pi / 6),
            to.dy - arrowSize * math.sin(angle - math.pi / 6),
          )
          ..lineTo(
            to.dx - arrowSize * math.cos(angle + math.pi / 6),
            to.dy - arrowSize * math.sin(angle + math.pi / 6),
          )
          ..close();

    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final totalDistance = (end - start).distance;
    final unitVector = (end - start) / totalDistance;

    var currentDistance = 0.0;
    while (currentDistance < totalDistance) {
      final dashEnd = math.min(currentDistance + dashWidth, totalDistance);
      canvas.drawLine(
        start + unitVector * currentDistance,
        start + unitVector * dashEnd,
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double maxWidth, {
    double fontSize = 13,
    Color? bgColor,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          backgroundColor: bgColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
