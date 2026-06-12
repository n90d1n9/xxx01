import '../gantt_dashboard.dart' as gantt;

/// Result for deciding whether a recent schedule edit should be surfaced.
class GanttScheduleEditFeedbackIntentResult {
  const GanttScheduleEditFeedbackIntentResult({required this.activity});

  static const hidden = GanttScheduleEditFeedbackIntentResult(activity: null);

  final gantt.GanttTaskEditActivity? activity;

  bool get shouldShow => activity != null;
}

/// Centralizes snack-bar feedback rules for interactive schedule edits.
class GanttScheduleEditFeedbackIntentService {
  const GanttScheduleEditFeedbackIntentService();

  GanttScheduleEditFeedbackIntentResult feedbackAfterDateRangeEdit({
    required String taskId,
    required List<gantt.GanttTaskEditActivity> recentEditsBefore,
    required List<gantt.GanttTaskEditActivity> recentEditsAfter,
    required bool feedbackEnabled,
  }) {
    return feedbackForDateRangeEdit(
      taskId: taskId,
      previousLatestEdit: _latestEdit(recentEditsBefore),
      recentEdits: recentEditsAfter,
      feedbackEnabled: feedbackEnabled,
    );
  }

  GanttScheduleEditFeedbackIntentResult feedbackForDateRangeEdit({
    required String taskId,
    required gantt.GanttTaskEditActivity? previousLatestEdit,
    required List<gantt.GanttTaskEditActivity> recentEdits,
    required bool feedbackEnabled,
  }) {
    if (!feedbackEnabled) return GanttScheduleEditFeedbackIntentResult.hidden;

    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty || recentEdits.isEmpty) {
      return GanttScheduleEditFeedbackIntentResult.hidden;
    }

    final latestEdit = recentEdits.first;
    if (identical(latestEdit, previousLatestEdit)) {
      return GanttScheduleEditFeedbackIntentResult.hidden;
    }
    if (latestEdit.taskId != normalizedTaskId) {
      return GanttScheduleEditFeedbackIntentResult.hidden;
    }

    return GanttScheduleEditFeedbackIntentResult(activity: latestEdit);
  }

  gantt.GanttTaskEditActivity? _latestEdit(
    List<gantt.GanttTaskEditActivity> recentEdits,
  ) {
    return recentEdits.isEmpty ? null : recentEdits.first;
  }
}
