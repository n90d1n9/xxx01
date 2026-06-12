import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class AnalyticsPanel extends ConsumerStatefulWidget {
  const AnalyticsPanel({super.key});
  @override
  ConsumerState<AnalyticsPanel> createState() => _AnalyticsPanelState();
}

class _AnalyticsPanelState extends ConsumerState<AnalyticsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(left: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(children: [
        // Header
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: Row(children: [
            const Icon(Icons.bar_chart, size: 14, color: GanttTheme.accent),
            const SizedBox(width: 8),
            const Text('Analytics',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.close, size: 14),
                color: GanttTheme.textMuted,
                padding: EdgeInsets.zero,
                onPressed: () =>
                    ref.read(analyticsOpenProvider.notifier).state = false),
          ]),
        ),
        // Tabs
        TabBar(
          controller: _tabs,
          isScrollable: false,
          indicatorColor: GanttTheme.accent,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
              fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600),
          labelColor: GanttTheme.accent,
          unselectedLabelColor: GanttTheme.textMuted,
          tabs: const [
            Tab(text: 'Burndown'),
            Tab(text: 'EVM'),
            Tab(text: 'Heatmap')
          ],
        ),
        Expanded(
            child: TabBarView(controller: _tabs, children: [
          _BurndownChart(tasks: tasks),
          _EvmPanel(tasks: tasks),
          _VelocityHeatmap(tasks: tasks),
        ])),
      ]),
    );
  }
}

// ─── Burndown Chart ───────────────────────────────────────────────────────────

class _BurndownChart extends StatelessWidget {
  final List<Task> tasks;
  const _BurndownChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const _EmptyState(label: 'No tasks to chart');
    final (start, end) = _range();
    final totalDays = end.difference(start).inDays;
    if (totalDays <= 0) return const _EmptyState(label: 'Invalid date range');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Remaining Work',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textSecondary)),
        const SizedBox(height: 4),
        const Text('Actual vs ideal completion trajectory',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: GanttTheme.textMuted)),
        const SizedBox(height: 16),
        SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _BurndownPainter(tasks: tasks, start: start, end: end),
              size: const Size(double.infinity, 200),
              child: Container(),
            )),
        const SizedBox(height: 12),
        Row(children: [
          _ChartLegend(color: GanttTheme.accent, label: 'Actual remaining'),
          const SizedBox(width: 16),
          _ChartLegend(
              color: GanttTheme.textDisabled,
              label: 'Ideal burndown',
              dashed: true),
        ]),
      ]),
    );
  }

  (DateTime, DateTime) _range() {
    final starts = tasks.map((t) => t.startDate).toList()..sort();
    final ends = tasks.map((t) => t.endDate).toList()..sort();
    return (starts.first, ends.last);
  }
}

class _BurndownPainter extends CustomPainter {
  final List<Task> tasks;
  final DateTime start;
  final DateTime end;
  const _BurndownPainter(
      {required this.tasks, required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final totalDays = end.difference(start).inDays;
    final total = tasks.length.toDouble();
    final today = DateTime.now();
    final w = size.width;
    final h = size.height - 20;

    // Grid
    final gridP = Paint()
      ..color = GanttTheme.gridLine
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 4; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridP);
      final tp = TextPainter(
          text: TextSpan(
              text: '${(total * (1 - i / 4)).toInt()}',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8,
                  color: GanttTheme.textMuted)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(0, y - 8));
    }

    // Ideal line (dashed)
    final idealP = Paint()
      ..color = GanttTheme.textDisabled.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final idealPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, h);
    _drawDashedPath(canvas, idealPath, idealP);

    // Actual points
    final points = <Offset>[];
    for (int i = 0; i <= totalDays; i++) {
      final day = start.add(Duration(days: i));
      if (day.isAfter(today)) break;
      final completed = tasks
          .where((t) => t.status == TaskStatus.done && t.endDate.isBefore(day))
          .length;
      final remaining = total - completed;
      final x = w * i / totalDays;
      final y = h * remaining / total;
      points.add(Offset(x, y));
    }

    if (points.length >= 2) {
      // Fill
      final fillPath = Path()..moveTo(points.first.dx, h);
      for (final p in points) fillPath.lineTo(p.dx, p.dy);
      fillPath.lineTo(points.last.dx, h)..close();
      canvas.drawPath(
          fillPath,
          Paint()
            ..shader = LinearGradient(colors: [
              GanttTheme.accent.withOpacity(0.3),
              GanttTheme.accent.withOpacity(0.0)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                .createShader(Rect.fromLTWH(0, 0, w, h)));

      // Line
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) linePath.lineTo(p.dx, p.dy);
      canvas.drawPath(
          linePath,
          Paint()
            ..color = GanttTheme.accent
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);

      // Today dot
      if (points.isNotEmpty)
        canvas.drawCircle(points.last, 4, Paint()..color = GanttTheme.accent);
    }

    // Axes
    canvas.drawLine(
        Offset(0, 0),
        Offset(0, h + 2),
        Paint()
          ..color = GanttTheme.surface4
          ..strokeWidth = 1);
    canvas.drawLine(
        Offset(0, h),
        Offset(w, h),
        Paint()
          ..color = GanttTheme.surface4
          ..strokeWidth = 1);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      double pos = 0;
      while (pos < metric.length) {
        final seg = metric.extractPath(pos, math.min(pos + 6, metric.length));
        canvas.drawPath(seg, paint);
        pos += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_BurndownPainter old) => old.tasks != tasks;
}

