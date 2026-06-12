import 'package:flutter/material.dart';

import '../models/mermaid_diagram.dart';

class MindmapPainter extends StatelessWidget {
  final MermaidDiagram diagram;
  const MindmapPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(1000, 800),
      painter: _MindmapCustomPainter(diagram),
    );
  }
}

class _MindmapCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;
  _MindmapCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    for (final edge in diagram.edges) {
      final from = diagram.nodes.firstWhere((n) => n.id == edge.from);
      final to = diagram.nodes.firstWhere((n) => n.id == edge.to);

      final paint =
          Paint()
            ..color = Colors.purple[300]!
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(from.position.dx + 60, from.position.dy + 20),
        Offset(to.position.dx + 60, to.position.dy + 20),
        paint,
      );
    }

    // Draw nodes
    for (var i = 0; i < diagram.nodes.length; i++) {
      final node = diagram.nodes[i];
      final isRoot = i == 0;

      final rect = Rect.fromLTWH(node.position.dx, node.position.dy, 120, 40);

      final paint =
          Paint()
            ..color = isRoot ? Colors.purple[400]! : Colors.purple[100]!
            ..style = PaintingStyle.fill;

      final borderPaint =
          Paint()
            ..color = Colors.purple[700]!
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));
      canvas.drawRRect(rrect, paint);
      canvas.drawRRect(rrect, borderPaint);

      _drawText(
        canvas,
        node.label,
        rect.center,
        110,
        fontSize: isRoot ? 14 : 11,
        fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double maxWidth, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: fontWeight,
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
