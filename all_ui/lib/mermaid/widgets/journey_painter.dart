import 'package:flutter/material.dart';

import '../models/mermaid_diagram.dart';

class JourneyPainter extends StatelessWidget {
  final MermaidDiagram diagram;
  const JourneyPainter({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(1000, 400),
      painter: _JourneyCustomPainter(diagram),
    );
  }
}

class _JourneyCustomPainter extends CustomPainter {
  final MermaidDiagram diagram;
  _JourneyCustomPainter(this.diagram);

  @override
  void paint(Canvas canvas, Size size) {
    if (diagram.journeyTasks.isEmpty) return;

    const startX = 100.0;
    const spacing = 150.0;
    const centerY = 200.0;

    // Draw journey line
    for (var i = 0; i < diagram.journeyTasks.length - 1; i++) {
      final x1 = startX + i * spacing;
      final x2 = startX + (i + 1) * spacing;
      final y1 = centerY - (diagram.journeyTasks[i].score - 5) * 10;
      final y2 = centerY - (diagram.journeyTasks[i + 1].score - 5) * 10;

      final paint =
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 3.0;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw points and labels
    for (var i = 0; i < diagram.journeyTasks.length; i++) {
      final task = diagram.journeyTasks[i];
      final x = startX + i * spacing;
      final y = centerY - (task.score - 5) * 10;

      // Draw point
      Color pointColor = Colors.green;
      if (task.score < 4) {
        pointColor = Colors.red;
      } else if (task.score < 7) {
        pointColor = Colors.orange;
      }

      canvas.drawCircle(Offset(x, y), 15, Paint()..color = pointColor);

      // Draw score
      _drawText(
        canvas,
        task.score.toString(),
        Offset(x, y),
        50,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        textColor: Colors.white,
      );

      // Draw task name
      _drawText(canvas, task.task, Offset(x, y + 40), 140, fontSize: 12);

      // Draw actors
      if (task.actors.isNotEmpty) {
        _drawText(
          canvas,
          task.actors.join(', '),
          Offset(x, y + 60),
          140,
          fontSize: 10,
          textColor: Colors.grey[600]!,
        );
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double maxWidth, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.normal,
    Color textColor = Colors.black87,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
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
