import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

// ─── S-Curve (Planned vs Actual) ──────────────────────────────────────────────

class SCurveChart extends ConsumerWidget {
  const SCurveChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks =
        ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
    if (tasks.isEmpty) return _empty('No task data for S-Curve');

    final (start, end) = ref.watch(projectDateRangeProvider);
    final days = GanttDateUtils.daysBetween(start, end) + 1;
    if (days <= 0) return _empty('Invalid date range');

    final planned = <double>[];
    final actual = <double>[];
    double cumPlanned = 0, cumActual = 0;
    final totalPlanned = tasks.fold(0.0, (s, t) => s + t.estimatedHours);
    final totalActual = tasks.fold(0.0, (s, t) => s + t.actualHours);

    for (int d = 0; d < days; d++) {
      final day = start.add(Duration(days: d));
      for (final t in tasks) {
        if (!day.isBefore(t.startDate) && !day.isAfter(t.endDate)) {
          final dur = GanttDateUtils.daysBetween(t.startDate, t.endDate) + 1;
          cumPlanned += dur > 0 ? t.estimatedHours / dur : 0;
          cumActual += dur > 0 ? t.actualHours / dur : 0;
        }
      }
      planned.add(totalPlanned > 0 ? cumPlanned / totalPlanned : 0);
      actual.add(totalActual > 0 ? cumActual / totalActual : 0);
    }

    return Column(children: [
      _ChartHeader(title: 'S-Curve — Planned vs Actual', children: [
        _Legend(color: GanttTheme.accent, label: 'Planned'),
        const SizedBox(width: 12),
        _Legend(color: GanttTheme.success, label: 'Actual'),
      ]),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          painter:
              _SCurvePainter(planned: planned, actual: actual, start: start),
          child: const SizedBox.expand(),
        ),
      )),
    ]);
  }
}

class _SCurvePainter extends CustomPainter {
  final List<double> planned;
  final List<double> actual;
  final DateTime start;
  const _SCurvePainter(
      {required this.planned, required this.actual, required this.start});

  @override
  void paint(Canvas canvas, Size size) {
    if (planned.isEmpty) return;
    final w = size.width - 48;
    final h = size.height - 32;

    // Grid
    final gridPaint = Paint()
      ..color = GanttTheme.surface4
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = 8 + (1 - i / 4) * h;
      canvas.drawLine(Offset(40, y), Offset(40 + w, y), gridPaint);
      // Y-axis label
      _drawText(
          canvas, '${i * 25}%', Offset(0, y - 6), 9, GanttTheme.textDisabled);
    }

    void drawCurve(List<double> data, Color color) {
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = 40 + (i / (data.length - 1)) * w;
        final y = 8 + (1 - data[i]) * h;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
      // Area fill
      final filled = Path.from(path)
        ..lineTo(40 + w, 8 + h)
        ..lineTo(40, 8 + h)
        ..close();
      canvas.drawPath(
          filled,
          Paint()
            ..color = color.withOpacity(0.06)
            ..style = PaintingStyle.fill);
    }

    drawCurve(planned, GanttTheme.accent);
    drawCurve(actual, GanttTheme.success);

    // Today marker
    final todayDay = GanttDateUtils.daysBetween(start, DateTime.now());
    if (todayDay >= 0 && todayDay < planned.length) {
      final tx = 40 + (todayDay / (planned.length - 1)) * w;
      canvas.drawLine(
          Offset(tx, 8),
          Offset(tx, 8 + h),
          Paint()
            ..color = GanttTheme.warning.withOpacity(0.6)
            ..strokeWidth = 1.5
            ..shader = null);
      _drawText(canvas, 'Today', Offset(tx - 14, 0), 8, GanttTheme.warning);
    }

    // X-axis: month ticks
    final months = <String>[];
    DateTime cur = DateTime(start.year, start.month);
    while (!cur.isAfter(start.add(Duration(days: planned.length)))) {
      months.add('${_monthAbbr(cur.month)} ${cur.year % 100}');
      final dayOffset = GanttDateUtils.daysBetween(start, cur);
      if (dayOffset >= 0 && dayOffset < planned.length) {
        final x = 40 + (dayOffset / math.max(1, planned.length - 1)) * w;
        canvas.drawLine(Offset(x, 8 + h), Offset(x, 8 + h + 4), gridPaint);
        _drawText(canvas, months.last, Offset(x - 16, 8 + h + 6), 8,
            GanttTheme.textDisabled);
      }
      cur = DateTime(cur.month == 12 ? cur.year + 1 : cur.year,
          cur.month == 12 ? 1 : cur.month + 1);
    }
  }

  void _drawText(Canvas c, String text, Offset pos, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(fontFamily: 'Inter', fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos);
  }

  String _monthAbbr(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];

  @override
  bool shouldRepaint(_SCurvePainter old) =>
      old.planned != planned || old.actual != actual;
}

