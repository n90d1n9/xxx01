import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/connection.dart';
import '../../model/integration_component.dart';

class ConnectionsPainter extends CustomPainter {
  final List<IntegrationComponent> components;
  final List<Connection> connections;
  final String? connectingFromId;
  final Offset? connectionEndPoint;

  ConnectionsPainter(
    this.components,
    this.connections,
    this.connectingFromId,
    this.connectionEndPoint,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw existing connections
    for (final conn in connections) {
      try {
        final from = components.firstWhere((c) => c.id == conn.fromId);
        final to = components.firstWhere((c) => c.id == conn.toId);

        final start = Offset(from.position.dx + 168, from.position.dy + 72);
        final end = Offset(to.position.dx + 12, to.position.dy + 12);

        _drawCurvedArrow(canvas, paint, start, end, conn.label);
      } catch (e) {
        // Component not found, skip connection
      }
    }

    // Draw temporary connection while dragging
    if (connectingFromId != null && connectionEndPoint != null) {
      try {
        final from = components.firstWhere((c) => c.id == connectingFromId);
        final start = Offset(from.position.dx + 168, from.position.dy + 72);

        final tempPaint = Paint()
          ..color = Colors.blue.withValues(alpha: 0.6)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

        _drawCurvedArrow(canvas, tempPaint, start, connectionEndPoint!, null);
      } catch (e) {
        // Component not found
      }
    }
  }

  void _drawCurvedArrow(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    String? label,
  ) {
    final controlPoint1 = Offset(start.dx + (end.dx - start.dx) / 2, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) / 2, end.dy);

    final path = Path()
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

    // Draw arrow head
    final arrowSize = 12.0;
    final angle = math.atan2(
      end.dy - controlPoint2.dy,
      end.dx - controlPoint2.dx,
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle - math.pi / 6),
        end.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        end.dx - arrowSize * math.cos(angle + math.pi / 6),
        end.dy - arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    // Draw label if exists
    if (label != null && label.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final midPoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      textPainter.paint(
        canvas,
        midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
