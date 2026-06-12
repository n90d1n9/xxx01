import 'package:flutter/material.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class GanttGridPainter extends CustomPainter {
  final DateTime startDate, endDate, today;
  final double dayWidth, rowHeight;
  final int rowCount;
  final bool showWeekends, showToday;

  const GanttGridPainter({
    required this.startDate, required this.endDate,
    required this.dayWidth, required this.rowHeight,
    required this.rowCount, required this.showWeekends,
    required this.showToday, required this.today,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalDays = GanttDateUtils.daysBetween(startDate, endDate) + 1;

    // Row backgrounds
    for (int r = 0; r < rowCount; r++) {
      canvas.drawRect(
        Rect.fromLTWH(0, r * rowHeight, size.width, rowHeight),
        Paint()..color = r.isEven ? GanttTheme.rowEven : GanttTheme.rowOdd,
      );
    }

    // Weekend columns
    if (showWeekends) {
      for (int d = 0; d < totalDays; d++) {
        final day = startDate.add(Duration(days: d));
        if (GanttDateUtils.isWeekend(day)) {
          canvas.drawRect(
            Rect.fromLTWH(d * dayWidth, 0, dayWidth, size.height),
            Paint()..color = GanttTheme.weekendBg.withOpacity(0.6),
          );
        }
      }
    }

    // Today column
    if (showToday) {
      final todayDays = GanttDateUtils.daysBetween(startDate, today);
      if (todayDays >= 0 && todayDays < totalDays) {
        canvas.drawRect(
          Rect.fromLTWH(todayDays * dayWidth, 0, dayWidth, size.height),
          Paint()..color = GanttTheme.todayBg.withOpacity(0.4),
        );
      }
    }

    // Vertical grid lines (month separators = major, week start = minor)
    for (int d = 0; d < totalDays; d++) {
      final day = startDate.add(Duration(days: d));
      final isMonthStart = day.day == 1;
      final isWeekStart = day.weekday == DateTime.monday;
      if (!isMonthStart && !isWeekStart) continue;
      final x = d * dayWidth;
      canvas.drawLine(
        Offset(x, 0), Offset(x, size.height),
        Paint()..color = isMonthStart ? GanttTheme.gridLineMajor : GanttTheme.gridLine..strokeWidth = isMonthStart ? 0.8 : 0.4,
      );
    }

    // Horizontal row lines
    final rowLinePaint = Paint()..color = GanttTheme.gridLine..strokeWidth = 0.5;
    for (int r = 0; r <= rowCount; r++) {
      canvas.drawLine(Offset(0, r * rowHeight), Offset(size.width, r * rowHeight), rowLinePaint);
    }
  }

  @override
  bool shouldRepaint(GanttGridPainter old) =>
      old.dayWidth != dayWidth || old.rowCount != rowCount || old.showWeekends != showWeekends;
}