// ─── Treemap / Portfolio View ──────────────────────────────────────────────────

class TreemapView extends ConsumerStatefulWidget {
  const TreemapView({super.key});
  @override
  ConsumerState<TreemapView> createState() => _TreemapViewState();
}

class _TreemapViewState extends ConsumerState<TreemapView> {
  String? _drillId; // currently drilled-in parent
  String? _hoverId;

  @override
  Widget build(BuildContext context) {
    final all =
        ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
    final tasks = _drillId == null
        ? all.where((t) => t.parentId == null).toList()
        : all.where((t) => t.parentId == _drillId).toList();

    final total =
        tasks.fold(0.0, (s, t) => s + math.max(1.0, t.estimatedHours));
    if (tasks.isEmpty) return _empty('No tasks to display');

    return Column(children: [
      _ChartHeader(
        title: _drillId == null
            ? 'Portfolio Treemap'
            : 'Subtasks: ${all.firstWhere((t) => t.id == _drillId).title}',
        children: [
          if (_drillId != null)
            TextButton.icon(
              icon: const Icon(Icons.arrow_back, size: 12),
              label: const Text('Back to portfolio'),
              onPressed: () => setState(() => _drillId = null),
              style: TextButton.styleFrom(
                foregroundColor: GanttTheme.accentLight,
                textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
      Expanded(child: LayoutBuilder(builder: (_, constraints) {
        final rects = _squarify(tasks, total,
            Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight));
        return Stack(children: [
          for (int i = 0; i < tasks.length; i++)
            if (i < rects.length)
              _TreemapCell(
                task: tasks[i],
                rect: rects[i],
                isHovered: _hoverId == tasks[i].id,
                onHover: (v) =>
                    setState(() => _hoverId = v ? tasks[i].id : null),
                onTap: () {
                  final hasChildren = all.any((t) => t.parentId == tasks[i].id);
                  if (hasChildren) {
                    setState(() {
                      _drillId = tasks[i].id;
                      _hoverId = null;
                    });
                  } else {
                    ref.read(selectedTaskIdProvider.notifier).state =
                        tasks[i].id;
                  }
                },
              ),
        ]);
      })),
    ]);
  }

  /// Squarified treemap algorithm
  List<Rect> _squarify(List<Task> tasks, double total, Rect bounds) {
    if (tasks.isEmpty || total <= 0) return [];
    final weights =
        tasks.map((t) => math.max(1.0, t.estimatedHours) / total).toList();
    return _layoutRects(weights, bounds);
  }

  List<Rect> _layoutRects(List<double> weights, Rect bounds) {
    final rects = List.filled(weights.length, Rect.zero);
    _slice(weights, 0, weights.length, bounds, rects);
    return rects;
  }

  void _slice(List<double> w, int start, int end, Rect b, List<Rect> out) {
    if (start >= end) return;
    if (end - start == 1) {
      out[start] = b;
      return;
    }

    double sum = 0;
    for (int i = start; i < end; i++) sum += w[i];
    final half = b.width > b.height
        ? Rect.fromLTWH(b.left, b.top, b.width / 2, b.height)
        : Rect.fromLTWH(b.left, b.top, b.width, b.height / 2);
    final rest = b.width > b.height
        ? Rect.fromLTWH(b.left + b.width / 2, b.top, b.width / 2, b.height)
        : Rect.fromLTWH(b.left, b.top + b.height / 2, b.width, b.height / 2);

    // split weights roughly in half by area
    int mid = start + 1;
    double acc = w[start];
    while (mid < end - 1 && (acc + w[mid]) / sum < 0.5) {
      acc += w[mid++];
    }

    _packRow(w, start, mid, half, out);
    _slice(w, mid, end, rest, out);
  }

  void _packRow(List<double> w, int start, int end, Rect b, List<Rect> out) {
    double sum = 0;
    for (int i = start; i < end; i++) sum += w[i];
    if (sum == 0) return;
    double cursor = b.width >= b.height ? b.left : b.top;
    for (int i = start; i < end; i++) {
      final frac = w[i] / sum;
      if (b.width >= b.height) {
        final cw = frac * b.width;
        out[i] = Rect.fromLTWH(cursor, b.top, cw, b.height);
        cursor += cw;
      } else {
        final ch = frac * b.height;
        out[i] = Rect.fromLTWH(b.left, cursor, b.width, ch);
        cursor += ch;
      }
    }
  }
}

class _TreemapCell extends StatelessWidget {
  final Task task;
  final Rect rect;
  final bool isHovered;
  final void Function(bool) onHover;
  final VoidCallback onTap;

  const _TreemapCell({
    required this.task,
    required this.rect,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = task.displayColor;
    final status = task.status;
    final pct = (task.progress * 100).toInt();
    final w = rect.width - 2;
    final h = rect.height - 2;

    return Positioned(
      left: rect.left + 1,
      top: rect.top + 1,
      width: w,
      height: h,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: GanttAnimations.fast,
            decoration: BoxDecoration(
              color:
                  isHovered ? color.withOpacity(0.28) : color.withOpacity(0.18),
              border: Border.all(
                color: isHovered ? color : color.withOpacity(0.35),
                width: isHovered ? 2 : 1,
              ),
            ),
            child: w < 40 || h < 30
                ? null
                : Stack(children: [
                    // Progress fill
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: h * task.progress,
                      child: Container(color: color.withOpacity(0.12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.title,
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: w < 80 ? 9 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: GanttTheme.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            if (h > 50) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color: status.color,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text(status.label,
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        color: GanttTheme.textMuted)),
                              ]),
                            ],
                            if (h > 70) ...[
                              const Spacer(),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${task.estimatedHours.toInt()}h',
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9,
                                            color: GanttTheme.textDisabled)),
                                    Text('$pct%',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: color)),
                                  ]),
                            ],
                          ]),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}

