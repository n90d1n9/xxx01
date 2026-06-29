import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/historical_event.dart';
import '../models/timeline_view.dart';

class EventsGraphPainter extends CustomPainter {
  final List<HistoricalEvent> events;

  EventsGraphPainter(this.events);

  @override
  void paint(Canvas canvas, Size size) {
    if (events.isEmpty) return;

    final positions = <String, Offset>{};
    final radius = math.min(size.width, size.height) * 0.35;
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate positions in circular layout
    for (var i = 0; i < events.length; i++) {
      final angle = (2 * math.pi * i) / events.length;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      positions[events[i].id] = Offset(x, y);
    }

    // Draw connections
    final linePaint =
        Paint()
          ..color = const Color(0xFF6C63FF).withOpacity(0.2)
          ..strokeWidth = 1;

    for (var event in events) {
      final startPos = positions[event.id];
      if (startPos != null) {
        for (var relatedId in event.relatedEventIds) {
          final endPos = positions[relatedId];
          if (endPos != null) {
            canvas.drawLine(startPos, endPos, linePaint);
          }
        }
      }
    }

    // Draw nodes
    for (var i = 0; i < events.length; i++) {
      final event = events[i];
      final pos = positions[event.id]!;

      final nodePaint =
          Paint()
            ..color = _getCategoryColor(event.categories.first)
            ..style = PaintingStyle.fill;

      final nodeSize = 8 + (event.popularity / 10);
      canvas.drawCircle(pos, nodeSize, nodePaint);

      final borderPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      canvas.drawCircle(pos, nodeSize, borderPaint);
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
      case EventCategory.culture:
        return const Color(0xFFFF6FCF);
      case EventCategory.exploration:
        return const Color(0xFF95E1D3);
      case EventCategory.nature:
        return const Color(0xFF8BC34A);
      case EventCategory.sports:
        return const Color(0xFFFF9F1C);
      case EventCategory.religion:
        return const Color(0xFFC77DFF);
      case EventCategory.economics:
        return const Color(0xFF06FFA5);
      case EventCategory.invention:
        return const Color(0xFFFFD60A);
    }
  }

  @override
  bool shouldRepaint(EventsGraphPainter oldDelegate) => true;
}
