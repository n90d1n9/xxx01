import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import '../../model/xyaxis.dart';

class AxesPainter extends CustomPainter {
  final XYAxis? xAxis;
  final XYAxis? yAxis;

  AxesPainter({
    this.xAxis,
    this.yAxis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (xAxis != null) {
      _paintXAxis(canvas, size);
    }

    if (yAxis != null) {
      _paintYAxis(canvas, size);
    }
  }

  void _paintXAxis(Canvas canvas, Size size) {
    // Assuming xAxis implementation details are defined elsewhere
    // Drawing here is just a placeholder
    final paint = Paint()
      ..color = stringToColor(xAxis!.axisLine!.lineStyle!.color)
      ..strokeWidth = xAxis?.axisLine?.lineStyle!.width ?? 1.0;

    // Draw axis line at the bottom
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    // Draw labels if available
    if (xAxis?.data != null) {
      final labels = xAxis!.data!;
      for (int i = 0; i < labels.length; i++) {
        final x = (i / (labels.length - 1)) * size.width;
        final textSpan = TextSpan(
          text: labels[i].toString(),
          style: TextStyle(
            color: stringToColor(xAxis!.axisLabel!.textStyle!.color),
            fontSize: 10,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height + 2),
        );
      }
    }
  }

  void _paintYAxis(Canvas canvas, Size size) {
    // Assuming yAxis implementation details are defined elsewhere
    // Drawing here is just a placeholder
    final paint = Paint()
      ..color = stringToColor(yAxis!.axisLine!.lineStyle!.color)
      ..strokeWidth = yAxis?.axisLine?.lineStyle!.width ?? 1.0;

    // Draw axis line at the left
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height),
      paint,
    );

    // Draw labels if available
    if (yAxis?.data != null) {
      final labels = yAxis!.data!;
      for (int i = 0; i < labels.length; i++) {
        final y = size.height - (i / (labels.length - 1)) * size.height;
        final textSpan = TextSpan(
          text: labels[i].toString(),
          style: TextStyle(
            color: stringToColor(yAxis!.axisLabel!.textStyle!.color),
            fontSize: 10,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(-textPainter.width - 2, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
