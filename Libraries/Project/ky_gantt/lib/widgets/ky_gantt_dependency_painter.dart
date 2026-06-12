import 'package:flutter/material.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_task.dart';
import '../utils/gantt_dependency_focus.dart';
import '../utils/gantt_dependency_health.dart';
import '../utils/gantt_task_layout.dart';

class KyGanttDependencyPainter extends CustomPainter {
  KyGanttDependencyPainter({
    required this.tasks,
    required this.rangeStart,
    required this.rangeEnd,
    required this.dayWidth,
    required this.rowHeight,
    required this.color,
    this.selectedTaskId,
    this.highlightSelectedTask = true,
    this.highlightConflictedDependencies = true,
    this.focusScope = KyGanttDependencyLineFocusScope.direct,
    this.highlightColor,
    this.conflictColor,
    this.lineOpacity = 0.62,
    this.inactiveLineOpacity = 0.16,
    this.highlightLineOpacity = 0.9,
    this.conflictLineOpacity = 0.92,
    this.strokeWidth = 1.6,
    this.highlightStrokeWidth = 2.4,
    this.conflictStrokeWidth = 2.2,
  });

  final List<GanttTask> tasks;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double dayWidth;
  final double rowHeight;
  final Color color;
  final String? selectedTaskId;
  final bool highlightSelectedTask;
  final bool highlightConflictedDependencies;
  final KyGanttDependencyLineFocusScope focusScope;
  final Color? highlightColor;
  final Color? conflictColor;
  final double lineOpacity;
  final double inactiveLineOpacity;
  final double highlightLineOpacity;
  final double conflictLineOpacity;
  final double strokeWidth;
  final double highlightStrokeWidth;
  final double conflictStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final indexById = <String, int>{
      for (var index = 0; index < tasks.length; index++) tasks[index].id: index,
    };
    final taskById = {for (final task in tasks) task.id: task};
    final selectedDependencyEdges = focusedGanttDependencyEdges(
      tasks: tasks,
      selectedTaskId: selectedTaskId,
      enabled: highlightSelectedTask,
      focusScope: focusScope,
    );
    final conflictedDependencyEdges = highlightConflictedDependencies
        ? conflictedGanttDependencyEdges(tasks: tasks)
        : const <KyGanttDependencyEdge>{};
    final segments = <_KyGanttDependencySegment>[];

    for (final task in tasks) {
      final predecessorId = task.dependsOn;
      if (predecessorId == null) continue;

      final predecessor = taskById[predecessorId];
      final predecessorIndex = indexById[predecessorId];
      final taskIndex = indexById[task.id];
      if (predecessor == null ||
          predecessorIndex == null ||
          taskIndex == null) {
        continue;
      }

      final start = _anchorForTask(
        task: predecessor,
        rowIndex: predecessorIndex,
        anchorEnd: true,
      );
      final end = _anchorForTask(
        task: task,
        rowIndex: taskIndex,
        anchorEnd: false,
      );
      if (start == null || end == null) continue;

      segments.add(
        _KyGanttDependencySegment(
          start: start,
          end: end,
          highlighted: _isSelectedDependency(
            predecessor.id,
            task.id,
            selectedDependencyEdges,
          ),
          conflicted: _isConflictedDependency(
            predecessor.id,
            task.id,
            conflictedDependencyEdges,
          ),
        ),
      );
    }

    for (final segment in segments.where(
      (segment) => !segment.highlighted && !segment.conflicted,
    )) {
      _drawDependency(canvas, segment);
    }

    for (final segment in segments.where(
      (segment) => segment.conflicted && !segment.highlighted,
    )) {
      _drawDependency(canvas, segment);
    }

    for (final segment in segments.where((segment) => segment.highlighted)) {
      _drawDependency(canvas, segment);
    }

