import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_route_focus_intent_service.dart';

void main() {
  group('GanttChartRouteFocusIntentService', () {
    const service = GanttChartRouteFocusIntentService();
    const dispatcher = GanttChartRouteFocusIntentDispatcher();

    test('allows task-only focus when no project id is supplied', () {
      final result = service.projectFocusFor(
        projectId: '  ',
        availableProjectIds: const ['mobile-app'],
      );

      expect(result, same(GanttChartRouteProjectFocusIntentResult.taskOnly));
    });

    test('ignores unknown project ids and skips task selection', () {
      final result = service.projectFocusFor(
        projectId: 'missing-project',
        availableProjectIds: const ['mobile-app'],
      );

      expect(result, same(GanttChartRouteProjectFocusIntentResult.ignored));
    });

    test('normalizes valid project ids and resolves task selection', () {
      final result = service.projectFocusFor(
        projectId: ' mobile-app ',
        availableProjectIds: const ['mobile-app'],
      );

      expect(result.projectId, 'mobile-app');
      expect(result.shouldResolveTaskSelection, isTrue);
    });

    test('selects nested visible task ids from route state', () {
      final result = service.taskSelectionFor(
        taskId: ' build ',
        visibleTasks: _visibleTasks,
      );

      expect(result.selectedTaskId, 'build');
    });

    test('ignores missing or empty task ids', () {
      expect(
        service.taskSelectionFor(taskId: null, visibleTasks: _visibleTasks),
        same(GanttChartRouteTaskSelectionIntentResult.ignored),
      );
      expect(
        service.taskSelectionFor(taskId: ' ', visibleTasks: _visibleTasks),
        same(GanttChartRouteTaskSelectionIntentResult.ignored),
      );
      expect(
        service.taskSelectionFor(
          taskId: 'release',
          visibleTasks: _visibleTasks,
        ),
        same(GanttChartRouteTaskSelectionIntentResult.ignored),
      );
    });

    test('dispatches project focus before resolving task selection', () {
      final operations = <String>[];

      dispatcher.dispatchProjectFocus(
        intent: const GanttChartRouteProjectFocusIntentResult(
          projectId: 'mobile-app',
          shouldResolveTaskSelection: true,
        ),
        onApplyProjectFocus:
            (projectId) => operations.add('project-$projectId'),
        onResolveTaskSelection: () => operations.add('resolve-task'),
      );

      expect(operations, ['project-mobile-app', 'resolve-task']);
    });

    test('dispatches task-only focus without applying a project', () {
      final operations = <String>[];

      dispatcher.dispatchProjectFocus(
        intent: GanttChartRouteProjectFocusIntentResult.taskOnly,
        onApplyProjectFocus:
            (projectId) => operations.add('project-$projectId'),
        onResolveTaskSelection: () => operations.add('resolve-task'),
      );

      expect(operations, ['resolve-task']);
    });

    test('ignores project focus dispatches that were rejected', () {
      final operations = <String>[];

      dispatcher.dispatchProjectFocus(
        intent: GanttChartRouteProjectFocusIntentResult.ignored,
        onApplyProjectFocus:
            (projectId) => operations.add('project-$projectId'),
        onResolveTaskSelection: () => operations.add('resolve-task'),
      );

      expect(operations, isEmpty);
    });

    test('dispatches valid task selections and ignores empty selections', () {
      final selectedTaskIds = <String>[];

      final selected = dispatcher.dispatchTaskSelection(
        intent: const GanttChartRouteTaskSelectionIntentResult(
          selectedTaskId: 'build',
        ),
        onSelectTask: selectedTaskIds.add,
      );
      final ignored = dispatcher.dispatchTaskSelection(
        intent: GanttChartRouteTaskSelectionIntentResult.ignored,
        onSelectTask: selectedTaskIds.add,
      );

      expect(selected, isTrue);
      expect(ignored, isFalse);
      expect(selectedTaskIds, ['build']);
    });
  });
}

final _buildTask = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026),
  endDate: DateTime(2026, 1, 8),
);

final _projectTask = gantt.GanttTask(
  id: 'project',
  title: 'Project',
  startDate: DateTime(2026),
  endDate: DateTime(2026, 1, 10),
  subtasks: [_buildTask],
);

final _visibleTasks = [_projectTask];
