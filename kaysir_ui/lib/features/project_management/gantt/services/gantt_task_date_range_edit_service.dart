import '../gantt_dashboard.dart' as gantt;
import 'gantt_schedule_edit_feedback_intent_service.dart';

/// Result of applying an interactive task date-range edit.
class GanttTaskDateRangeEditResult {
  const GanttTaskDateRangeEditResult({required this.feedbackActivity});

  final gantt.GanttTaskEditActivity? feedbackActivity;

  bool get shouldShowFeedback => feedbackActivity != null;
}

/// Coordinates task date-range mutations with schedule edit feedback rules.
class GanttTaskDateRangeEditService {
  const GanttTaskDateRangeEditService({
    this.feedbackIntentService = const GanttScheduleEditFeedbackIntentService(),
  });

  final GanttScheduleEditFeedbackIntentService feedbackIntentService;

  GanttTaskDateRangeEditResult applyDateRangeEdit({
    required gantt.TasksNotifier tasksNotifier,
    required gantt.GanttTask task,
    required DateTime startDate,
    required DateTime endDate,
    required bool feedbackEnabled,
  }) {
    final recentEditsBefore = tasksNotifier.recentEdits;

    tasksNotifier.updateTaskDateRange(
      task.id,
      startDate: startDate,
      endDate: endDate,
    );

    final feedback = feedbackIntentService.feedbackAfterDateRangeEdit(
      taskId: task.id,
      recentEditsBefore: recentEditsBefore,
      recentEditsAfter: tasksNotifier.recentEdits,
      feedbackEnabled: feedbackEnabled,
    );

    return GanttTaskDateRangeEditResult(feedbackActivity: feedback.activity);
  }
}
