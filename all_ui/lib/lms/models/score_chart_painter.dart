import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'score_history.dart';

class ScoreChartPainter extends CustomPainter {
  final List<ScoreHistory> history;
  ScoreChartPainter(this.history);
  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;
    final paint =
        Paint()
          ..color = const Color(0xFF6366F1)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final path = Path();
    final maxScore = history
        .map((h) => h.score)
        .reduce((a, b) => a > b ? a : b);
    final minScore = history
        .map((h) => h.score)
        .reduce((a, b) => a < b ? a : b);
    final range = maxScore - minScore;
    for (var i = 0; i < history.length; i++) {
      final x = (size.width / (history.length - 1)) * i;
      final normalizedScore = (history[i].score - minScore) / range;
      final y = size.height - (size.height * normalizedScore);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    final pointPaint =
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.fill;
    for (var i = 0; i < history.length; i++) {
      final x = (size.width / (history.length - 1)) * i;
      final normalizedScore = (history[i].score - minScore) / range;
      final y = size.height - (size.height * normalizedScore);
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }
    final gradientPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.3),
              const Color(0xFF6366F1).withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
