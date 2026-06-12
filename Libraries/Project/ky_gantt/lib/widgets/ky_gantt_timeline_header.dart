import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/gantt_view_mode.dart';
import 'ky_gantt_today_marker.dart';

class KyGanttTimelineHeader extends StatelessWidget {
  const KyGanttTimelineHeader({
    required this.rangeStart,
    required this.totalDays,
    required this.dayWidth,
    required this.height,
    required this.viewMode,
    this.today,
    this.showTodayMarker = true,
    this.showWeekendBands = true,
    this.weekendBandColor,
    this.weekendBandOpacity = 0.5,
    this.todayIndicatorColor,
    this.todayIndicatorOpacity = 0.14,
    Key? key,
  }) : super(key: key ?? defaultHeaderKey);

  static const defaultHeaderKey = ValueKey('ky-gantt-timeline-header');
  static const defaultTodayIndicatorKey = ValueKey(
    'ky-gantt-timeline-header-today-indicator',
  );

  final DateTime rangeStart;
  final int totalDays;
  final double dayWidth;
  final double height;
  final KyGanttViewMode viewMode;
  final DateTime? today;
  final bool showTodayMarker;
  final bool showWeekendBands;
  final Color? weekendBandColor;
  final double weekendBandOpacity;
  final Color? todayIndicatorColor;
  final double todayIndicatorOpacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthFormat = DateFormat('MMM yyyy');
    final dayFormat = DateFormat('d');
    final labelInterval = viewMode.labelIntervalDays;
    final headerWeekendColor = weekendBandColor ?? colorScheme.errorContainer;
    final headerWeekendOpacity =
        (weekendBandOpacity * 0.36).clamp(0, 0.28).toDouble();
    final effectiveToday = today ?? DateTime.now();
    final todayOffset = showTodayMarker
        ? KyGanttTodayMarker.todayOffsetDays(
            today: effectiveToday,
            rangeStart: rangeStart,
            totalDays: totalDays,
          )
        : null;
    final todayColor = todayIndicatorColor ?? colorScheme.primary;
    final normalizedToday = DateUtils.dateOnly(effectiveToday);

    return Container(
      height: height,
      width: totalDays * dayWidth,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Stack(
        children: [
          for (var day = 0; day < totalDays; day++)
            _KyGanttTimelineHeaderDayCell(
              left: day * dayWidth,
              width: dayWidth,
              weekend: _isWeekend(rangeStart.add(Duration(days: day))),
              showWeekendBands: showWeekendBands,
              weekendColor: headerWeekendColor,
              weekendOpacity: headerWeekendOpacity,
            ),
          if (todayOffset != null)
            _KyGanttTimelineHeaderTodayIndicator(
              left: todayOffset * dayWidth,
              width: dayWidth,
              color: todayColor,
              opacity: todayIndicatorOpacity,
            ),
          for (var day = 0; day < totalDays; day += labelInterval)
            Positioned(
              left: day * dayWidth,
              top: 8,
              width: dayWidth * labelInterval,
              child: Text(
                monthFormat.format(rangeStart.add(Duration(days: day))),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          if (dayWidth >= 28)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                children: [
                  for (var day = 0; day < totalDays; day++)
                    SizedBox(
                      width: dayWidth,
                      child: Text(
                        dayFormat.format(rangeStart.add(Duration(days: day))),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _dayLabelColor(
                                colorScheme: colorScheme,
                                date: rangeStart.add(Duration(days: day)),
                                today: normalizedToday,
                              ),
                              fontWeight: _isToday(
                                rangeStart.add(Duration(days: day)),
                                normalizedToday,
                              )
                                  ? FontWeight.w900
                                  : FontWeight.w800,
                            ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isToday(DateTime date, DateTime today) {
    return showTodayMarker && DateUtils.dateOnly(date) == today;
  }

  Color _dayLabelColor({
    required ColorScheme colorScheme,
    required DateTime date,
    required DateTime today,
  }) {
    if (_isToday(date, today)) {
      return todayIndicatorColor ?? colorScheme.primary;
    }

    return showWeekendBands && _isWeekend(date)
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
  }
}

class _KyGanttTimelineHeaderTodayIndicator extends StatelessWidget {
  const _KyGanttTimelineHeaderTodayIndicator({
    required this.left,
    required this.width,
    required this.color,
    required this.opacity,
  });

  final double left;
  final double width;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final normalizedOpacity = opacity.clamp(0, 1).toDouble();
    final borderOpacity = (normalizedOpacity * 1.8).clamp(0, 0.38).toDouble();

    return Positioned(
      key: KyGanttTimelineHeader.defaultTodayIndicatorKey,
      left: left,
      top: 0,
      bottom: 0,
      width: width,
      child: Semantics(
        label: 'Today header marker',
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: normalizedOpacity),
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: color.withValues(alpha: borderOpacity),
                    width: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTimelineHeaderDayCell extends StatelessWidget {
  const _KyGanttTimelineHeaderDayCell({
    required this.left,
    required this.width,
    required this.weekend,
    required this.showWeekendBands,
    required this.weekendColor,
    required this.weekendOpacity,
  });

  final double left;
  final double width;
  final bool weekend;
  final bool showWeekendBands;
  final Color weekendColor;
  final double weekendOpacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: showWeekendBands && weekend
              ? weekendColor.withValues(alpha: weekendOpacity)
              : null,
          border: Border(
            right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
