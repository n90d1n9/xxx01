import 'package:flutter/widgets.dart';

import 'gantt_task.dart';

/// Called after a task date range is successfully committed by interaction.
typedef KyGanttTaskDateRangeChanged = void Function(
    GanttTask task, DateTime startDate, DateTime endDate);

/// Called when a task date range interaction is rejected by validation.
typedef KyGanttTaskDateRangeChangeRejected = void Function(
  GanttTask task,
  DateTime startDate,
  DateTime endDate,
  KyGanttTaskDateRangeValidation validation,
);

/// Builds the floating drag preview shown during task bar interactions.
typedef KyGanttTaskDragPreviewBuilder = Widget Function(
    BuildContext context, KyGanttTaskDragPreview preview);

/// Validates an interactive task date range before it can be committed.
typedef KyGanttTaskDateRangeValidator = KyGanttTaskDateRangeValidation Function(
    GanttTask task, DateTime startDate, DateTime endDate);

/// Snap behavior for interactive Gantt task bar movement and resizing.
enum KyGanttTaskDragSnap { day, week }

/// Visibility policy for task bar resize handles.
enum KyGanttTaskResizeHandleVisibility { always, focused }

/// Interaction mode represented by a task range preview.
enum KyGanttTaskRangePreviewAction { move, resizeStart, resizeEnd }

/// Severity emitted by a task date range validator.
enum KyGanttTaskDateRangeValidationSeverity { valid, warning, error }

/// Validation result for an interactive task date range edit.
class KyGanttTaskDateRangeValidation {
  const KyGanttTaskDateRangeValidation({
    required this.severity,
    this.message,
    this.canCommit = true,
  });

  const KyGanttTaskDateRangeValidation.valid()
      : severity = KyGanttTaskDateRangeValidationSeverity.valid,
        message = null,
        canCommit = true;

  const KyGanttTaskDateRangeValidation.warning(this.message)
      : severity = KyGanttTaskDateRangeValidationSeverity.warning,
        canCommit = true;

  const KyGanttTaskDateRangeValidation.blocked(this.message)
      : severity = KyGanttTaskDateRangeValidationSeverity.error,
        canCommit = false;

  final KyGanttTaskDateRangeValidationSeverity severity;
  final String? message;
  final bool canCommit;

  bool get isValid => severity == KyGanttTaskDateRangeValidationSeverity.valid;
  bool get isBlocking => !canCommit;
}

/// Snapshot of the task range currently being previewed during interaction.
class KyGanttTaskDragPreview {
  const KyGanttTaskDragPreview({
    required this.task,
    required this.startDate,
    required this.endDate,
    required this.deltaDays,
    this.action = KyGanttTaskRangePreviewAction.move,
    this.snap = KyGanttTaskDragSnap.day,
    this.validation = const KyGanttTaskDateRangeValidation.valid(),
  });

  final GanttTask task;
  final DateTime startDate;
  final DateTime endDate;
  final int deltaDays;
  final KyGanttTaskRangePreviewAction action;
  final KyGanttTaskDragSnap snap;
  final KyGanttTaskDateRangeValidation validation;

  String get actionLabel {
    switch (action) {
      case KyGanttTaskRangePreviewAction.move:
        return 'Move';
      case KyGanttTaskRangePreviewAction.resizeStart:
        return 'Start';
      case KyGanttTaskRangePreviewAction.resizeEnd:
        return 'Finish';
    }
  }

  String get deltaLabel {
    if (deltaDays == 0) return 'No change';
    if (deltaDays > 0) return '+${deltaDays}d';
    return '${deltaDays}d';
  }

  int get durationDays {
    final normalizedStart = _dateOnly(startDate);
    final normalizedEnd = _dateOnly(endDate);
    return normalizedEnd.difference(normalizedStart).inDays.abs() + 1;
  }

  String get durationLabel {
    final days = durationDays;
    if (days == 1) return '1d';
    if (days % 7 == 0) {
      final weeks = days ~/ 7;
      return weeks == 1 ? '1w' : '${weeks}w';
    }

    return '${days}d';
  }

  String get snapLabel {
    switch (snap) {
      case KyGanttTaskDragSnap.day:
        return 'Day snap';
      case KyGanttTaskDragSnap.week:
        return 'Week snap';
    }
  }

