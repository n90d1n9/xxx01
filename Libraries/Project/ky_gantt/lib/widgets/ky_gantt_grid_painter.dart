import 'package:flutter/material.dart';

class KyGanttGridPainter extends CustomPainter {
  const KyGanttGridPainter({
    required this.rangeStart,
    required this.totalDays,
    required this.dayWidth,
    required this.rowHeight,
    required this.rowCount,
    required this.weekendColor,
    required this.verticalLineColor,
    required this.horizontalLineColor,
    this.showWeekendBands = true,
  });

  final DateTime rangeStart;
  final int totalDays;
  final double dayWidth;
  final double rowHeight;
  final int rowCount;
  final Color weekendColor;
  final Color verticalLineColor;
  final Color horizontalLineColor;
  final bool showWeekendBands;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalDays <= 0 || dayWidth <= 0 || rowHeight <= 0) return;

    if (showWeekendBands) {
      _paintWeekendBands(canvas, size);
    }
    _paintVerticalLines(canvas, size);
    _paintHorizontalLines(canvas, size);
  }

  void _paintWeekendBands(Canvas canvas, Size size) {
    final paint = Paint()..color = weekendColor;
    final normalizedStart = DateUtils.dateOnly(rangeStart);

    for (var day = 0; day < totalDays; day++) {
      final date = normalizedStart.add(Duration(days: day));
      if (!_isWeekend(date)) continue;

      canvas.drawRect(
        Rect.fromLTWH(day * dayWidth, 0, dayWidth, size.height),
        paint,
      );
    }
  }

  void _paintVerticalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = verticalLineColor
      ..strokeWidth = 0.8;

    for (var day = 1; day <= totalDays; day++) {
      final x = day * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _paintHorizontalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = horizontalLineColor
      ..strokeWidth = 1;

    for (var row = 0; row <= rowCount; row++) {
      final y = row * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  @override
  bool shouldRepaint(covariant KyGanttGridPainter oldDelegate) {
    return oldDelegate.rangeStart != rangeStart ||
        oldDelegate.totalDays != totalDays ||
        oldDelegate.dayWidth != dayWidth ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.rowCount != rowCount ||
        oldDelegate.weekendColor != weekendColor ||
        oldDelegate.verticalLineColor != verticalLineColor ||
        oldDelegate.horizontalLineColor != horizontalLineColor ||
        oldDelegate.showWeekendBands != showWeekendBands;
  }
}
