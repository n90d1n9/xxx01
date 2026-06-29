import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/mermaid_diagram.dart';

class PieChartPainter extends StatelessWidget {
  final MermaidDiagram diagram;

  const PieChartPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(500, 500),
      painter: _PieChartCustomPainter(diagram),
    );
  }
}

class _PieChartCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;

  _PieChartCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    if (diagram.pieSlices.isEmpty) return;

    final total = diagram.pieSlices.fold(
      0.0,
      (sum, slice) => sum + slice.value,
    );
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 150.0;

    var startAngle = -math.pi / 2;

    for (final slice in diagram.pieSlices) {
      final sweepAngle = (slice.value / total) * 2 * math.pi;

      final paint =
          Paint()
            ..color = slice.color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final borderPaint =
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw label
      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius + 40;
      final labelX = center.dx + labelRadius * math.cos(labelAngle);
      final labelY = center.dy + labelRadius * math.sin(labelAngle);

      final percentage = ((slice.value / total) * 100).toStringAsFixed(1);

      _drawText(
        canvas,
        '${slice.label}\n$percentage%',
        Offset(labelX, labelY),
        100,
        fontSize: 11,
      );

      // Draw connector line
      final innerX = center.dx + (radius + 5) * math.cos(labelAngle);
      final innerY = center.dy + (radius + 5) * math.sin(labelAngle);
      final outerX = center.dx + (radius + 30) * math.cos(labelAngle);
      final outerY = center.dy + (radius + 30) * math.sin(labelAngle);

      final linePaint =
          Paint()
            ..color = Colors.grey[600]!
            ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        linePaint,
      );

      startAngle += sweepAngle;
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
