import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_edit_feedback_intent_service.dart';

void main() {
  group('GanttScheduleEditFeedbackIntentService', () {
    const service = GanttScheduleEditFeedbackIntentService();

    test('shows a fresh schedule edit for the moved task', () {
      final result = service.feedbackForDateRangeEdit(
        taskId: 'task-a',
        previousLatestEdit: _previousEdit,
        recentEdits: [_freshTaskEdit, _previousEdit],
        feedbackEnabled: true,
      );

      expect(result.shouldShow, isTrue);
      expect(result.activity, same(_freshTaskEdit));
    });

    test('shows a fresh edit by comparing before and after edit logs', () {
      final result = service.feedbackAfterDateRangeEdit(
        taskId: 'task-a',
        recentEditsBefore: [_previousEdit],
        recentEditsAfter: [_freshTaskEdit, _previousEdit],
        feedbackEnabled: true,
      );

      expect(result.shouldShow, isTrue);
      expect(result.activity, same(_freshTaskEdit));
    });

    test('hides after-edit feedback when the latest edit did not change', () {
      final result = service.feedbackAfterDateRangeEdit(
        taskId: 'task-a',
        recentEditsBefore: [_previousEdit],
        recentEditsAfter: [_previousEdit],
        feedbackEnabled: true,
      );

      expect(result, same(GanttScheduleEditFeedbackIntentResult.hidden));
    });

    test('hides feedback when the preference is disabled', () {
      final result = service.feedbackForDateRangeEdit(
        taskId: 'task-a',
        previousLatestEdit: _previousEdit,
        recentEdits: [_freshTaskEdit, _previousEdit],
        feedbackEnabled: false,
      );

      expect(result, same(GanttScheduleEditFeedbackIntentResult.hidden));
    });

    test('hides feedback when no new edit was recorded', () {
      final result = service.feedbackForDateRangeEdit(
        taskId: 'task-a',
        previousLatestEdit: _previousEdit,
        recentEdits: [_previousEdit],
        feedbackEnabled: true,
      );

      expect(result, same(GanttScheduleEditFeedbackIntentResult.hidden));
    });

    test('hides feedback when the latest edit belongs to another task', () {
      final result = service.feedbackForDateRangeEdit(
        taskId: 'task-a',
        previousLatestEdit: _previousEdit,
        recentEdits: [_otherTaskEdit, _previousEdit],
        feedbackEnabled: true,
      );

      expect(result, same(GanttScheduleEditFeedbackIntentResult.hidden));
    });

    test('hides feedback for empty task ids or empty edit logs', () {
      expect(
        service.feedbackForDateRangeEdit(
          taskId: ' ',
          previousLatestEdit: _previousEdit,
          recentEdits: [_freshTaskEdit],
          feedbackEnabled: true,
        ),
        same(GanttScheduleEditFeedbackIntentResult.hidden),
      );
      expect(
        service.feedbackForDateRangeEdit(
          taskId: 'task-a',
          previousLatestEdit: _previousEdit,
          recentEdits: const [],
          feedbackEnabled: true,
        ),
        same(GanttScheduleEditFeedbackIntentResult.hidden),
      );
    });
  });
}

final _previousEdit = gantt.GanttTaskEditActivity(
  taskId: 'task-a',
  taskTitle: 'Task A',
  kind: gantt.GanttTaskEditKind.startDate,
  label: 'Start date changed',
  timestamp: DateTime(2026),
);

final _freshTaskEdit = gantt.GanttTaskEditActivity(
  taskId: 'task-a',
  taskTitle: 'Task A',
  kind: gantt.GanttTaskEditKind.endDate,
  label: 'Finish resized +2d',
  timestamp: DateTime(2026, 1, 2),
);

final _otherTaskEdit = gantt.GanttTaskEditActivity(
  taskId: 'task-b',
  taskTitle: 'Task B',
  kind: gantt.GanttTaskEditKind.startDate,
  label: 'Schedule moved +2d',
  timestamp: DateTime(2026, 1, 3),
);
