import 'package:flutter/foundation.dart';

/// Action bundle for full-screen Gantt keyboard and shell-level commands.
@immutable
class GanttChartScreenActions {
  const GanttChartScreenActions({
    required this.onDismiss,
    required this.onSearch,
    this.onToggleControls,
    this.onOpenSettings,
    this.onClearFilters,
    this.onUndo,
    this.onPreviousTask,
    this.onNextTask,
  });

  static const disabled = GanttChartScreenActions(
    onDismiss: _noop,
    onSearch: _noop,
  );

  final VoidCallback onDismiss;
  final VoidCallback onSearch;
  final VoidCallback? onToggleControls;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onClearFilters;
  final VoidCallback? onUndo;
  final VoidCallback? onPreviousTask;
  final VoidCallback? onNextTask;
}

void _noop() {}