  KyGanttTaskDragPreview copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? deltaDays,
    KyGanttTaskRangePreviewAction? action,
    KyGanttTaskDragSnap? snap,
    KyGanttTaskDateRangeValidation? validation,
  }) {
    return KyGanttTaskDragPreview(
      task: task,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deltaDays: deltaDays ?? this.deltaDays,
      action: action ?? this.action,
      snap: snap ?? this.snap,
      validation: validation ?? this.validation,
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Runtime configuration for interactive taskbar editing affordances.
class KyGanttChartInteractionOptions {
  const KyGanttChartInteractionOptions({
    this.enableTaskBarDrag = false,
    this.enableTaskBarResize = false,
    this.dragSnap = KyGanttTaskDragSnap.day,
    this.showTaskBarDragPreview = true,
    this.showTaskBarDragGuides = true,
    this.showTaskBarDragGuideLabels = true,
    this.showTaskBarDragValidationBadge = true,
    this.showTaskBarDropTarget = true,
    this.showTaskBarBlockedDropPattern = true,
    this.showTaskBarInteractionLift = true,
    this.showTaskBarInteractionGhost = true,
    this.showTaskBarHoverFocusRing = true,
    this.showTaskBarDragHandle = true,
    this.taskBarInteractionFeedback =
        const KyGanttTaskBarInteractionFeedbackOptions(),
    this.resizeHandleVisibility = KyGanttTaskResizeHandleVisibility.always,
    this.taskBarResizeHandleWidth = 12,
  });

  final bool enableTaskBarDrag;
  final bool enableTaskBarResize;
  final KyGanttTaskDragSnap dragSnap;
  final bool showTaskBarDragPreview;
  final bool showTaskBarDragGuides;
  final bool showTaskBarDragGuideLabels;
  final bool showTaskBarDragValidationBadge;
  final bool showTaskBarDropTarget;
  final bool showTaskBarBlockedDropPattern;
  final bool showTaskBarInteractionLift;
  final bool showTaskBarInteractionGhost;
  final bool showTaskBarHoverFocusRing;
  final bool showTaskBarDragHandle;
  final KyGanttTaskBarInteractionFeedbackOptions taskBarInteractionFeedback;
  final KyGanttTaskResizeHandleVisibility resizeHandleVisibility;
  final double taskBarResizeHandleWidth;

  KyGanttChartInteractionOptions copyWith({
    bool? enableTaskBarDrag,
    bool? enableTaskBarResize,
    KyGanttTaskDragSnap? dragSnap,
    bool? showTaskBarDragPreview,
    bool? showTaskBarDragGuides,
    bool? showTaskBarDragGuideLabels,
    bool? showTaskBarDragValidationBadge,
    bool? showTaskBarDropTarget,
    bool? showTaskBarBlockedDropPattern,
    bool? showTaskBarInteractionLift,
    bool? showTaskBarInteractionGhost,
    bool? showTaskBarHoverFocusRing,
    bool? showTaskBarDragHandle,
    KyGanttTaskBarInteractionFeedbackOptions? taskBarInteractionFeedback,
    KyGanttTaskResizeHandleVisibility? resizeHandleVisibility,
    double? taskBarResizeHandleWidth,
  }) {
    return KyGanttChartInteractionOptions(
      enableTaskBarDrag: enableTaskBarDrag ?? this.enableTaskBarDrag,
      enableTaskBarResize: enableTaskBarResize ?? this.enableTaskBarResize,
      dragSnap: dragSnap ?? this.dragSnap,
      showTaskBarDragPreview:
          showTaskBarDragPreview ?? this.showTaskBarDragPreview,
      showTaskBarDragGuides:
          showTaskBarDragGuides ?? this.showTaskBarDragGuides,
      showTaskBarDragGuideLabels:
          showTaskBarDragGuideLabels ?? this.showTaskBarDragGuideLabels,
      showTaskBarDragValidationBadge:
          showTaskBarDragValidationBadge ?? this.showTaskBarDragValidationBadge,
      showTaskBarDropTarget:
          showTaskBarDropTarget ?? this.showTaskBarDropTarget,
      showTaskBarBlockedDropPattern:
          showTaskBarBlockedDropPattern ?? this.showTaskBarBlockedDropPattern,
      showTaskBarInteractionLift:
          showTaskBarInteractionLift ?? this.showTaskBarInteractionLift,
      showTaskBarInteractionGhost:
          showTaskBarInteractionGhost ?? this.showTaskBarInteractionGhost,
      showTaskBarHoverFocusRing:
          showTaskBarHoverFocusRing ?? this.showTaskBarHoverFocusRing,
      showTaskBarDragHandle:
          showTaskBarDragHandle ?? this.showTaskBarDragHandle,
      taskBarInteractionFeedback:
          taskBarInteractionFeedback ?? this.taskBarInteractionFeedback,
      resizeHandleVisibility:
          resizeHandleVisibility ?? this.resizeHandleVisibility,
      taskBarResizeHandleWidth:
          taskBarResizeHandleWidth ?? this.taskBarResizeHandleWidth,
    );
  }
}

/// Visual depth multipliers applied to taskbar interaction feedback.
class KyGanttTaskBarInteractionFeedbackOptions {
  const KyGanttTaskBarInteractionFeedbackOptions({
    this.opacityScale = 1,
    this.blurScale = 1,
    this.offsetScale = 1,
  });

  final double opacityScale;
  final double blurScale;
  final double offsetScale;

  KyGanttTaskBarInteractionFeedbackOptions copyWith({
    double? opacityScale,
    double? blurScale,
    double? offsetScale,
  }) {
    return KyGanttTaskBarInteractionFeedbackOptions(
      opacityScale: opacityScale ?? this.opacityScale,
      blurScale: blurScale ?? this.blurScale,
      offsetScale: offsetScale ?? this.offsetScale,
    );
  }
}
