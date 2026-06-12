import 'package:flutter/material.dart';

class KyGanttTodayMarker extends StatelessWidget {
  const KyGanttTodayMarker({
    required this.rangeStart,
    required this.totalDays,
    required this.dayWidth,
    required this.height,
    required this.today,
    this.markerKey = defaultMarkerKey,
    this.opacity = 1,
    super.key,
  });

  static const defaultMarkerKey = ValueKey('ky-gantt-today-marker');

  final DateTime rangeStart;
  final int totalDays;
  final double dayWidth;
  final double height;
  final DateTime today;
  final Key? markerKey;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final offset = todayOffsetDays(
      today: today,
      rangeStart: rangeStart,
      totalDays: totalDays,
    );
    if (offset == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      key: markerKey,
      left: offset * dayWidth,
      top: 0,
      height: height,
      child: Semantics(
        label: 'Today marker',
        child: Container(
          width: 2,
          color: colorScheme.primary.withValues(
            alpha: opacity.clamp(0, 1).toDouble(),
          ),
        ),
      ),
    );
  }

  static int? todayOffsetDays({
    required DateTime today,
    required DateTime rangeStart,
    required int totalDays,
  }) {
    final normalizedToday = DateUtils.dateOnly(today);
    final normalizedRangeStart = DateUtils.dateOnly(rangeStart);
    final offset = normalizedToday.difference(normalizedRangeStart).inDays;

    return offset < 0 || offset >= totalDays ? null : offset;
  }
}
