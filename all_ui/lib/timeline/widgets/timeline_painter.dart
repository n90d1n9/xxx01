import 'package:flutter/material.dart';

import '../models/historical_event.dart';

class TimelinePainter extends CustomPainter {
  final List<HistoricalEvent> events;
  TimelinePainter(this.events);
  @override
  void paint(Canvas canvas, Size size) {
    if (events.isEmpty) return;
    final linePaint =
        Paint()
          ..color = const Color(0xFF6C63FF).withOpacity(0.3)
          ..strokeWidth = 1;
    canvas.drawLine(
      Offset(20, size.height / 2),
      Offset(size.width - 20, size.height / 2),
      linePaint,
    );
    final sortedEvents = List<HistoricalEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));
    final earliest = sortedEvents.first.date;
    final latest = sortedEvents.last.date;
    final timeSpan = latest.difference(earliest).inDays.toDouble();
    for (var event in sortedEvents) {
      final position =
          timeSpan == 0
              ? 0.5
              : event.date.difference(earliest).inDays / timeSpan;
      final x = 20 + (size.width - 40) * position;
      final dotPaint =
          Paint()
            ..color =
                Color.lerp(
                  const Color(0xFF6C63FF),
                  const Color(0xFFFF6B9D),
                  position,
                )!
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, size.height / 2), 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => true;
}