// ─── EVM Panel ────────────────────────────────────────────────────────────────

class _EvmPanel extends StatelessWidget {
  final List<Task> tasks;
  const _EvmPanel({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const _EmptyState(label: 'No tasks for EVM');
    final today = DateTime.now();
    final total = tasks.length.toDouble();

    // Planned Value: proportion of tasks that should be done by today
    final planned = tasks
            .where((t) =>
                t.endDate.isBefore(today) || t.endDate.isAtSameMomentAs(today))
            .length /
        total;
    // Earned Value: actual progress weighted
    final earned = tasks.map((t) => t.progress).reduce((a, b) => a + b) / total;
    // Actual Cost (normalized by estimated hours)
    final totalEst = tasks.fold(0.0, (s, t) => s + t.estimatedHours);
    final totalActual = tasks.fold(0.0, (s, t) => s + t.actualHours);
    final ac = totalEst > 0 ? totalActual / totalEst : 0.0;

    final spi = planned > 0 ? earned / planned : 1.0;
    final cpi = ac > 0 ? earned / ac : 1.0;
    final cv = earned - ac;
    final sv = earned - planned;
    final eac = cpi > 0 ? 1.0 / cpi : 1.0;
    final budgetUtil = math.min(ac, 2.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Key metrics
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            _EvmCard('PV', '${(planned * 100).toInt()}%', 'Planned Value',
                GanttTheme.info),
            _EvmCard('EV', '${(earned * 100).toInt()}%', 'Earned Value',
                GanttTheme.success),
            _EvmCard('AC', '${(ac * 100).toInt()}%', 'Actual Cost',
                GanttTheme.warning),
            _EvmCard('EAC', '${(eac * 100).toInt()}%', 'Est. at Completion',
                eac > 1.1 ? GanttTheme.danger : GanttTheme.success),
          ],
        ),
        const SizedBox(height: 16),
        // Indices
        Row(children: [
          Expanded(child: _IndexCard('SPI', spi, 'Schedule Performance Index')),
          const SizedBox(width: 8),
          Expanded(child: _IndexCard('CPI', cpi, 'Cost Performance Index')),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _IndexCard('SV', sv, 'Schedule Variance', showSign: true)),
          const SizedBox(width: 8),
          Expanded(
              child: _IndexCard('CV', cv, 'Cost Variance', showSign: true)),
        ]),
        const SizedBox(height: 16),
        // Progress bars
        const Text('BUDGET UTILIZATION', style: GanttTheme.headerLabel),
        const SizedBox(height: 8),
        _ProgressBar(
            label: 'Actual Cost',
            value: budgetUtil / 2,
            color: ac > 1.0 ? GanttTheme.danger : GanttTheme.warning,
            text: '${(ac * 100).toInt()}%'),
        const SizedBox(height: 6),
        _ProgressBar(
            label: 'Schedule Progress',
            value: earned,
            color: GanttTheme.success,
            text: '${(earned * 100).toInt()}%'),
        const SizedBox(height: 6),
        _ProgressBar(
            label: 'Planned Progress',
            value: planned,
            color: GanttTheme.info,
            text: '${(planned * 100).toInt()}%'),
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: GanttTheme.surface2,
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(
                  spi >= 1.0 && cpi >= 1.0
                      ? Icons.check_circle
                      : Icons.warning_amber,
                  size: 14,
                  color: spi >= 1.0 && cpi >= 1.0
                      ? GanttTheme.success
                      : GanttTheme.warning),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      spi >= 1.0 && cpi >= 1.0
                          ? 'Project on schedule and within budget'
                          : spi < 1.0 && cpi < 1.0
                              ? 'Behind schedule and over budget'
                              : spi < 1.0
                                  ? 'Behind schedule, within budget'
                                  : 'On schedule, over budget',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: GanttTheme.textSecondary))),
            ])),
      ]),
    );
  }
}

class _EvmCard extends StatelessWidget {
  final String title, value, subtitle;
  final Color color;
  const _EvmCard(this.title, this.value, this.subtitle, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: GanttTheme.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                Text(title,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color.withOpacity(0.8))),
                const Spacer(),
                Text(value,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ]),
              Text(subtitle,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      color: GanttTheme.textMuted)),
            ]),
      );
}

