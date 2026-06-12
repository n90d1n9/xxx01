import 'package:flutter/material.dart';

class SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = size.width / 8;
    final values = [0.3, 0.6, 0.4, 0.8, 0.5, 0.7];
    final colors = [
      Colors.blue[300]!,
      Colors.blue[400]!,
      Colors.blue[500]!,
      Colors.blue[600]!,
      Colors.blue[700]!,
      Colors.blue[800]!,
    ];

    for (int i = 0; i < values.length; i++) {
      paint.color = colors[i];
      final height = size.height * values[i] * 0.9;
      final rect = Rect.fromLTWH(
        i * barWidth + barWidth * 0.3,
        size.height - height - 10,
        barWidth * 0.5,
        height,
      );

      // Draw rounded rectangle
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(SimpleChartPainter oldDelegate) => false;
}
