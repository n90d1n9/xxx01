import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_task_focus_intent_service.dart';

void main() {
  group('GanttChartTaskFocusIntentService', () {
    const service = GanttChartTaskFocusIntentService();
    const focusDispatcher = GanttChartTaskFocusIntentDispatcher();
    const dispatcher = GanttChartTaskSelectionIntentDispatcher();

    test('toggles collapsed task ids without mutating the original set', () {
      final collapsed = {'project'};

      final expanded = service.toggleCollapsedTask(
        collapsedTaskIds: collapsed,
        taskId: 'project',
      );
      final collapsedAgain = service.toggleCollapsedTask(
        collapsedTaskIds: expanded,
        taskId: 'build',
      );

      expect(collapsed, {'project'});
      expect(expanded, isEmpty);
      expect(collapsedAgain, {'build'});
    });

    test('focuses a branch and expands the focused task row', () {
      final result = service.focusBranch(
        taskId: ' project ',
        collapsedTaskIds: {'project', 'design'},
      );

      expect(result.branchFocusTaskId, 'project');
      expect(result.collapsedTaskIds, {'design'});
    });

    test('dispatches collapsed task ids through the tree callback', () {
      Set<String>? appliedCollapsedTaskIds;

      focusDispatcher.dispatchCollapsedTaskIds(
        collapsedTaskIds: const {'project', 'design'},
        onApplyCollapsedTaskIds:
            (collapsedTaskIds) => appliedCollapsedTaskIds = collapsedTaskIds,
      );

      expect(appliedCollapsedTaskIds, {'project', 'design'});
    });

    test('dispatches branch focus before tree expansion', () {
      final operations = <String>[];

      focusDispatcher.dispatchBranchFocus(
        intent: const GanttChartBranchFocusIntentResult(
          branchFocusTaskId: 'project',
          collapsedTaskIds: {'design'},
        ),
        onApplyBranchFocus: (taskId) => operations.add('branch-$taskId'),
        onApplyCollapsedTaskIds:
            (collapsedTaskIds) =>
                operations.add('collapsed-${collapsedTaskIds.join(',')}'),
      );

      expect(operations, ['branch-project', 'collapsed-design']);
    });

    test('reveal selected task ignores empty selections', () {
      expect(
        service.revealSelectedTask(null),
        same(GanttChartTaskSelectionIntentResult.ignored),
      );
      expect(
        service.revealSelectedTask('  '),
        same(GanttChartTaskSelectionIntentResult.ignored),
      );
    });

    test('reveal selected task asks caller to clear timeline focus', () {
      final result = service.revealSelectedTask(' build ');

      expect(result.selectedTaskId, 'build');
      expect(result.shouldClearTimelineFocus, isTrue);
    });

    test('selects visible recent edit task without clearing focus', () {
      final result = service.selectRecentEditTask(
        taskId: 'build',
        allTasks: _allTasks,
        visibleTasks: _visibleTasks,
      );

      expect(result.selectedTaskId, 'build');
      expect(result.shouldClearTimelineFocus, isFalse);
    });

    test('selects hidden recent edit task and asks caller to clear focus', () {
      final result = service.selectRecentEditTask(
        taskId: 'release',
        allTasks: _allTasks,
        visibleTasks: _visibleTasks,
      );

      expect(result.selectedTaskId, 'release');
      expect(result.shouldClearTimelineFocus, isTrue);
    });

    test('ignores recent edit task ids that no longer exist', () {
      final result = service.selectRecentEditTask(
        taskId: 'missing',
        allTasks: _allTasks,
        visibleTasks: _visibleTasks,
      );

      expect(result, same(GanttChartTaskSelectionIntentResult.ignored));
    });

    test('dispatches selection intents after clearing timeline focus', () {
      final operations = <String>[];

      final dispatched = dispatcher.dispatch(
        intent: const GanttChartTaskSelectionIntentResult(
          selectedTaskId: 'release',
          shouldClearTimelineFocus: true,
        ),
        onClearTimelineFocus: () => operations.add('clear-focus'),
        onSelectTask: (taskId) => operations.add('select-$taskId'),
      );

      expect(dispatched, isTrue);
      expect(operations, ['clear-focus', 'select-release']);
    });

    test('dispatches visible selection intents without clearing focus', () {
      final operations = <String>[];

      final dispatched = dispatcher.dispatch(
        intent: const GanttChartTaskSelectionIntentResult(
          selectedTaskId: 'build',
          shouldClearTimelineFocus: false,
        ),
        onClearTimelineFocus: () => operations.add('clear-focus'),
        onSelectTask: (taskId) => operations.add('select-$taskId'),
      );

      expect(dispatched, isTrue);
      expect(operations, ['select-build']);
    });

    test('ignores empty selection intent dispatches', () {
      final operations = <String>[];

      final dispatched = dispatcher.dispatch(
        intent: GanttChartTaskSelectionIntentResult.ignored,
        onClearTimelineFocus: () => operations.add('clear-focus'),
        onSelectTask: (taskId) => operations.add('select-$taskId'),
      );

      expect(dispatched, isFalse);
      expect(operations, isEmpty);
    });
  });
}

final _designTask = gantt.GanttTask(
  id: 'design',
  title: 'Design',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 1, 5),
);

final _buildTask = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 1, 6),
  endDate: DateTime(2026, 1, 12),
);

final _projectTask = gantt.GanttTask(
  id: 'project',
  title: 'Project',
  startDate: DateTime(2026, 1),
  endDate: DateTime(2026, 1, 20),
  subtasks: [_designTask, _buildTask],
);

final _releaseTask = gantt.GanttTask(
  id: 'release',
  title: 'Release',
  startDate: DateTime(2026, 1, 16),
  endDate: DateTime(2026, 1, 20),
);

final _allTasks = [_projectTask, _releaseTask];
final _visibleTasks = [_projectTask];