class _IndexCard extends StatelessWidget {
  final String label, description;
  final double value;
  final bool showSign;
  const _IndexCard(this.label, this.value, this.description,
      {this.showSign = false});
  @override
  Widget build(BuildContext context) {
    final isGood = showSign ? value >= 0 : value >= 1.0;
    final color = isGood ? GanttTheme.success : GanttTheme.danger;
    final text = showSign
        ? '${value >= 0 ? "+" : ""}${(value * 100).toInt()}%'
        : value.toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: GanttTheme.surface2, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textMuted)),
          Text(description,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: GanttTheme.textDisabled)),
        ]),
        const Spacer(),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(text,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color))),
      ]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label, text;
  final double value;
  final Color color;
  const _ProgressBar(
      {required this.label,
      required this.value,
      required this.color,
      required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: GanttTheme.textMuted))),
        Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                    value: value.clamp(0, 1),
                    backgroundColor: GanttTheme.surface3,
                    color: color,
                    minHeight: 5))),
        const SizedBox(width: 6),
        SizedBox(
            width: 36,
            child: Text(text,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color),
                textAlign: TextAlign.right)),
      ]);
}

// ─── Velocity Heatmap ─────────────────────────────────────────────────────────

class _VelocityHeatmap extends StatelessWidget {
  final List<Task> tasks;
  const _VelocityHeatmap({required this.tasks});

  @override
  Widget build(BuildContext context) {
    // Build completion counts by date
    final completionMap = <DateTime, int>{};
    for (final t in tasks) {
      if (t.status == TaskStatus.done) {
        final d = GanttDateUtils.dateOnly(t.endDate);
        completionMap[d] = (completionMap[d] ?? 0) + 1;
      }
    }

    final today = GanttDateUtils.dateOnly(DateTime.now());
    final startWeek = today
        .subtract(Duration(days: today.weekday - 1 + 7 * 11)); // 12 weeks ago
    final maxVal = completionMap.values.isEmpty
        ? 1
        : completionMap.values.reduce(math.max);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Task Completions',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textSecondary)),
        const SizedBox(height: 4),
        const Text('Last 12 weeks',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: GanttTheme.textMuted)),
        const SizedBox(height: 12),
        // Day labels
        Row(children: [
          const SizedBox(width: 28),
          for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
            Expanded(
                child: Text(d,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: GanttTheme.textMuted),
                    textAlign: TextAlign.center)),
        ]),
        const SizedBox(height: 4),
        // Grid
        ...List.generate(12, (week) {
          final weekStart = startWeek.add(Duration(days: week * 7));
          final isCurrentWeek = GanttDateUtils.isSameDay(
              weekStart, today.subtract(Duration(days: today.weekday - 1)));
          return Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(children: [
              SizedBox(
                  width: 28,
                  child: week % 4 == 0
                      ? Text(GanttDateUtils.formatMonthShort(weekStart),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              color: GanttTheme.textMuted))
                      : null),
              ...List.generate(7, (dayOfWeek) {
                final day = weekStart.add(Duration(days: dayOfWeek));
                final count = completionMap[day] ?? 0;
                final isToday = GanttDateUtils.isSameDay(day, today);
                final intensity = maxVal == 0 ? 0.0 : count / maxVal;
                final col = _heatColor(intensity);
                return Expanded(
                    child: Tooltip(
                  message:
                      '${GanttDateUtils.formatShortDate(day)}: $count task${count != 1 ? "s" : ""}',
                  child: Container(
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(2),
                      border: isToday
                          ? Border.all(color: GanttTheme.accent, width: 1.5)
                          : null,
                    ),
                  ),
                ));
              }),
            ]),
          );
        }),
        const SizedBox(height: 12),
        // Legend
        Row(children: [
          const Text('Less',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: GanttTheme.textMuted)),
          const SizedBox(width: 4),
          for (final i in [0.0, 0.25, 0.5, 0.75, 1.0])
            Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                    color: _heatColor(i),
                    borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          const Text('More',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: GanttTheme.textMuted)),
          const Spacer(),
          Text(
              '${completionMap.values.fold(0, (a, b) => a + b)} tasks completed',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: GanttTheme.textMuted)),
        ]),
      ]),
    );
  }

  Color _heatColor(double intensity) {
    if (intensity == 0) return GanttTheme.surface3;
    final shades = [
      const Color(0xFF0E4429),
      const Color(0xFF006D32),
      const Color(0xFF26A641),
      const Color(0xFF39D353)
    ];
    final idx =
        ((intensity * (shades.length - 1))).round().clamp(0, shades.length - 1);
    return shades[idx];
  }
}

// ─── Chart legend ─────────────────────────────────────────────────────────────

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _ChartLegend(
      {required this.color, required this.label, this.dashed = false});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 20, height: 2, color: color.withOpacity(dashed ? 0.4 : 1.0)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: GanttTheme.textMuted)),
      ]);
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.bar_chart, size: 32, color: GanttTheme.textDisabled),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: GanttTheme.textMuted)),
      ]));
}
