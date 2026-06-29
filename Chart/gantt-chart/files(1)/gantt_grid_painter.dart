import 'package:flutter/material.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

/// Paints the background grid for the Gantt chart:
/// - Weekend column shading
/// - Today column highlight
/// - Vertical grid lines (daily / weekly)
/// - Horizontal row separators
class GanttGridPainter extends CustomPainter {
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;
  final double rowHeight;
  final int rowCount;
  final bool showWeekends;
  final bool showToday;
  final DateTime today;
  final Set<String> selectedRowIds;
  final Set<String> hoveredRowIds;

  GanttGridPainter({
    required this.startDate,
    required this.endDate,
    required this.dayWidth,
    required this.rowHeight,
    required this.rowCount,
    required this.showWeekends,
    required this.showToday,
    required this.today,
    this.selectedRowIds = const {},
    this.hoveredRowIds = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWeekendColumns(canvas, size);
    _drawTodayColumn(canvas, size);
    _drawGridLines(canvas, size);
  }

  void _drawWeekendColumns(Canvas canvas, Size size) {
    if (!showWeekends) return;
    final paint = Paint()..color = const Color(0xFF0F1219);
    var current = GanttDateUtils.dateOnly(startDate);
    final end = GanttDateUtils.dateOnly(endDate);
    while (!current.isAfter(end)) {
      if (GanttDateUtils.isWeekend(current)) {
        final x = GanttDateUtils.daysBetween(startDate, current) * dayWidth;
        canvas.drawRect(
          Rect.fromLTWH(x, 0, dayWidth, size.height),
          paint,
        );
      }
      current = current.add(const Duration(days: 1));
    }
  }

  void _drawTodayColumn(Canvas canvas, Size size) {
    if (!showToday) return;
    if (today.isBefore(startDate) || today.isAfter(endDate)) return;

    final x = GanttDateUtils.daysBetween(startDate, today) * dayWidth;

    // Soft highlight column
    final bgPaint = Paint()
      ..color = GanttTheme.accentDim.withOpacity(0.15);
    canvas.drawRect(
      Rect.fromLTWH(x, 0, dayWidth, size.height),
      bgPaint,
    );

    // Today vertical line (left edge of today column)
    final linePaint = Paint()
      ..color = GanttTheme.accent.withOpacity(0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final dayPaint = Paint()
      ..color = GanttTheme.gridLine
      ..strokeWidth = 0.5;
    final weekPaint = Paint()
      ..color = GanttTheme.gridLineMajor
      ..strokeWidth = 1.0;
    final rowPaint = Paint()
      ..color = GanttTheme.gridLine
      ..strokeWidth = 0.5;

    // Vertical lines
    var current = GanttDateUtils.dateOnly(startDate);
    final end = GanttDateUtils.dateOnly(endDate);
    while (!current.isAfter(end)) {
      final x = GanttDateUtils.daysBetween(startDate, current) * dayWidth;
      final isMonday = current.weekday == DateTime.monday;
      final paint = isMonday ? weekPaint : dayPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      current = current.add(const Duration(days: 1));
    }

    // Horizontal row lines
    for (int i = 0; i <= rowCount; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rowPaint);
    }
  }

  @override
  bool shouldRepaint(GanttGridPainter old) =>
      old.startDate != startDate ||
      old.endDate != endDate ||
      old.dayWidth != dayWidth ||
      old.rowHeight != rowHeight ||
      old.rowCount != rowCount ||
      old.showToday != showToday ||
      old.showWeekends != showWeekends;
}
