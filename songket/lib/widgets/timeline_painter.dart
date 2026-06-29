import 'package:flutter/material.dart';

import '../models/mermaid_diagram.dart';

// Simplified painters for remaining diagram types
class TimelinePainter extends StatelessWidget {
  final MermaidDiagram diagram;
  const TimelinePainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(1000, diagram.timelineEvents.length * 120.0 + 100),
      painter: _TimelineCustomPainter(diagram),
    );
  }
}

class _TimelineCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;
  _TimelineCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    const lineX = 100.0;
    var currentY = 80.0;

    final linePaint =
        Paint()
          ..color = Colors.blue[700]!
          ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(lineX, 50),
      Offset(lineX, size.height - 50),
      linePaint,
    );

    for (var i = 0; i < diagram.timelineEvents.length; i++) {
      final event = diagram.timelineEvents[i];

      // Draw circle
      canvas.drawCircle(
        Offset(lineX, currentY),
        12,
        Paint()..color = Colors.blue[700]!,
      );
      canvas.drawCircle(
        Offset(lineX, currentY),
        12,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // Draw period
      _drawText(
        canvas,
        event.period,
        Offset(lineX + 40, currentY - 10),
        200,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        align: TextAlign.left,
      );

      // Draw title
      if (event.title.isNotEmpty) {
        _drawText(
          canvas,
          event.title,
          Offset(lineX + 40, currentY + 15),
          400,
          fontSize: 13,
          align: TextAlign.left,
        );
      }

      // Draw events
      var eventY = currentY + 40;
      for (final evt in event.events) {
        _drawText(
          canvas,
          '• $evt',
          Offset(lineX + 60, eventY),
          400,
          fontSize: 11,
          align: TextAlign.left,
        );
        eventY += 20;
      }

      currentY += 120;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double maxWidth, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign align = TextAlign.center,
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
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final offset =
        align == TextAlign.center
            ? Offset(
              position.dx - textPainter.width / 2,
              position.dy - textPainter.height / 2,
            )
            : Offset(position.dx, position.dy - textPainter.height / 2);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