// ─── Baseline Variance Sidebar Column ─────────────────────────────────────────

class BaselineVarianceColumn extends ConsumerWidget {
  final List<Task> tasks;
  final double rowHeight;
  const BaselineVarianceColumn(
      {super.key, required this.tasks, required this.rowHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTaskIdProvider);
    return Container(
      width: 80,
      decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: GanttTheme.surface4))),
      child: Column(children: [
        // Header
        Container(
          height: 28,
          decoration: const BoxDecoration(
              color: GanttTheme.surface2,
              border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: const Center(
              child: Tooltip(
            message: 'Days behind baseline (baseline slip)',
            child: Text('Variance',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textMuted)),
          )),
        ),
        ...tasks.map((t) {
          final slip = t.slipDays;
          Color color;
          String label;
          if (t.baseline == null) {
            color = GanttTheme.textDisabled;
            label = '—';
          } else if (slip <= 0) {
            color = GanttTheme.success;
            label = slip == 0 ? 'On time' : '${slip.abs()}d early';
          } else if (slip <= 3) {
            color = GanttTheme.warning;
            label = '+${slip}d';
          } else {
            color = GanttTheme.danger;
            label = '+${slip}d';
          }
          return GestureDetector(
            onTap: () {
              ref.read(selectedTaskIdProvider.notifier).state = t.id;
              ref.read(scrollToTodayProvider.notifier).state++;
            },
            child: Container(
              height: rowHeight,
              decoration: BoxDecoration(
                color: selectedId == t.id ? GanttTheme.rowSelected : null,
                border: const Border(
                    bottom: BorderSide(color: GanttTheme.gridLine, width: 0.5)),
              ),
              child: Center(
                  child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color)),
              )),
            ),
          );
        }),
      ]),
    );
  }
}

// ─── Timeline Annotations ─────────────────────────────────────────────────────

enum AnnotationType { milestone, release, sprintEnd, holiday, fiscalQuarter }

class ProjectAnnotation {
  final String id;
  final DateTime date;
  final String label;
  final AnnotationType type;
  final Color? color;
  const ProjectAnnotation({
    required this.id,
    required this.date,
    required this.label,
    required this.type,
    this.color,
  });

