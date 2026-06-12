import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

// ─── State for interactive dependency drawing ─────────────────────────────────

/// Tracks in-progress dependency draw gesture
class _DrawState {
  final String fromTaskId;
  final Offset fromPoint;
  final Offset currentPoint;

  const _DrawState({
    required this.fromTaskId,
    required this.fromPoint,
    required this.currentPoint,
  });

  _DrawState copyWith({Offset? currentPoint}) => _DrawState(
        fromTaskId: fromTaskId,
        fromPoint: fromPoint,
        currentPoint: currentPoint ?? this.currentPoint,
      );
}

final _depDrawStateProvider = StateProvider<_DrawState?>((_) => null);

// ─── Draw handle on right edge of each bar ────────────────────────────────────

/// Tiny connector dot shown on right edge of task bars in "draw mode".
class DepDrawHandle extends ConsumerWidget {
  final Task task;
  final double barRight; // absolute X within chart
  final double barCenterY; // absolute Y within chart

  const DepDrawHandle({
    super.key,
    required this.task,
    required this.barRight,
    required this.barCenterY,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawing = ref.watch(_depDrawStateProvider);
    final isSource = drawing?.fromTaskId == task.id;

    return Positioned(
      left: barRight - 6,
      top: barCenterY - 6,
      width: 12,
      height: 12,
      child: MouseRegion(
        cursor: SystemMouseCursors.cell,
        child: GestureDetector(
          onPanStart: (d) {
            ref.read(_depDrawStateProvider.notifier).state = _DrawState(
              fromTaskId: task.id,
              fromPoint: Offset(barRight, barCenterY),
              currentPoint: Offset(barRight, barCenterY),
            );
          },
          onPanUpdate: (d) {
            final s = ref.read(_depDrawStateProvider);
            if (s != null) {
              ref.read(_depDrawStateProvider.notifier).state =
                  s.copyWith(currentPoint: s.currentPoint + d.delta);
            }
          },
          onPanEnd: (_) =>
              ref.read(_depDrawStateProvider.notifier).state = null,
          child: AnimatedContainer(
            duration: GanttAnimations.fast,
            decoration: BoxDecoration(
              color: isSource ? GanttTheme.accent : GanttTheme.surface4,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSource ? GanttTheme.accentLight : GanttTheme.textMuted,
                width: 1.5,
              ),
              boxShadow: isSource
                  ? [
                      BoxShadow(
                          color: GanttTheme.accent.withOpacity(0.5),
                          blurRadius: 6)
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Drop target on left edge of each bar ────────────────────────────────────

/// Invisible drop zone on the left of each bar. When a draw gesture releases
/// here, we add the dependency.
class DepDropTarget extends ConsumerWidget {
  final Task task;
  final double barLeft;
  final double barCenterY;

  const DepDropTarget({
    super.key,
    required this.task,
    required this.barLeft,
    required this.barCenterY,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawing = ref.watch(_depDrawStateProvider);
    if (drawing == null) return const SizedBox.shrink();
    if (drawing.fromTaskId == task.id) return const SizedBox.shrink();

    // Check if current draw point is near our left edge
    final dist = (drawing.currentPoint - Offset(barLeft, barCenterY)).distance;
    final isHot = dist < 28;

    return Positioned(
      left: barLeft - 14,
      top: barCenterY - 14,
      width: 28,
      height: 28,
      child: GestureDetector(
        onPanEnd: (_) {
          if (!isHot) return;
          _addDependency(ref, drawing.fromTaskId, task.id);
          ref.read(_depDrawStateProvider.notifier).state = null;
        },
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          decoration: BoxDecoration(
            color: isHot
                ? GanttTheme.success.withOpacity(0.25)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isHot ? GanttTheme.success : Colors.transparent,
              width: 2,
            ),
          ),
          child: isHot
              ? const Center(
                  child: Icon(Icons.link, size: 14, color: GanttTheme.success))
              : null,
        ),
      ),
    );
  }

  void _addDependency(WidgetRef ref, String fromId, String toId) {
    final tasks = ref.read(tasksProvider);
    // Prevent duplicate
    final target = tasks.firstWhere((t) => t.id == toId);
    if (target.dependencies.any((d) => d.predecessorId == fromId)) return;

    // Prevent circular: check if fromId depends on toId
    if (_wouldCreateCycle(tasks, fromId, toId)) return;

    final updated = target.copyWith(
      dependencies: [
        ...target.dependencies,
        TaskDependency(predecessorId: fromId, type: DependencyType.fs),
      ],
      updatedAt: DateTime.now(),
    );
    ref.read(tasksProvider.notifier).updateTask(updated);
  }

  bool _wouldCreateCycle(List<Task> tasks, String from, String to) {
    // DFS from 'from' following predecessors; if we reach 'to', it's circular
    final map = {for (final t in tasks) t.id: t};
    final visited = <String>{};
    bool dfs(String id) {
      if (id == to) return true;
      if (!visited.add(id)) return false;
      final t = map[id];
      if (t == null) return false;
      for (final dep in t.dependencies) {
        if (dfs(dep.predecessorId)) return true;
      }
      return false;
    }

    return dfs(from);
  }
}

// ─── In-progress draw line painter ───────────────────────────────────────────

/// Paints the rubber-band line while user is drawing a dependency.
class DependencyDrawLinePainter extends CustomPainter {
  final _DrawState? state;
  const DependencyDrawLinePainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    if (state == null) return;
    final paint = Paint()
      ..color = GanttTheme.accent.withOpacity(0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = GanttTheme.accent.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final from = state!.fromPoint;
    final to = state!.currentPoint;
    final dx = (to.dx - from.dx) * 0.5;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);

    // Draw dashed glow path
    _drawDashed(canvas, path, dashPaint);
    canvas.drawPath(path, paint);

    // Arrow head
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowLen = 8.0;
    final arrowPaint = Paint()
      ..color = GanttTheme.accent
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - arrowLen * math.cos(angle - 0.4),
          to.dy - arrowLen * math.sin(angle - 0.4))
      ..lineTo(to.dx - arrowLen * math.cos(angle + 0.4),
          to.dy - arrowLen * math.sin(angle + 0.4))
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Source dot
    canvas.drawCircle(from, 5, Paint()..color = GanttTheme.accent);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashLen = 8.0;
    const gapLen = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final end = math.min(dist + dashLen, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(DependencyDrawLinePainter old) => old.state != state;
}

/// Provider to expose draw state to the viewport layer
final dependencyDrawStateProvider = _depDrawStateProvider;
