import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class ResourceHistogram extends ConsumerWidget {
  final DateTime ganttStart;
  final DateTime ganttEnd;
  final double dayWidth;
  final ScrollController hScrollController;

  const ResourceHistogram({
    super.key,
    required this.ganttStart,
    required this.ganttEnd,
    required this.dayWidth,
    required this.hScrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceLoad = ref.watch(resourceLoadProvider);
    final totalDays = GanttDateUtils.daysBetween(ganttStart, ganttEnd) + 1;
    final totalW = totalDays * dayWidth;

    // Build per-day totals
    final dailyTotals = <DateTime, double>{};
    final dailyCap = <DateTime, double>{};
    final assignees = ref.watch(allAssigneesProvider);
    final totalCapPerDay =
        assignees.fold(0.0, (sum, a) => sum + a.allocatedHoursPerDay);

    for (int i = 0; i < totalDays; i++) {
      final day = ganttStart.add(Duration(days: i));
      final dateOnly = GanttDateUtils.dateOnly(day);
      double total = 0;
      if (resourceLoad.containsKey(dateOnly)) {
        resourceLoad[dateOnly]!.forEach((_, h) => total += h);
      }
      dailyTotals[dateOnly] = total;
      dailyCap[dateOnly] = totalCapPerDay > 0 ? totalCapPerDay : 8.0;
    }

    final maxHours =
        dailyTotals.values.isEmpty ? 8.0 : dailyTotals.values.reduce(math.max);
    final barMax =
        math.max(maxHours, totalCapPerDay > 0 ? totalCapPerDay * 1.2 : 8.0);

    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: GanttTheme.surface0,
        border: Border(top: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: GanttTheme.surface1,
          child: Row(children: [
            const Icon(Icons.people_outline,
                size: 12, color: GanttTheme.textMuted),
            const SizedBox(width: 6),
            const Text('RESOURCE LOAD', style: GanttTheme.headerLabel),
            const SizedBox(width: 12),
            _LegendDot(color: GanttTheme.success, label: 'Normal'),
            const SizedBox(width: 8),
            _LegendDot(color: GanttTheme.warning, label: '80–100%'),
            const SizedBox(width: 8),
            _LegendDot(color: GanttTheme.danger, label: 'Overloaded'),
            const Spacer(),
            if (totalCapPerDay > 0)
              Text('Capacity: ${totalCapPerDay.toInt()}h/day',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: GanttTheme.textMuted)),
          ]),
        ),
        // Bars
        Expanded(
            child: SingleChildScrollView(
          controller: hScrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: totalW,
            height: 92,
            child: CustomPaint(
              painter: _HistogramPainter(
                ganttStart: ganttStart,
                dailyTotals: dailyTotals,
                dailyCap: dailyCap,
                totalDays: totalDays,
                dayWidth: dayWidth,
                maxHours: barMax,
                capacityHours: totalCapPerDay > 0 ? totalCapPerDay : 8.0,
              ),
            ),
          ),
        )),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 9, color: GanttTheme.textMuted)),
      ]);
}

class _HistogramPainter extends CustomPainter {
  final DateTime ganttStart;
  final Map<DateTime, double> dailyTotals;
  final Map<DateTime, double> dailyCap;
  final int totalDays;
  final double dayWidth;
  final double maxHours;
  final double capacityHours;

  const _HistogramPainter({
    required this.ganttStart,
    required this.dailyTotals,
    required this.dailyCap,
    required this.totalDays,
    required this.dayWidth,
    required this.maxHours,
    required this.capacityHours,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final usableH = h - 14; // leave room for hour labels at bottom

    // Grid lines
    final gridPaint = Paint()
      ..color = GanttTheme.gridLine
      ..strokeWidth = 0.5;
    for (final pct in [0.25, 0.5, 0.75, 1.0]) {
      final y = h - 14 - usableH * pct * (capacityHours / maxHours);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Capacity dashed line
    final capY = h - 14 - usableH * (capacityHours / maxHours);
    final dashPaint = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.5)
      ..strokeWidth = 1.0;
    double dx = 0;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, capY),
          Offset(math.min(dx + 6, size.width), capY), dashPaint);
      dx += 10;
    }

    // Bars
    for (int i = 0; i < totalDays; i++) {
      final day = GanttDateUtils.dateOnly(ganttStart.add(Duration(days: i)));
      final hours = dailyTotals[day] ?? 0.0;
      final cap = dailyCap[day] ?? capacityHours;

      if (hours == 0) continue;

      final ratio = hours / maxHours;
      final loadRatio = hours / cap;

      final barH = usableH * ratio;
      final left = i * dayWidth + 1;
      final barW = dayWidth - 2;

      final color = loadRatio > 1.0
          ? GanttTheme.danger
          : loadRatio >= 0.8
              ? GanttTheme.warning
              : GanttTheme.success;
      final paint = Paint()..color = color.withOpacity(0.75);

      final rect = RRect.fromLTRBR(
          left, h - 14 - barH, left + barW, h - 14, const Radius.circular(2));
      canvas.drawRRect(rect, paint);

      // Overload hatching
      if (loadRatio > 1.0) {
        final hatchPaint = Paint()
          ..color = GanttTheme.danger.withOpacity(0.3)
          ..strokeWidth = 1.0;
        double sy = h - 14 - barH;
        while (sy < h - 14) {
          final lineStart = Offset(left, sy);
          final lineEnd = Offset(math.min(left + barW, left + (h - 14 - sy)),
              math.min(sy + barW, h - 14));
          canvas.drawLine(lineStart, lineEnd, hatchPaint);
          sy += 5;
        }
      }

      // Hours label on tall bars
      if (dayWidth > 28 && barH > 18) {
        final tp = TextPainter(
          text: TextSpan(
              text: hours.toStringAsFixed(0),
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8,
                  color: color,
                  fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas, Offset(left + (barW - tp.width) / 2, h - 14 - barH - 11));
      }
    }

    // Day label (hidden if too small)
    if (dayWidth >= 24) {
      final labelPaint = Paint()..color = GanttTheme.textMuted;
      for (int i = 0; i < totalDays; i += dayWidth < 32 ? 2 : 1) {
        final day = ganttStart.add(Duration(days: i));
        final tp = TextPainter(
          text: TextSpan(
              text: '${day.day}',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8,
                  color: GanttTheme.textMuted)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas, Offset(i * dayWidth + (dayWidth - tp.width) / 2, h - 12));
      }
    }
  }

  @override
  bool shouldRepaint(_HistogramPainter old) =>
      old.dailyTotals != dailyTotals ||
      old.dayWidth != dayWidth ||
      old.maxHours != maxHours;
}