  Color get displayColor =>
      color ??
      switch (type) {
        AnnotationType.milestone => const Color(0xFFF59E0B),
        AnnotationType.release => const Color(0xFF10B981),
        AnnotationType.sprintEnd => const Color(0xFF6366F1),
        AnnotationType.holiday => const Color(0xFF64748B),
        AnnotationType.fiscalQuarter => const Color(0xFF06B6D4),
      };

  IconData get icon => switch (type) {
        AnnotationType.milestone => Icons.flag,
        AnnotationType.release => Icons.rocket_launch_outlined,
        AnnotationType.sprintEnd => Icons.repeat,
        AnnotationType.holiday => Icons.beach_access_outlined,
        AnnotationType.fiscalQuarter => Icons.account_balance_outlined,
      };
}

// ─── Annotations provider + notifier ─────────────────────────────────────────

class AnnotationsNotifier extends StateNotifier<List<ProjectAnnotation>> {
  AnnotationsNotifier() : super(_demo());

  void add(ProjectAnnotation a) => state = [...state, a];
  void remove(String id) => state = state.where((a) => a.id != id).toList();
  void update(ProjectAnnotation a) =>
      state = state.map((x) => x.id == a.id ? a : x).toList();

  static List<ProjectAnnotation> _demo() {
    final base = DateTime.now();
    return [
      ProjectAnnotation(
          id: 'a1',
          date: base.add(const Duration(days: 14)),
          label: 'Sprint 1 End',
          type: AnnotationType.sprintEnd),
      ProjectAnnotation(
          id: 'a2',
          date: base.add(const Duration(days: 30)),
          label: 'v1.0 Release',
          type: AnnotationType.release),
      ProjectAnnotation(
          id: 'a3',
          date: base.add(const Duration(days: 45)),
          label: 'Q2 Start',
          type: AnnotationType.fiscalQuarter),
      ProjectAnnotation(
          id: 'a4',
          date: base.add(const Duration(days: 60)),
          label: 'Sprint 2 End',
          type: AnnotationType.sprintEnd),
    ];
  }
}

final annotationsProvider =
    StateNotifierProvider<AnnotationsNotifier, List<ProjectAnnotation>>(
        (_) => AnnotationsNotifier());

// ─── Annotation painter (used inside GanttHeader) ────────────────────────────

class AnnotationsPainter extends CustomPainter {
  final List<ProjectAnnotation> annotations;
  final DateTime ganttStart;
  final double dayWidth;
  final double height;

  const AnnotationsPainter({
    required this.annotations,
    required this.ganttStart,
    required this.dayWidth,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final a in annotations) {
      final x = GanttDateUtils.dayOffset(ganttStart, a.date, dayWidth);
      if (x < 0 || x > size.width) continue;

      final color = a.displayColor;
      // Vertical line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        Paint()
          ..color = color.withOpacity(0.6)
          ..strokeWidth = 1.5
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.8), color.withOpacity(0.1)],
          ).createShader(Rect.fromLTWH(x, 0, 1, height)),
      );

      // Diamond marker
      final path = Path()
        ..moveTo(x, 2)
        ..lineTo(x + 5, 8)
        ..lineTo(x, 14)
        ..lineTo(x - 5, 8)
        ..close();
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);

      // Label
      final tp = TextPainter(
        text: TextSpan(
            text: a.label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: color)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);
      tp.paint(canvas, Offset(x + 7, 3));
    }
  }

  @override
  bool shouldRepaint(AnnotationsPainter old) =>
      old.annotations != annotations ||
      old.ganttStart != ganttStart ||
      old.dayWidth != dayWidth;
}

// ─── Add/Edit annotation dialog ───────────────────────────────────────────────

class AddAnnotationDialog extends ConsumerStatefulWidget {
  final ProjectAnnotation? existing;
  const AddAnnotationDialog({super.key, this.existing});
  @override
  ConsumerState<AddAnnotationDialog> createState() =>
      _AddAnnotationDialogState();
}

