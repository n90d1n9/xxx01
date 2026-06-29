import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_type.dart';
import '../models/mermaid_diagram.dart';

class GitGraphPainter extends StatelessWidget {
  final MermaidDiagram diagram;
  const GitGraphPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diagram.nodes.length * 80.0 + 200, 400),
      painter: _GitGraphCustomPainter(diagram),
    );
  }
}

class _GitGraphCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;
  _GitGraphCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    for (final edge in diagram.edges) {
      final from = diagram.nodes.firstWhere((n) => n.id == edge.from);
      final to = diagram.nodes.firstWhere((n) => n.id == edge.to);

      final paint =
          Paint()
            ..color =
                edge.type == EdgeType.dotted ? Colors.green : Colors.blue[700]!
            ..strokeWidth = edge.type == EdgeType.dotted ? 2.0 : 3.0
            ..style = PaintingStyle.stroke;

      if (edge.type == EdgeType.dotted) {
        _drawDashedLine(
          canvas,
          from.position + const Offset(0, 25),
          to.position + const Offset(0, 25),
          paint,
        );
      } else {
        canvas.drawLine(
          from.position + const Offset(0, 25),
          to.position + const Offset(0, 25),
          paint,
        );
      }
    }

    // Draw commits
    for (final node in diagram.nodes) {
      canvas.drawCircle(
        node.position + const Offset(0, 25),
        20,
        Paint()..color = Colors.blue[700]!,
      );
      canvas.drawCircle(
        node.position + const Offset(0, 25),
        20,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      _drawText(
        canvas,
        node.label,
        node.position + const Offset(0, 70),
        100,
        fontSize: 10,
      );
    }
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
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
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
