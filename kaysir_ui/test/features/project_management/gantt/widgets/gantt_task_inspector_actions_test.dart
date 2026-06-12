import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_actions.dart';

void main() {
  group('GanttTaskInspectorActions', () {
    test('resolves an existing action bundle without rebuilding it', () {
      final actions = GanttTaskInspectorActions(
        onDismiss: () {},
        onClearSelection: () {},
      );

      expect(
        GanttTaskInspectorActions.resolve(actions: actions),
        same(actions),
      );
    });

    test('guards legacy resolution without a clear selection callback', () {
      expect(GanttTaskInspectorActions.resolve, throwsA(isA<AssertionError>()));
    });

    test(
      'maps dismiss to clear selection when no dismiss callback is supplied',
      () {
        var clearCount = 0;

        final actions = GanttTaskInspectorActions.fromCallbacks(
          onClearSelection: () => clearCount++,
        );

        actions.onDismiss();
        actions.onClearSelection();

        expect(clearCount, 2);
        expect(actions.onPreviousTask, isNull);
        expect(actions.onNextTask, isNull);
      },
    );

    test('keeps dismiss separate when explicitly supplied', () {
      var dismissCount = 0;
      var clearCount = 0;

      final actions = GanttTaskInspectorActions.fromCallbacks(
        onDismiss: () => dismissCount++,
        onClearSelection: () => clearCount++,
      );

      actions.onDismiss();
      actions.onClearSelection();

      expect(dismissCount, 1);
      expect(clearCount, 1);
    });

    test('preserves edit, relationship, and navigation callbacks', () {
      gantt.GanttTaskKind? selectedKind;
      DateTime? selectedStartDate;
      String? selectedDependencyId;
      double? selectedProgress;
      String? selectedTaskId;
      gantt.GanttTaskEditActivity? selectedActivity;
      var previousCount = 0;
      var focusBranchCount = 0;

      final activity = gantt.GanttTaskEditActivity(
        taskId: 'build',
        taskTitle: 'Build',
        kind: gantt.GanttTaskEditKind.progress,
        label: 'Progress changed',
        timestamp: DateTime(2026),
      );
      final actions = GanttTaskInspectorActions.fromCallbacks(
        onClearSelection: () {},
        onPreviousTask: () => previousCount++,
        onFocusBranch: () => focusBranchCount++,
        onTaskKindChanged: (kind) => selectedKind = kind,
        onStartDateChanged: (date) => selectedStartDate = date,
        onDependencyChanged: (dependencyId) {
          selectedDependencyId = dependencyId;
        },
        onProgressChanged: (progress) => selectedProgress = progress,
        onTaskSelected: (taskId) => selectedTaskId = taskId,
        onRecentEditSelected: (activity) => selectedActivity = activity,
      );

      actions.onPreviousTask!();
      actions.onFocusBranch!();
      actions.onTaskKindChanged!(gantt.GanttTaskKind.milestone);
      actions.onStartDateChanged!(DateTime(2026, 5, 4));
      actions.onDependencyChanged!('plan');
      actions.onProgressChanged!(0.7);
      actions.onTaskSelected!('release');
      actions.onRecentEditSelected!(activity);

      expect(previousCount, 1);
      expect(focusBranchCount, 1);
      expect(selectedKind, gantt.GanttTaskKind.milestone);
      expect(selectedStartDate, DateTime(2026, 5, 4));
      expect(selectedDependencyId, 'plan');
      expect(selectedProgress, 0.7);
      expect(selectedTaskId, 'release');
      expect(selectedActivity, same(activity));
    });
  });
}