    canvas.restore();
  }

  @visibleForTesting
  bool isDependencyHighlightedForTesting({
    required String predecessorId,
    required String taskId,
  }) {
    return _isSelectedDependency(
      predecessorId,
      taskId,
      focusedGanttDependencyEdges(
        tasks: tasks,
        selectedTaskId: selectedTaskId,
        enabled: highlightSelectedTask,
        focusScope: focusScope,
      ),
    );
  }

  @visibleForTesting
  bool isDependencyConflictedForTesting({
    required String predecessorId,
    required String taskId,
  }) {
    return _isConflictedDependency(
      predecessorId,
      taskId,
      highlightConflictedDependencies
          ? conflictedGanttDependencyEdges(tasks: tasks)
          : const <KyGanttDependencyEdge>{},
    );
  }

  bool _isSelectedDependency(
    String predecessorId,
    String taskId,
    Set<KyGanttDependencyEdge> selectedDependencyEdges,
  ) {
    final selectedId = selectedTaskId?.trim();
    if (!highlightSelectedTask || selectedId == null || selectedId.isEmpty) {
      return false;
    }

    return selectedDependencyEdges.contains(
      KyGanttDependencyEdge(predecessorId, taskId),
    );
  }

  bool _isConflictedDependency(
    String predecessorId,
    String taskId,
    Set<KyGanttDependencyEdge> conflictedDependencyEdges,
  ) {
    if (!highlightConflictedDependencies) return false;

    return conflictedDependencyEdges.contains(
      KyGanttDependencyEdge(predecessorId, taskId),
    );
  }

  void _drawDependency(Canvas canvas, _KyGanttDependencySegment segment) {
    final selectedId = selectedTaskId?.trim();
    final hasFocus =
        highlightSelectedTask && selectedId != null && selectedId.isNotEmpty;
    final isInactive = hasFocus && !segment.highlighted;
    final resolvedConflictColor = conflictColor ?? color;
    final resolvedColor = segment.conflicted
        ? resolvedConflictColor
        : segment.highlighted
            ? (highlightColor ?? color)
            : color;
    final opacity = segment.conflicted
        ? (segment.highlighted
            ? _maxOpacity(conflictLineOpacity, highlightLineOpacity)
            : conflictLineOpacity)
        : segment.highlighted
            ? highlightLineOpacity
            : isInactive
                ? inactiveLineOpacity
                : lineOpacity;
    final resolvedStrokeWidth = (segment.conflicted
            ? _maxStrokeWidth(
                conflictStrokeWidth,
                segment.highlighted ? highlightStrokeWidth : strokeWidth,
              )
            : segment.highlighted
                ? highlightStrokeWidth
                : strokeWidth)
        .clamp(0.5, 8)
        .toDouble();
    final elbow = (segment.start.dx + segment.end.dx) / 2;
    final path = Path()
      ..moveTo(segment.start.dx, segment.start.dy)
      ..cubicTo(
        elbow,
        segment.start.dy,
        elbow,
        segment.end.dy,
        segment.end.dx,
        segment.end.dy,
      );

    if (segment.highlighted || segment.conflicted) {
      final haloPaint = Paint()
        ..color = resolvedColor.withValues(
          alpha: _clampedOpacity(opacity * 0.18),
        )
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = resolvedStrokeWidth + 5;
      canvas.drawPath(path, haloPaint);
    }

    final paint = Paint()
      ..color = resolvedColor.withValues(alpha: _clampedOpacity(opacity))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = resolvedStrokeWidth;

    final arrowPaint = Paint()
      ..color = resolvedColor.withValues(
        alpha: _clampedOpacity(opacity + 0.1),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    _drawArrowHead(canvas, arrowPaint, segment.end);
  }

  Offset? _anchorForTask({
    required GanttTask task,
    required int rowIndex,
    required bool anchorEnd,
  }) {
    final rowCenter = rowIndex * rowHeight + rowHeight / 2;

    if (task.isMilestone) {
      final offsetDays = milestoneOffsetDaysForTask(
        task: task,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );
      if (offsetDays == null) return null;

      return Offset(offsetDays * dayWidth + dayWidth / 2, rowCenter);
    }

    final segment = visibleSegmentForTask(
      task: task,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
    if (segment == null) return null;

    final x = anchorEnd
        ? segment.left(dayWidth) + segment.width(dayWidth)
        : segment.left(dayWidth);
    return Offset(x, rowCenter);
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Offset end) {
    const arrowSize = 6.0;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize, end.dy - arrowSize / 2)
      ..lineTo(end.dx - arrowSize, end.dy + arrowSize / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  double _clampedOpacity(double opacity) => opacity.clamp(0, 1).toDouble();

  double _maxOpacity(double left, double right) {
    return left > right ? left : right;
  }

  double _maxStrokeWidth(double left, double right) {
    return left > right ? left : right;
  }

  @override
  bool shouldRepaint(KyGanttDependencyPainter oldDelegate) {
    return oldDelegate.tasks != tasks ||
        oldDelegate.rangeStart != rangeStart ||
        oldDelegate.rangeEnd != rangeEnd ||
        oldDelegate.dayWidth != dayWidth ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.color != color ||
        oldDelegate.selectedTaskId != selectedTaskId ||
        oldDelegate.highlightSelectedTask != highlightSelectedTask ||
        oldDelegate.highlightConflictedDependencies !=
            highlightConflictedDependencies ||
        oldDelegate.focusScope != focusScope ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.conflictColor != conflictColor ||
        oldDelegate.lineOpacity != lineOpacity ||
        oldDelegate.inactiveLineOpacity != inactiveLineOpacity ||
        oldDelegate.highlightLineOpacity != highlightLineOpacity ||
        oldDelegate.conflictLineOpacity != conflictLineOpacity ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.highlightStrokeWidth != highlightStrokeWidth ||
        oldDelegate.conflictStrokeWidth != conflictStrokeWidth;
  }
}

class _KyGanttDependencySegment {
  const _KyGanttDependencySegment({
    required this.start,
    required this.end,
    required this.highlighted,
    required this.conflicted,
  });

  final Offset start;
  final Offset end;
  final bool highlighted;
  final bool conflicted;
}
