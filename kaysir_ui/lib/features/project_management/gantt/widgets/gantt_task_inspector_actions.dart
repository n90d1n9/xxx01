import 'package:flutter/foundation.dart';

import '../gantt_dashboard.dart' as gantt;

/// Callback bundle for every action exposed by the Gantt task inspector.
class GanttTaskInspectorActions {
  const GanttTaskInspectorActions({
    required this.onDismiss,
    required this.onClearSelection,
    this.onPreviousTask,
    this.onNextTask,
    this.onFocusBranch,
    this.onOpenProject,
    this.onUndoLastEdit,
    this.onTaskKindChanged,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.onMilestoneDateChanged,
    this.onDependencyChanged,
    this.onProgressChanged,
    this.onTaskSelected,
    this.onRecentEditSelected,
  });

  /// Builds an action bundle from individual callbacks used by inspector APIs.
  factory GanttTaskInspectorActions.fromCallbacks({
    required VoidCallback onClearSelection,
    VoidCallback? onDismiss,
    VoidCallback? onPreviousTask,
    VoidCallback? onNextTask,
    VoidCallback? onFocusBranch,
    VoidCallback? onOpenProject,
    VoidCallback? onUndoLastEdit,
    ValueChanged<gantt.GanttTaskKind>? onTaskKindChanged,
    ValueChanged<DateTime>? onStartDateChanged,
    ValueChanged<DateTime>? onEndDateChanged,
    ValueChanged<DateTime>? onMilestoneDateChanged,
    ValueChanged<String?>? onDependencyChanged,
    ValueChanged<double>? onProgressChanged,
    ValueChanged<String>? onTaskSelected,
    ValueChanged<gantt.GanttTaskEditActivity>? onRecentEditSelected,
  }) {
    return GanttTaskInspectorActions(
      onDismiss: onDismiss ?? onClearSelection,
      onClearSelection: onClearSelection,
      onPreviousTask: onPreviousTask,
      onNextTask: onNextTask,
      onFocusBranch: onFocusBranch,
      onOpenProject: onOpenProject,
      onUndoLastEdit: onUndoLastEdit,
      onTaskKindChanged: onTaskKindChanged,
      onStartDateChanged: onStartDateChanged,
      onEndDateChanged: onEndDateChanged,
      onMilestoneDateChanged: onMilestoneDateChanged,
      onDependencyChanged: onDependencyChanged,
      onProgressChanged: onProgressChanged,
      onTaskSelected: onTaskSelected,
      onRecentEditSelected: onRecentEditSelected,
    );
  }

  /// Resolves a supplied action bundle or builds one from legacy callbacks.
  factory GanttTaskInspectorActions.resolve({
    GanttTaskInspectorActions? actions,
    VoidCallback? onClearSelection,
    VoidCallback? onDismiss,
    VoidCallback? onPreviousTask,
    VoidCallback? onNextTask,
    VoidCallback? onFocusBranch,
    VoidCallback? onOpenProject,
    VoidCallback? onUndoLastEdit,
    ValueChanged<gantt.GanttTaskKind>? onTaskKindChanged,
    ValueChanged<DateTime>? onStartDateChanged,
    ValueChanged<DateTime>? onEndDateChanged,
    ValueChanged<DateTime>? onMilestoneDateChanged,
    ValueChanged<String?>? onDependencyChanged,
    ValueChanged<double>? onProgressChanged,
    ValueChanged<String>? onTaskSelected,
    ValueChanged<gantt.GanttTaskEditActivity>? onRecentEditSelected,
  }) {
    final providedActions = actions;
    if (providedActions != null) return providedActions;

    assert(onClearSelection != null, 'Provide actions or onClearSelection.');

    return GanttTaskInspectorActions.fromCallbacks(
      onClearSelection: onClearSelection ?? () {},
      onDismiss: onDismiss,
      onPreviousTask: onPreviousTask,
      onNextTask: onNextTask,
      onFocusBranch: onFocusBranch,
      onOpenProject: onOpenProject,
      onUndoLastEdit: onUndoLastEdit,
      onTaskKindChanged: onTaskKindChanged,
      onStartDateChanged: onStartDateChanged,
      onEndDateChanged: onEndDateChanged,
      onMilestoneDateChanged: onMilestoneDateChanged,
      onDependencyChanged: onDependencyChanged,
      onProgressChanged: onProgressChanged,
      onTaskSelected: onTaskSelected,
      onRecentEditSelected: onRecentEditSelected,
    );
  }

  final VoidCallback onDismiss;
  final VoidCallback onClearSelection;
  final VoidCallback? onPreviousTask;
  final VoidCallback? onNextTask;
  final VoidCallback? onFocusBranch;
  final VoidCallback? onOpenProject;
  final VoidCallback? onUndoLastEdit;
  final ValueChanged<gantt.GanttTaskKind>? onTaskKindChanged;
  final ValueChanged<DateTime>? onStartDateChanged;
  final ValueChanged<DateTime>? onEndDateChanged;
  final ValueChanged<DateTime>? onMilestoneDateChanged;
  final ValueChanged<String?>? onDependencyChanged;
  final ValueChanged<double>? onProgressChanged;
  final ValueChanged<String>? onTaskSelected;
  final ValueChanged<gantt.GanttTaskEditActivity>? onRecentEditSelected;
}
