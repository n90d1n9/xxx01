import 'package:flutter/material.dart';

import '../models/mermaid_diagram.dart';

class QuadrantPainter extends StatelessWidget {
  final MermaidDiagram diagram;
  const QuadrantPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(600, 600),
      painter: _QuadrantCustomPainter(diagram),
    );
  }
}

class _QuadrantCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;
  _QuadrantCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    const centerX = 300.0;
    const centerY = 300.0;

    // Draw axes
    final axisPaint =
        Paint()
          ..color = Colors.grey[400]!
          ..strokeWidth = 2.0;

    canvas.drawLine(
      const Offset(50, centerY),
      const Offset(550, centerY),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(centerX, 50),
      const Offset(centerX, 550),
      axisPaint,
    );

    // Draw quadrant backgrounds
    final q1Paint = Paint()..color = Colors.blue[50]!;
    final q2Paint = Paint()..color = Colors.green[50]!;
    final q3Paint = Paint()..color = Colors.orange[50]!;
    final q4Paint = Paint()..color = Colors.red[50]!;

    canvas.drawRect(Rect.fromLTWH(centerX, 50, 250, 250), q1Paint);
    canvas.drawRect(Rect.fromLTWH(50, 50, 250, 250), q2Paint);
    canvas.drawRect(Rect.fromLTWH(50, centerY, 250, 250), q3Paint);
    canvas.drawRect(Rect.fromLTWH(centerX, centerY, 250, 250), q4Paint);

    // Draw points
    for (final node in diagram.nodes) {
      canvas.drawCircle(node.position, 8, Paint()..color = Colors.blue[700]!);

      _drawText(
        canvas,
        node.label,
        node.position + const Offset(0, 20),
        100,
        fontSize: 10,
      );
    }

    // Draw labels
    _drawText(
      canvas,
      'High',
      const Offset(centerX, 30),
      100,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    _drawText(
      canvas,
      'Low',
      const Offset(centerX, 570),
      100,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    _drawText(
      canvas,
      'Low',
      const Offset(25, centerY),
      50,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    _drawText(
      canvas,
      'High',
      const Offset(575, centerY),
      50,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
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
