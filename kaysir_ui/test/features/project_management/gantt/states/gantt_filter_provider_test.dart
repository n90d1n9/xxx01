import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';

void main() {
  test('operational gantt provider filters by search, project, and status', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      flattenGanttTaskTree(container.read(operationalGanttTasksProvider)),
      hasLength(7),
    );
    expect(container.read(ganttVisibleBranchTaskIdsProvider), {'1'});

    container.read(gantt.searchQueryProvider.notifier).state = 'requirements';
    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.title),
      ['Requirements Gathering'],
    );
    expect(container.read(ganttVisibleBranchTaskIdsProvider), isEmpty);

    container.read(gantt.searchQueryProvider.notifier).state = '';
    container.read(ganttProjectFilterProvider.notifier).state =
        'retail-modernization';
    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.id),
      ['1', '1.1', '1.2'],
    );
    expect(container.read(ganttVisibleBranchTaskIdsProvider), {'1'});

    container.read(ganttProjectFilterProvider.notifier).state = null;
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(operationalGanttTasksProvider)),
        '5',
      )?.kind,
      gantt.GanttTaskKind.milestone,
    );

    container.read(ganttTaskStatusFilterProvider.notifier).state =
        GanttTaskStatusFilter.complete;
    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.title),
      ['Requirements Gathering'],
    );
  });

  test('standalone task filtering preserves matching branches only', () {
    final tasks = [
      gantt.GanttTask(
        id: 'parent',
        title: 'Parent',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 3),
        progress: 0.5,
        subtasks: [
          gantt.GanttTask(
            id: 'child',
            title: 'Launch Checklist',
            startDate: DateTime(2026, 5, 2),
            endDate: DateTime(2026, 5, 2),
            progress: 1,
          ),
        ],
      ),
    ];

    final filtered = filterGanttTasks(tasks: tasks, query: 'launch');

    expect(flattenGanttTaskTree(filtered).map((task) => task.id), ['child']);
  });

  test('operational gantt provider scopes to a focused branch', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(ganttBranchFocusTaskIdProvider.notifier).state = '1';

    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.id),
      ['1', '1.1', '1.2'],
    );
    expect(container.read(ganttVisibleBranchTaskIdsProvider), {'1'});

    container.read(ganttBranchFocusTaskIdProvider.notifier).state = '1.1';

    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.id),
      ['1.1'],
    );
    expect(container.read(ganttVisibleBranchTaskIdsProvider), isEmpty);

    container.read(ganttBranchFocusTaskIdProvider.notifier).state = 'missing';

    expect(
      flattenGanttTaskTree(container.read(operationalGanttTasksProvider)),
      isEmpty,
    );
  });

  test('selected operational task provider resolves the visible task', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(gantt.selectedTaskProvider.notifier).state = '2';

    expect(
      container.read(selectedOperationalGanttTaskProvider)?.title,
      'Design Phase',
    );

    container.read(ganttTaskStatusFilterProvider.notifier).state =
        GanttTaskStatusFilter.complete;

    expect(container.read(selectedOperationalGanttTaskProvider), isNull);
  });

  test('task notifier updates milestone kind and date', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(gantt.tasksProvider.notifier);
    final originalTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;

    notifier.updateTaskKind('2', gantt.GanttTaskKind.milestone);

    final milestone =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(milestone.kind, gantt.GanttTaskKind.milestone);
    expect(milestone.startDate, DateUtils.dateOnly(originalTask.startDate));
    expect(milestone.endDate, DateUtils.dateOnly(originalTask.startDate));

    final movedDate = milestone.startDate.add(const Duration(days: 2));
    notifier.updateMilestoneDate('2', movedDate);

    final movedMilestone =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(movedMilestone.startDate, movedDate);
    expect(movedMilestone.endDate, movedDate);
  });

  test('task notifier updates dates with bounds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(gantt.tasksProvider.notifier);
    final originalTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    final originalEndDate = DateUtils.dateOnly(originalTask.endDate);

    final movedStartDate = DateUtils.dateOnly(
      originalTask.startDate.add(const Duration(days: 1)),
    );
    notifier.updateTaskStartDate('2', movedStartDate);
    var task =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(task.startDate, movedStartDate);
    expect(task.endDate, originalEndDate);

    final invalidStartDate = originalEndDate.add(const Duration(days: 3));
    notifier.updateTaskStartDate('2', invalidStartDate);
    task =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(task.startDate, invalidStartDate);
    expect(task.endDate, invalidStartDate);

    final invalidEndDate = invalidStartDate.subtract(const Duration(days: 2));
    notifier.updateTaskEndDate('2', invalidEndDate);
    task =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(task.startDate, invalidEndDate);
    expect(task.endDate, invalidEndDate);

    notifier.updateTaskKind('2', gantt.GanttTaskKind.milestone);
    final movedMilestoneDate = invalidEndDate.add(const Duration(days: 4));
    notifier.updateTaskStartDate('2', movedMilestoneDate);
    task =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(task.startDate, movedMilestoneDate);
    expect(task.endDate, movedMilestoneDate);
  });

  test('task notifier updates progress with bounds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(gantt.tasksProvider.notifier);

    notifier.updateTaskProgress('2', 0.75);
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '2',
      )?.progress,
      0.75,
    );

    notifier.updateTaskProgress('2', 1.4);
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '2',
      )?.progress,
      1,
    );

    notifier.updateTaskProgress('2', -0.2);
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '2',
      )?.progress,
      0,
    );
  });

  test('task notifier can undo the last task edit', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(gantt.tasksProvider.notifier);
    final originalTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;

    expect(notifier.canUndoTask('2'), false);

    notifier.updateTaskProgress('2', 0.75);
    expect(notifier.canUndoTask('2'), true);
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '2',
      )?.progress,
      0.75,
    );

    expect(notifier.undoLastTaskEdit(), true);
    final restoredTask =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    expect(restoredTask.progress, originalTask.progress);
    expect(restoredTask.dependsOn, originalTask.dependsOn);
    expect(notifier.canUndoTask('2'), false);
    expect(notifier.undoLastTaskEdit(), false);
  });

  test(
    'recent task edit provider records newest activity and caps history',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gantt.tasksProvider.notifier);

      expect(container.read(gantt.recentTaskEditsProvider), isEmpty);

      notifier.updateTaskProgress('2', 0.75);
      var edits = container.read(gantt.recentTaskEditsProvider);
      expect(edits, hasLength(1));
      expect(edits.first.taskId, '2');
      expect(edits.first.taskTitle, 'Design Phase');
      expect(edits.first.kind, gantt.GanttTaskEditKind.progress);
      expect(edits.first.label, 'Progress changed to 75%');

      notifier.updateTaskDependency('3', null);
      edits = container.read(gantt.recentTaskEditsProvider);
      expect(edits.first.taskId, '3');
      expect(edits.first.kind, gantt.GanttTaskEditKind.dependency);
      expect(edits.first.label, 'Removed predecessor');
      expect(edits[1].kind, gantt.GanttTaskEditKind.progress);

      expect(notifier.undoLastTaskEdit(), true);
      edits = container.read(gantt.recentTaskEditsProvider);
      expect(edits.first.taskId, '3');
      expect(edits.first.kind, gantt.GanttTaskEditKind.undo);
      expect(edits.first.label, 'Reverted last edit');

      for (var step = 1; step <= 7; step += 1) {
        notifier.updateTaskProgress('2', step / 10);
      }

      edits = container.read(gantt.recentTaskEditsProvider);
      expect(edits, hasLength(6));
      expect(edits.first.label, 'Progress changed to 70%');
      expect(edits.last.label, 'Progress changed to 20%');
    },
  );

  test('recent task edits are pruned when tasks are deleted', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(gantt.tasksProvider.notifier);

    notifier.updateTaskProgress('2', 0.75);
    notifier.updateTaskProgress('3', 0.4);

    expect(
      container
          .read(gantt.recentTaskEditsProvider)
          .map((activity) => activity.taskId),
      ['3', '2'],
    );
    expect(notifier.canUndoTask('3'), true);

    notifier.deleteTask('3');

    expect(
      container
          .read(gantt.recentTaskEditsProvider)
          .map((activity) => activity.taskId),
      ['2'],
    );
    expect(notifier.canUndoTask('3'), false);
    expect(notifier.undoLastTaskEdit(), false);

    notifier.updateTaskProgress('1.1', 0.5);
    expect(
      container
          .read(gantt.recentTaskEditsProvider)
          .map((activity) => activity.taskId),
      ['1.1', '2'],
    );

    notifier.deleteTask('1');

    expect(
      container
          .read(gantt.recentTaskEditsProvider)
          .map((activity) => activity.taskId),
      ['2'],
    );
  });

  test('task notifier updates and guards dependency links', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(gantt.tasksProvider.notifier);

    final taskTwoBefore =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '2',
        )!;
    notifier.updateTaskDependency('2', '5');
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '2',
      )?.dependsOn,
      taskTwoBefore.dependsOn,
    );

    notifier.updateTaskDependency('3', '1');
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '3',
      )?.dependsOn,
      '1',
    );

    notifier.updateTaskDependency('3', null);
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '3',
      )?.dependsOn,
      isNull,
    );

    final taskOneBefore =
        findGanttTaskById(
          flattenGanttTaskTree(container.read(gantt.tasksProvider)),
          '1',
        )!;
    notifier.updateTaskDependency('1', '1.1');
    expect(
      findGanttTaskById(
        flattenGanttTaskTree(container.read(gantt.tasksProvider)),
        '1',
      )?.dependsOn,
      taskOneBefore.dependsOn,
    );
  });

  test('timeline saved view provider filters operational tasks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(ganttTimelineViewProvider.notifier).state =
        GanttTimelineViewPreset.activeNow;

    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.id),
      ['1', '1.2'],
    );

    container.read(ganttTimelineViewProvider.notifier).state =
        GanttTimelineViewPreset.dependencyWatch;

    expect(
      flattenGanttTaskTree(
        container.read(operationalGanttTasksProvider),
      ).map((task) => task.id),
      ['2', '3', '4', '5'],
    );
  });
}
