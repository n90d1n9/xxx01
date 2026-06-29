import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';

class SequenceDiagramPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const SequenceDiagramPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        diagram.nodes.length * 200.0 + 100,
        diagram.edges.length * 80.0 + 200,
      ),
      painter: _SequenceDiagramCustomPainter(diagram),
    );
  }
}

class _SequenceDiagramCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _SequenceDiagramCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    const participantHeight = 60.0;
    const messageSpacing = 80.0;
    var currentY = participantHeight + 50;

    // Draw participants
    for (final node in diagram.nodes) {
      final rect = Rect.fromLTWH(node.position.dx, 20, 160, participantHeight);
      final paint =
          Paint()
            ..color = Colors.blue[100]!
            ..style = PaintingStyle.fill;
      final borderPaint =
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke;

      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, borderPaint);

      // Lifeline
      final linePaint =
          Paint()
            ..color = Colors.grey[400]!
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      final dashPaint =
          Paint()
            ..color = Colors.grey[400]!
            ..strokeWidth = 2.0;

      _drawDashedLine(
        canvas,
        Offset(rect.center.dx, rect.bottom),
        Offset(rect.center.dx, size.height),
        dashPaint,
      );

      _drawText(canvas, node.label, rect.center, 150);
    }

    // Draw messages
    for (final edge in diagram.edges) {
      final fromNode = diagram.nodes.firstWhere((n) => n.id == edge.from);
      final toNode = diagram.nodes.firstWhere((n) => n.id == edge.to);

      final fromX = fromNode.position.dx + 80;
      final toX = toNode.position.dx + 80;

      final paint =
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      if (edge.type == EdgeType.dotted) {
        _drawDashedLine(
          canvas,
          Offset(fromX, currentY),
          Offset(toX, currentY),
          paint,
        );
      } else {
        canvas.drawLine(Offset(fromX, currentY), Offset(toX, currentY), paint);
      }

      // Draw arrow
      if (edge.type == EdgeType.cross) {
        _drawCross(canvas, Offset(toX, currentY));
      } else {
        _drawArrow(canvas, Offset(fromX, currentY), Offset(toX, currentY));
      }

      // Draw label
      if (edge.label != null) {
        _drawText(
          canvas,
          edge.label!,
          Offset((fromX + toX) / 2, currentY - 15),
          150,
          fontSize: 11,
          bgColor: Colors.white,
        );
      }

      currentY += messageSpacing;
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final paint =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;

    const arrowSize = 10.0;
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

  void _drawCross(Canvas canvas, Offset pos) {
    final paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(pos.dx - 6, pos.dy - 6),
      Offset(pos.dx + 6, pos.dy + 6),
      paint,
    );
    canvas.drawLine(
      Offset(pos.dx + 6, pos.dy - 6),
      Offset(pos.dx - 6, pos.dy + 6),
      paint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    var current = 0.0;
    while (current < distance) {
      final next = math.min(current + dashWidth, distance);
      canvas.drawLine(
        start + direction * current,
        start + direction * next,
        paint,
      );
      current += dashWidth + dashSpace;
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
