import 'package:flutter/material.dart';

class TimelineRulerPainter extends CustomPainter {
  final double duration;
  final double currentTime;

  TimelineRulerPainter(this.duration, this.currentTime);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw time markers
    final step = duration / 10;
    for (var i = 0; i <= 10; i++) {
      final x = (size.width * i) / 10;
      final time = step * i;

      canvas.drawLine(
        Offset(x, size.height - 10),
        Offset(x, size.height),
        paint,
      );

      textPainter.text = TextSpan(
        text: time.toStringAsFixed(1),
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, 5));
    }

    // Draw current time indicator
    final currentX = (currentTime / duration) * size.width;
    final indicatorPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2;

    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, size.height),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(TimelineRulerPainter oldDelegate) {
    return oldDelegate.currentTime != currentTime ||
        oldDelegate.duration != duration;
  }
}
