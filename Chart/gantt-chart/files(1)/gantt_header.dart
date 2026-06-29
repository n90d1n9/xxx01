import 'package:flutter/material.dart';
import '../../core/models/task_model.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

/// Renders the time header: top row (months/quarters) + bottom row (days/weeks)
class GanttHeaderPainter extends CustomPainter {
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;
  final GanttViewSettings settings;
  final double topRowHeight;
  final double bottomRowHeight;
  final DateTime today;

  GanttHeaderPainter({
    required this.startDate,
    required this.endDate,
    required this.dayWidth,
    required this.settings,
    required this.topRowHeight,
    required this.bottomRowHeight,
    required this.today,
  });

  static const _bgTop = GanttTheme.surface1;
  static const _bgBottom = Color(0xFF131720);
  static const _borderColor = GanttTheme.surface4;
  static const _monthTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: GanttTheme.textSecondary,
    letterSpacing: 0.4,
  );
  static const _dayTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: GanttTheme.textMuted,
  );
  static const _todayDayTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: GanttTheme.accent,
  );
  static const _weekendDayTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF3D4A62),
  );

  @override
  void paint(Canvas canvas, Size size) {
    _drawTopRow(canvas, size);
    _drawBottomRow(canvas, size);
    _drawBorders(canvas, size);
  }

  void _drawTopRow(Canvas canvas, Size size) {
    final paint = Paint()..color = _bgTop;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, topRowHeight), paint);

    final months = GanttDateUtils.monthsInRange(startDate, endDate);
    for (final month in months) {
      final monthStart = month.isBefore(startDate) ? startDate : month;
      final monthEnd = month.month < 12
          ? DateTime(month.year, month.month + 1, 1)
              .subtract(const Duration(days: 1))
          : DateTime(month.year + 1, 1, 1).subtract(const Duration(days: 1));
      final clampedEnd = monthEnd.isAfter(endDate) ? endDate : monthEnd;

      final x1 = GanttDateUtils.dayOffset(startDate, monthStart, dayWidth);
      final x2 = GanttDateUtils.dayOffset(startDate, clampedEnd, dayWidth) +
          dayWidth;
      final monthWidth = x2 - x1;

      if (monthWidth < 20) continue;

      // Label
      _drawText(
        canvas,
        GanttDateUtils.formatMonth(month),
        x1 + 8,
        (topRowHeight - 14) / 2,
        _monthTextStyle,
        maxWidth: monthWidth - 16,
      );

      // Separator
      final divPaint = Paint()
        ..color = _borderColor
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x1, 0),
        Offset(x1, topRowHeight),
        divPaint,
      );
    }
  }

  void _drawBottomRow(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = _bgBottom;
    canvas.drawRect(
        Rect.fromLTWH(0, topRowHeight, size.width, bottomRowHeight), bgPaint);

    final days = GanttDateUtils.daysInRange(startDate, endDate);
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final x = i * dayWidth;
      final isWeekend = GanttDateUtils.isWeekend(day);
      final isToday_ = GanttDateUtils.isSameDay(day, today);

      // Weekend background
      if (isWeekend) {
        final wkPaint = Paint()..color = const Color(0xFF0F1218);
        canvas.drawRect(
          Rect.fromLTWH(x, topRowHeight, dayWidth, bottomRowHeight),
          wkPaint,
        );
      }

      // Today highlight
      if (isToday_) {
        final todayPaint = Paint()
          ..color = GanttTheme.accentDim.withOpacity(0.4);
        canvas.drawRect(
          Rect.fromLTWH(x, topRowHeight, dayWidth, bottomRowHeight),
          todayPaint,
        );
      }

      // Day number
      if (dayWidth >= 18) {
        final style = isToday_
            ? _todayDayTextStyle
            : isWeekend
                ? _weekendDayTextStyle
                : _dayTextStyle;

        _drawText(
          canvas,
          day.day.toString(),
          x,
          topRowHeight + (bottomRowHeight - 12) / 2,
          style,
          width: dayWidth,
          centerAlign: true,
        );
      }

      // Week separator
      if (day.weekday == DateTime.monday) {
        final sepPaint = Paint()
          ..color = _borderColor
          ..strokeWidth = 1;
        canvas.drawLine(
          Offset(x, topRowHeight),
          Offset(x, topRowHeight + bottomRowHeight),
          sepPaint,
        );
      }
    }
  }

  void _drawBorders(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _borderColor
      ..strokeWidth = 1;
    // Bottom border of entire header
    canvas.drawLine(
      Offset(0, topRowHeight + bottomRowHeight),
      Offset(size.width, topRowHeight + bottomRowHeight),
      paint,
    );
    // Separator between top and bottom rows
    canvas.drawLine(
      Offset(0, topRowHeight),
      Offset(size.width, topRowHeight),
      paint,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    TextStyle style, {
    double? maxWidth,
    double? width,
    bool centerAlign = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '',
    );
    tp.layout(maxWidth: maxWidth ?? (width ?? double.infinity));

    double dx = x;
    if (centerAlign && width != null) {
      dx = x + (width - tp.width) / 2;
    }
    tp.paint(canvas, Offset(dx, y));
  }

  @override
  bool shouldRepaint(GanttHeaderPainter old) =>
      old.startDate != startDate ||
      old.endDate != endDate ||
      old.dayWidth != dayWidth ||
      old.settings != settings;
}

/// Sticky header widget that wraps the painter
class GanttHeader extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;
  final GanttViewSettings settings;
  final ScrollController scrollController;

  const GanttHeader({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.dayWidth,
    required this.settings,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays =
        GanttDateUtils.daysBetween(startDate, endDate) + 1;
    final totalWidth = totalDays * dayWidth;
    final headerH = settings.headerHeight + settings.subHeaderHeight;

    return SizedBox(
      height: headerH,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: totalWidth,
          height: headerH,
          child: CustomPaint(
            painter: GanttHeaderPainter(
              startDate: startDate,
              endDate: endDate,
              dayWidth: dayWidth,
              settings: settings,
              topRowHeight: settings.headerHeight,
              bottomRowHeight: settings.subHeaderHeight,
              today: DateTime.now(),
            ),
          ),
        ),
      ),
    );
  }
}
