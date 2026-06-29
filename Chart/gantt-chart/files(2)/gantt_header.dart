import 'package:flutter/material.dart';
import '../../core/models/task_model.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class GanttHeader extends StatelessWidget {
  final DateTime startDate, endDate;
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
    final totalDays = GanttDateUtils.daysBetween(startDate, endDate) + 1;
    final totalW = totalDays * dayWidth;

    return Container(
      height: settings.headerHeight + settings.subHeaderHeight,
      color: GanttTheme.surface1,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: totalW,
          child: Column(children: [
            // ── Top row: months/quarters ──
            SizedBox(height: settings.headerHeight, child: CustomPaint(
              size: Size(totalW, settings.headerHeight),
              painter: _TopHeaderPainter(
                startDate: startDate, endDate: endDate,
                dayWidth: dayWidth, viewMode: settings.viewMode,
                today: DateTime.now(),
              ),
            )),
            // ── Bottom row: weeks/days ──
            SizedBox(height: settings.subHeaderHeight, child: CustomPaint(
              size: Size(totalW, settings.subHeaderHeight),
              painter: _SubHeaderPainter(
                startDate: startDate, endDate: endDate,
                dayWidth: dayWidth, viewMode: settings.viewMode,
                showWeekends: settings.showWeekends, today: DateTime.now(),
              ),
            )),
          ]),
        ),
      ),
    );
  }
}

// ─── Top header painter ───────────────────────────────────────────────────────

class _TopHeaderPainter extends CustomPainter {
  final DateTime startDate, endDate, today;
  final double dayWidth;
  final GanttViewMode viewMode;

  const _TopHeaderPainter({required this.startDate, required this.endDate, required this.dayWidth, required this.viewMode, required this.today});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = GanttTheme.surface1;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final borderPaint = Paint()..color = GanttTheme.surface4..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), borderPaint);

    final months = GanttDateUtils.monthsInRange(startDate, endDate);
    for (final month in months) {
      final startX = GanttDateUtils.dayOffset(startDate, month, dayWidth);
      final nextMonth = DateTime(month.year, month.month + 1);
      final endX = GanttDateUtils.dayOffset(startDate, nextMonth, dayWidth);
      final w = endX - startX;
      if (w < 2) continue;

      // Month highlight if today is in this month
      if (today.month == month.month && today.year == month.year) {
        canvas.drawRect(
          Rect.fromLTWH(startX, 0, w, size.height),
          Paint()..color = GanttTheme.accent.withOpacity(0.04),
        );
      }

      // Separator
      if (startX > 0) canvas.drawLine(Offset(startX, 4), Offset(startX, size.height - 4), Paint()..color = GanttTheme.surface4..strokeWidth = 0.5);

      // Label
      String label;
      if (viewMode == GanttViewMode.quarter) {
        label = GanttDateUtils.quarterLabel(month);
      } else {
        label = w > 100 ? GanttDateUtils.formatMonth(month) : GanttDateUtils.formatMonthShort(month);
      }

      _drawText(canvas, label, startX + 8, size.height / 2, const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: GanttTheme.textSecondary), w - 16);
    }
  }

  void _drawText(Canvas canvas, String text, double x, double cy, TextStyle style, double maxW) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr, maxLines: 1, ellipsis: '…')
      ..layout(maxWidth: maxW);
    tp.paint(canvas, Offset(x, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_TopHeaderPainter old) => old.startDate != startDate || old.dayWidth != dayWidth;
}

// ─── Sub header painter ───────────────────────────────────────────────────────

class _SubHeaderPainter extends CustomPainter {
  final DateTime startDate, endDate, today;
  final double dayWidth;
  final GanttViewMode viewMode;
  final bool showWeekends;

  const _SubHeaderPainter({required this.startDate, required this.endDate, required this.dayWidth, required this.viewMode, required this.showWeekends, required this.today});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = GanttTheme.surface1;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final borderPaint = Paint()..color = GanttTheme.surface4..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), borderPaint);

    final totalDays = GanttDateUtils.daysBetween(startDate, endDate) + 1;

    if (viewMode == GanttViewMode.day || (viewMode == GanttViewMode.week && dayWidth >= 20)) {
      // Show individual days
      for (int i = 0; i < totalDays; i++) {
        final day = startDate.add(Duration(days: i));
        final x = i * dayWidth;
        final isToday = GanttDateUtils.isSameDay(day, today);
        final isWeekend = GanttDateUtils.isWeekend(day);

        if (isToday) {
          canvas.drawRect(Rect.fromLTWH(x, 0, dayWidth, size.height),
            Paint()..color = GanttTheme.accent.withOpacity(0.15));
        } else if (isWeekend && showWeekends) {
          canvas.drawRect(Rect.fromLTWH(x, 0, dayWidth, size.height),
            Paint()..color = GanttTheme.weekendBg.withOpacity(0.5));
        }

        // Divider
        canvas.drawLine(Offset(x, size.height * 0.3), Offset(x, size.height * 0.9), Paint()..color = GanttTheme.gridLine..strokeWidth = 0.5);

        // Day label (skip if too narrow)
        if (dayWidth >= 16) {
          final label = viewMode == GanttViewMode.day ? GanttDateUtils.formatDayHeader(day) : '${day.day}';
          final style = TextStyle(
            fontFamily: 'Inter', fontSize: dayWidth >= 28 ? 10 : 8, fontWeight: FontWeight.w400,
            color: isToday ? GanttTheme.accent : (isWeekend ? GanttTheme.textDisabled : GanttTheme.textMuted),
          );
          _drawCenteredText(canvas, label, x + dayWidth / 2, size.height / 2, style);
        }
      }
    } else {
      // Show weeks
      var curr = startDate;
      while (!curr.isAfter(endDate)) {
        final x = GanttDateUtils.dayOffset(startDate, curr, dayWidth);
        final weekEnd = curr.add(const Duration(days: 6));
        final nextWeek = curr.add(const Duration(days: 7));
        final w = GanttDateUtils.dayOffset(startDate, nextWeek, dayWidth) - x;
        final isCurrentWeek = GanttDateUtils.isSameDay(curr, today.subtract(Duration(days: today.weekday - 1)));

        if (isCurrentWeek) {
          canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), Paint()..color = GanttTheme.accent.withOpacity(0.08));
        }

        canvas.drawLine(Offset(x, 4), Offset(x, size.height - 4), Paint()..color = GanttTheme.gridLine..strokeWidth = 0.5);
        _drawCenteredText(canvas, 'W${_weekOfYear(curr)} · ${GanttDateUtils.weekLabel(curr)}', x + w / 2, size.height / 2,
          TextStyle(fontFamily: 'Inter', fontSize: 9, color: isCurrentWeek ? GanttTheme.accent : GanttTheme.textMuted, fontWeight: isCurrentWeek ? FontWeight.w600 : FontWeight.w400));

        curr = nextWeek;
      }
    }
  }

  void _drawCenteredText(Canvas canvas, String text, double cx, double cy, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr, maxLines: 1)..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  int _weekOfYear(DateTime d) {
    final start = DateTime(d.year, 1, 1);
    return ((d.difference(start).inDays) / 7).ceil() + 1;
  }

  @override
  bool shouldRepaint(_SubHeaderPainter old) => old.dayWidth != dayWidth || old.viewMode != viewMode;
}
