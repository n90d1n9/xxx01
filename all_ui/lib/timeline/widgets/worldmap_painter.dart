import 'package:flutter/material.dart';

import '../models/historical_event.dart';
import '../models/timeline_view.dart';

class WorldMapPainter extends CustomPainter {
  final List<HistoricalEvent> events;

  WorldMapPainter(this.events);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF6C63FF).withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Draw simple grid for world map
    for (var i = 0; i < 10; i++) {
      final y = size.height * (i / 10);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 0; i < 20; i++) {
      final x = size.width * (i / 20);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Plot events
    for (var event in events) {
      final x = ((event.lng + 180) / 360) * size.width;
      final y = ((90 - event.lat) / 180) * size.height;

      final dotPaint =
          Paint()
            ..color = _getCategoryColor(event.categories.first)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 6, dotPaint);

      final glowPaint =
          Paint()
            ..color = _getCategoryColor(event.categories.first).withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(x, y), 12, glowPaint);
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.war:
        return const Color(0xFFFF6B6B);
      case EventCategory.science:
        return const Color(0xFF4ECDC4);
      case EventCategory.art:
        return const Color(0xFFFFBE0B);
      case EventCategory.politics:
        return const Color(0xFFB388FF);
      case EventCategory.technology:
        return const Color(0xFF00D9FF);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  bool shouldRepaint(WorldMapPainter oldDelegate) => true;
}
