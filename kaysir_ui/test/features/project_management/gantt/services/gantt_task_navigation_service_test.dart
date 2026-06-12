import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_navigation_service.dart';

void main() {
  const service = GanttTaskNavigationService();
  const actionService = GanttTaskNavigationActionService();

  group('GanttTaskNavigationService', () {
    test('builds previous and next navigation for nested visible tasks', () {
      final context = service.contextFor(
        selectedTask: _buildTask,
        visibleTasks: _visibleTasks,
        taskTitlesById: const {'design': 'Design Sprint', 'release': 'Launch'},
      );

      expect(context.positionLabel, '3 of 4 visible');
      expect(context.previousTaskId, 'design');
      expect(context.previousTaskTitle, 'Design Sprint');
      expect(context.nextTaskId, 'release');
      expect(context.nextTaskTitle, 'Launch');
    });

    test('handles first and last visible task boundaries', () {
      final firstContext = service.contextFor(
        selectedTask: _projectTask,
        visibleTasks: _visibleTasks,
      );
      final lastContext = service.contextFor(
        selectedTask: _releaseTask,
        visibleTasks: _visibleTasks,
      );

      expect(firstContext.positionLabel, '1 of 4 visible');
      expect(firstContext.previousTaskId, isNull);
      expect(firstContext.nextTaskId, 'design');
      expect(firstContext.nextTaskTitle, 'Design');

      expect(lastContext.positionLabel, '4 of 4 visible');
      expect(lastContext.previousTaskId, 'build');
      expect(lastContext.previousTaskTitle, 'Build');
      expect(lastContext.nextTaskId, isNull);
    });

    test('returns empty context when selected task is not visible', () {
      final context = service.contextFor(
        selectedTask: _hiddenTask,
        visibleTasks: _visibleTasks,
      );

      expect(context, same(GanttTaskNavigationContext.empty));
      expect(context.positionLabel, isNull);
      expect(context.previousTaskId, isNull);
      expect(context.nextTaskId, isNull);
    });

    test('returns empty context when no task is selected', () {
      final context = service.contextFor(
        selectedTask: null,
        visibleTasks: _visibleTasks,
      );

      expect(context, same(GanttTaskNavigationContext.empty));
    });

    test('builds callbacks for available previous and next tasks', () {
      final openedTaskIds = <String>[];
      final actions = actionService.actionsFor(
        context: const GanttTaskNavigationContext(
          positionLabel: '2 of 4 visible',
          previousTaskId: 'design',
          nextTaskId: 'release',
          previousTaskTitle: 'Design',
          nextTaskTitle: 'Release',
        ),
        onOpenTask: openedTaskIds.add,
      );

      actions.onPreviousTask!();
      actions.onNextTask!();

      expect(openedTaskIds, ['design', 'release']);
    });

    test('omits callbacks at task navigation boundaries', () {
      final firstActions = actionService.actionsFor(
        context: const GanttTaskNavigationContext(
          positionLabel: '1 of 4 visible',
          previousTaskId: null,
          nextTaskId: 'design',
          previousTaskTitle: null,
          nextTaskTitle: 'Design',
        ),
        onOpenTask: (_) {},
      );
      final emptyActions = actionService.actionsFor(
        context: GanttTaskNavigationContext.empty,
        onOpenTask: (_) {},
      );

      expect(firstActions.onPreviousTask, isNull);
      expect(firstActions.onNextTask, isNotNull);
      expect(emptyActions, same(GanttTaskNavigationActions.empty));
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

final _hiddenTask = gantt.GanttTask(
  id: 'hidden',
  title: 'Hidden',
  startDate: DateTime(2026, 2),
  endDate: DateTime(2026, 2, 5),
);

final _visibleTasks = [_projectTask, _releaseTask];
