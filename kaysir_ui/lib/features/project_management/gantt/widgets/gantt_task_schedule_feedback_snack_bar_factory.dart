import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;
import 'gantt_task_schedule_guard_feedback.dart';
import 'gantt_task_schedule_feedback.dart';

/// Builds snackbars that surface recent Gantt task schedule edit feedback.
class GanttTaskScheduleFeedbackSnackBarFactory {
  const GanttTaskScheduleFeedbackSnackBarFactory();

  SnackBar snackBarFor({
    required gantt.GanttTaskEditActivity activity,
    required VoidCallback onUndo,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: GanttTaskScheduleFeedback(activity: activity),
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    );
  }

  SnackBar rejectedSnackBarFor({
    required gantt.GanttTask task,
    required ky.KyGanttTaskDateRangeValidation validation,
    required VoidCallback onReview,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: GanttTaskScheduleGuardFeedback(
        task: task,
        validation: validation,
      ),
      action: SnackBarAction(label: 'Review', onPressed: onReview),
    );
  }
}