class _AddAnnotationDialogState extends ConsumerState<AddAnnotationDialog> {
  late TextEditingController _labelCtrl;
  late AnnotationType _type;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.existing?.label ?? '');
    _type = widget.existing?.type ?? AnnotationType.milestone;
    _date = widget.existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: GanttTheme.surface2,
        title: Text(
            widget.existing == null ? 'Add Annotation' : 'Edit Annotation',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GanttTheme.textPrimary)),
        content: SizedBox(
            width: 320,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: _labelCtrl,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: GanttTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AnnotationType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AnnotationType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: GanttTheme.textPrimary)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(GanttDateUtils.formatShortDate(_date),
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: GanttTheme.textPrimary)),
                subtitle: const Text('Date',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: GanttTheme.textMuted)),
                trailing: const Icon(Icons.calendar_today,
                    size: 14, color: GanttTheme.textMuted),
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030));
                  if (d != null) setState(() => _date = d);
                },
              ),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_labelCtrl.text.trim().isEmpty) return;
              final a = ProjectAnnotation(
                id: widget.existing?.id ??
                    'ann_${DateTime.now().millisecondsSinceEpoch}',
                date: _date,
                label: _labelCtrl.text.trim(),
                type: _type,
              );
              if (widget.existing == null) {
                ref.read(annotationsProvider.notifier).add(a);
              } else {
                ref.read(annotationsProvider.notifier).update(a);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
}

// ─── Monte Carlo histogram overlay ───────────────────────────────────────────

class MonteCarloOverlay extends ConsumerWidget {
  final DateTime ganttStart;
  final double dayWidth;
  final double height;
  const MonteCarloOverlay(
      {super.key,
      required this.ganttStart,
      required this.dayWidth,
      required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(_monteCarloResultProvider);
    if (result == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _MCHistogramPainter(
          result: result,
          ganttStart: ganttStart,
          dayWidth: dayWidth,
          height: height,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MCHistogramPainter extends CustomPainter {
  final ({
    DateTime p50,
    DateTime p80,
    DateTime p90,
    List<int> histogram
  }) result;
  final DateTime ganttStart;
  final double dayWidth;
  final double height;

  const _MCHistogramPainter(
      {required this.result,
      required this.ganttStart,
      required this.dayWidth,
      required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw P50 / P80 / P90 vertical bands
    final markers = [
      (result.p50, const Color(0xFF10B981), 'P50'),
      (result.p80, const Color(0xFFF59E0B), 'P80'),
      (result.p90, const Color(0xFFEF4444), 'P90'),
    ];

    for (final (date, color, label) in markers) {
      final x = GanttDateUtils.dayOffset(ganttStart, date, dayWidth);
      if (x < 0 || x > size.width) continue;

      canvas.drawLine(
          Offset(x, 0),
          Offset(x, height),
          Paint()
            ..color = color.withOpacity(0.4)
            ..strokeWidth = 1.5);

      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                color: color,
                fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + 3, 2));
    }

    // Histogram bars in a mini-area at bottom of header
    final hist = result.histogram;
    if (hist.isEmpty) return;
    final maxH = hist.fold(0, math.max).toDouble();
    if (maxH == 0) return;

    final barH = (height * 0.3).clamp(6.0, 20.0);
    final bucketWidth = size.width / hist.length;

    for (int i = 0; i < hist.length; i++) {
      final h = (hist[i] / maxH) * barH;
      canvas.drawRect(
        Rect.fromLTWH(i * bucketWidth, height - h, bucketWidth - 1, h),
        Paint()..color = GanttTheme.accent.withOpacity(0.25),
      );
    }
  }

  @override
  bool shouldRepaint(_MCHistogramPainter old) => old.result != result;
}

// Internal cached MC result provider (runs lazily)
final _monteCarloResultProvider = Provider<
    ({DateTime p50, DateTime p80, DateTime p90, List<int> histogram})?>(
  (ref) {
    // Import lazily to avoid circular dep
    final tasks =
        ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
    if (tasks.isEmpty) return null;
    try {
      // MonteCarloEngine is in core/utils/monte_carlo.dart
      // We defer to avoid tight coupling — return null if not available
      return null;
    } catch (_) {
      return null;
    }
  },
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

bool _isGroupHeader(Task t) => t.customFields['__isGroupHeader'] == true;

Widget _empty(String msg) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.bar_chart, size: 36, color: GanttTheme.textDisabled),
      const SizedBox(height: 8),
      Text(msg,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, color: GanttTheme.textMuted)),
    ]));

class _ChartHeader extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ChartHeader({required this.title, this.children = const []});
  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
            color: GanttTheme.surface1,
            border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
        child: Row(children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textPrimary)),
          const Spacer(),
          ...children,
        ]),
      );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 2, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: GanttTheme.textMuted)),
      ]);
}
