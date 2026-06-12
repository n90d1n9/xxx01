import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_date_range_edit_service.dart';

void main() {
  group('GanttTaskDateRangeEditService', () {
    const service = GanttTaskDateRangeEditService();

    test(
      'applies date range edits and returns the fresh feedback activity',
      () {
        final tasksNotifier = gantt.TasksNotifier();
        final task = tasksNotifier.state.first;
        final nextStartDate = task.startDate.add(const Duration(days: 2));
        final nextEndDate = task.endDate.add(const Duration(days: 2));

        final result = service.applyDateRangeEdit(
          tasksNotifier: tasksNotifier,
          task: task,
          startDate: nextStartDate,
          endDate: nextEndDate,
          feedbackEnabled: true,
        );

        final updatedTask = tasksNotifier.state.first;
        expect(updatedTask.startDate, nextStartDate);
        expect(updatedTask.endDate, nextEndDate);
        expect(result.shouldShowFeedback, isTrue);
        expect(result.feedbackActivity, same(tasksNotifier.recentEdits.first));
        expect(result.feedbackActivity?.label, 'Schedule moved +2d');
      },
    );

    test('records the edit but suppresses feedback when disabled', () {
      final tasksNotifier = gantt.TasksNotifier();
      final task = tasksNotifier.state.first;

      final result = service.applyDateRangeEdit(
        tasksNotifier: tasksNotifier,
        task: task,
        startDate: task.startDate.add(const Duration(days: 1)),
        endDate: task.endDate.add(const Duration(days: 1)),
        feedbackEnabled: false,
      );

      expect(result.shouldShowFeedback, isFalse);
      expect(result.feedbackActivity, isNull);
      expect(tasksNotifier.recentEdits.single.label, 'Schedule moved +1d');
    });
  });
}
