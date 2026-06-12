import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_scrumboard/ky_scrumboard.dart';
import 'package:ky_scrumboard/src/presentation/board_action_feedback.dart';
import 'package:ky_scrumboard/src/presentation/board_snack_bar_presenter.dart';
import 'package:ky_scrumboard/src/presentation/board_task_deletion_planner.dart';
import 'package:ky_scrumboard/src/presentation/board_task_detail_action_dispatcher.dart';
import 'package:ky_scrumboard/src/presentation/board_task_move_outcome.dart';
import 'package:ky_scrumboard/src/widgets/activity_filter_controls.dart';
import 'package:ky_scrumboard/src/widgets/activity_feed_row.dart';
import 'package:ky_scrumboard/src/widgets/board_lane_collection.dart';
import 'package:ky_scrumboard/src/widgets/board_lane_header_metrics.dart';
import 'package:ky_scrumboard/src/widgets/board_lane_surface.dart';
import 'package:ky_scrumboard/src/widgets/board_lane_task_list.dart';
import 'package:ky_scrumboard/src/widgets/bulk_action_buttons.dart';
import 'package:ky_scrumboard/src/widgets/bulk_selection_summary.dart';
import 'package:ky_scrumboard/src/widgets/move_preview_blocked_list.dart';
import 'package:ky_scrumboard/src/widgets/move_preview_summary.dart';
import 'package:ky_scrumboard/src/widgets/scrum_board_column.dart';
import 'package:ky_scrumboard/src/widgets/scrum_board_filter_controls.dart';
import 'package:ky_scrumboard/src/widgets/scrum_board_insights_panel.dart';
import 'package:ky_scrumboard/src/widgets/scrum_board_toolbar.dart';
import 'package:ky_scrumboard/src/widgets/scrum_board_viewport.dart';
import 'package:ky_scrumboard/src/widgets/scrum_task_card.dart';
import 'package:ky_scrumboard/src/widgets/scrum_task_detail_common.dart';
import 'package:ky_scrumboard/src/widgets/scrum_task_detail_dialog.dart';
import 'package:ky_scrumboard/src/widgets/scrum_task_editor_dialog.dart';
import 'package:ky_scrumboard/src/widgets/task_detail_action_menus.dart';
import 'package:ky_scrumboard/src/widgets/task_detail_metadata_section.dart';
import 'package:ky_scrumboard/src/widgets/task_detail_panel_shell.dart';
import 'package:ky_scrumboard/src/widgets/task_detail_summary_section.dart';

void main() {
  group('ScrumBoardController', () {
    final defaultCreatedAt = DateTime(2026, 1, 1);

    ScrumTask task({
      required String id,
      required ScrumTaskStatus status,
      DateTime? createdAt,
      int points = 3,
      String assignee = 'Team',
      ScrumTaskPriority priority = ScrumTaskPriority.medium,
      DateTime? dueAt,
      int sortOrder = 0,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: assignee,
        storyPoints: points,
        createdAt: createdAt ?? defaultCreatedAt,
        dueAt: dueAt,
        status: status,
        sortOrder: sortOrder,
        priority: priority,
        accentColor: Colors.blue,
      );
    }

    test('summarizes task volume and points', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.todo, points: 2),
          task(id: 'b', status: ScrumTaskStatus.inProgress, points: 5),
          task(id: 'c', status: ScrumTaskStatus.done, points: 3),
        ],
      );

      final summary = controller.summary;

      expect(summary.totalTasks, 3);
      expect(summary.completedTasks, 1);
      expect(summary.completedStoryPoints, 3);
      expect(summary.activeStoryPoints, 7);
      expect(summary.completionRate, closeTo(1 / 3, 0.001));
      expect(summary.storyPointCompletionRate, closeTo(0.3, 0.001));
    });

    test('calculates sprint date progress', () {
      final sprint = ScrumSprint(
        id: 'sprint-1',
        name: 'Sprint 1',
        goal: 'Ship the board foundation',
        startAt: DateTime(2026, 1, 1),
        endAt: DateTime(2026, 1, 10),
      );

      expect(sprint.durationDays, 10);
      expect(sprint.daysElapsedAt(DateTime(2026, 1, 5)), 5);
      expect(sprint.daysRemainingAt(DateTime(2026, 1, 5)), 6);
      expect(sprint.timeProgressAt(DateTime(2026, 1, 5)), closeTo(.5, .001));
      expect(sprint.isActiveAt(DateTime(2026, 1, 5)), isTrue);
    });

    test('moves tasks between columns', () {
      final controller = ScrumBoardController(
        initialTasks: [task(id: 'a', status: ScrumTaskStatus.todo)],
      );

      final moved = controller.moveTask('a', ScrumTaskStatus.review);

      expect(moved, isTrue);
      expect(controller.taskById('a')?.status, ScrumTaskStatus.review);
      expect(controller.countFor(ScrumTaskStatus.todo), 0);
      expect(controller.countFor(ScrumTaskStatus.review), 1);
    });

    test('orders tasks by lane sort order', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'later', status: ScrumTaskStatus.todo, sortOrder: 2000),
          task(id: 'first', status: ScrumTaskStatus.todo, sortOrder: 1000),
        ],
      );

      expect(controller.tasksFor(ScrumTaskStatus.todo).map((task) => task.id), [
        'first',
        'later',
      ]);
    });

    test('places tasks before another task in the same lane', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.todo),
          task(id: 'b', status: ScrumTaskStatus.todo),
          task(id: 'c', status: ScrumTaskStatus.todo),
        ],
      );

      final placed = controller.placeTask(
        'c',
        ScrumTaskStatus.todo,
        beforeTaskId: 'a',
      );

      expect(placed, isTrue);
      expect(controller.tasksFor(ScrumTaskStatus.todo).map((task) => task.id), [
        'c',
        'a',
        'b',
      ]);
    });

    test('places tasks into another lane at a specific position', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'todo', status: ScrumTaskStatus.todo),
          task(id: 'review-a', status: ScrumTaskStatus.review),
          task(id: 'review-b', status: ScrumTaskStatus.review),
        ],
      );

      final placed = controller.placeTask(
        'todo',
        ScrumTaskStatus.review,
        beforeTaskId: 'review-b',
      );

      expect(placed, isTrue);
      expect(controller.countFor(ScrumTaskStatus.todo), 0);
      expect(
        controller.tasksFor(ScrumTaskStatus.review).map((task) => task.id),
        ['review-a', 'todo', 'review-b'],
      );
    });

    test('allows WIP overage when policy is advisory', () {
      final controller = ScrumBoardController(
        policy: const ScrumWorkflowPolicy(
          wipLimits: {ScrumTaskStatus.inProgress: 1},
          enforceWipLimits: false,
        ),
        initialTasks: [
          task(id: 'active', status: ScrumTaskStatus.inProgress),
          task(id: 'todo', status: ScrumTaskStatus.todo),
        ],
      );

      final result = controller.placeTaskWithResult(
        'todo',
        ScrumTaskStatus.inProgress,
      );

      expect(result.accepted, isTrue);
      expect(result.changed, isTrue);
      expect(controller.countFor(ScrumTaskStatus.inProgress), 2);
    });

    test('blocks moves that exceed enforced WIP limits', () {
      final controller = ScrumBoardController(
        policy: const ScrumWorkflowPolicy(
          wipLimits: {ScrumTaskStatus.inProgress: 1},
          enforceWipLimits: true,
        ),
        initialTasks: [
          task(id: 'active', status: ScrumTaskStatus.inProgress),
          task(id: 'todo', status: ScrumTaskStatus.todo),
        ],
      );

      final result = controller.placeTaskWithResult(
        'todo',
        ScrumTaskStatus.inProgress,
      );

      expect(result.accepted, isFalse);
      expect(result.changed, isFalse);
      expect(result.blockReason, ScrumTaskMoveBlockReason.wipLimit);
      expect(result.targetCount, 2);
      expect(result.targetLimit, 1);
      expect(controller.taskById('todo')?.status, ScrumTaskStatus.todo);
      expect(controller.activities, isEmpty);
    });

    test('allows reordering within a lane when WIP limits are enforced', () {
      final controller = ScrumBoardController(
        policy: const ScrumWorkflowPolicy(
          wipLimits: {ScrumTaskStatus.inProgress: 1},
          enforceWipLimits: true,
        ),
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.inProgress),
          task(id: 'b', status: ScrumTaskStatus.inProgress),
        ],
      );

      final result = controller.placeTaskWithResult(
        'b',
        ScrumTaskStatus.inProgress,
        beforeTaskId: 'a',
      );

      expect(result.accepted, isTrue);
      expect(result.changed, isTrue);
      expect(
        controller.tasksFor(ScrumTaskStatus.inProgress).map((task) => task.id),
        ['b', 'a'],
      );
    });

    test('previews bulk moves against projected WIP capacity', () {
      final controller = ScrumBoardController(
        policy: const ScrumWorkflowPolicy(
          wipLimits: {ScrumTaskStatus.inProgress: 2},
          enforceWipLimits: true,
        ),
        initialTasks: [
          task(id: 'active', status: ScrumTaskStatus.inProgress),
          task(id: 'a', status: ScrumTaskStatus.todo),
          task(id: 'b', status: ScrumTaskStatus.todo),
        ],
      );

      final preview = controller.previewTaskMoves([
        'a',
        'b',
      ], ScrumTaskStatus.inProgress);

      expect(preview.changedCount, 1);
      expect(preview.blockedCount, 1);
      expect(preview.blockedResults.single.taskId, 'b');
      expect(preview.blockedResults.single.targetCount, 3);
      expect(preview.blockedResults.single.targetLimit, 2);
      expect(controller.taskById('a')?.status, ScrumTaskStatus.todo);
      expect(controller.taskById('b')?.status, ScrumTaskStatus.todo);
    });

    test('applies bulk task actions through controller APIs', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.todo),
          task(id: 'b', status: ScrumTaskStatus.todo),
          task(id: 'c', status: ScrumTaskStatus.review),
        ],
      );

      final moveResults = controller.moveTasks([
        'a',
        'b',
        'b',
      ], ScrumTaskStatus.inProgress);
      final updatedPriorities = controller.updateTaskPriorities([
        'a',
        'b',
      ], ScrumTaskPriority.critical);
      final deletedTasks = controller.deleteTasks(['a', 'missing']);

      expect(moveResults, hasLength(2));
      expect(moveResults.every((result) => result.changed), isTrue);
      expect(updatedPriorities, 2);
      expect(deletedTasks, 1);
      expect(controller.taskById('a'), isNull);
      expect(controller.taskById('b')?.status, ScrumTaskStatus.inProgress);
      expect(controller.taskById('b')?.priority, ScrumTaskPriority.critical);
    });

    test('restores deleted tasks to their previous lane order', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.todo, sortOrder: 1000),
          task(id: 'b', status: ScrumTaskStatus.todo, sortOrder: 2000),
          task(id: 'c', status: ScrumTaskStatus.todo, sortOrder: 3000),
        ],
      );
      final deletedTask = controller.taskById('b')!;

      controller.deleteTask('b');
      final restoredCount = controller.restoreTasks([deletedTask, deletedTask]);

      expect(restoredCount, 1);
      expect(controller.tasksFor(ScrumTaskStatus.todo).map((task) => task.id), [
        'a',
        'b',
        'c',
      ]);
      expect(controller.activities.first.note, 'Restored after deletion.');
    });

    test('classifies task due states for card badges', () {
      final now = DateTime(2026, 1, 10, 15);

      final overdue = ScrumTaskDueState.forTask(
        task(
          id: 'overdue',
          status: ScrumTaskStatus.todo,
          dueAt: DateTime(2026, 1, 9),
        ),
        now: now,
      );
      final dueSoon = ScrumTaskDueState.forTask(
        task(
          id: 'soon',
          status: ScrumTaskStatus.todo,
          dueAt: DateTime(2026, 1, 11),
        ),
        now: now,
      );
      final planned = ScrumTaskDueState.forTask(
        task(
          id: 'planned',
          status: ScrumTaskStatus.todo,
          dueAt: DateTime(2026, 1, 20),
        ),
        now: now,
      );
      final completed = ScrumTaskDueState.forTask(
        task(
          id: 'done',
          status: ScrumTaskStatus.done,
          dueAt: DateTime(2026, 1, 9),
        ),
        now: now,
      );

      expect(overdue.status, ScrumTaskDueStatus.overdue);
      expect(overdue.label, 'Overdue');
      expect(dueSoon.status, ScrumTaskDueStatus.dueSoon);
      expect(dueSoon.label, 'Due in 1d');
      expect(planned.status, ScrumTaskDueStatus.planned);
      expect(planned.label, 'Due 20/1');
      expect(completed.status, ScrumTaskDueStatus.planned);
    });

    test('classifies task status age for lane badges', () {
      final ageState = ScrumTaskAgeState.forTask(
        task(
          id: 'review',
          status: ScrumTaskStatus.review,
          createdAt: DateTime(2026, 1, 1),
        ),
        statusStartedAt: DateTime(2026, 1, 5),
        now: DateTime(2026, 1, 8),
        reviewAgeWarningDays: 3,
      );
      final todoAgeState = ScrumTaskAgeState.forTask(
        task(
          id: 'todo',
          status: ScrumTaskStatus.todo,
          createdAt: DateTime(2026, 1, 1),
        ),
        statusStartedAt: DateTime(2026, 1, 5),
        now: DateTime(2026, 1, 8),
      );

      expect(ageState.shouldRender, isTrue);
      expect(ageState.durationLabel, '3d');
      expect(ageState.severity, ScrumTaskAgeSeverity.warning);
      expect(todoAgeState.shouldRender, isFalse);
    });

    test('aggregates lane health from due dates and review age', () {
      final now = DateTime(2026, 1, 10);
      final health = ScrumLaneHealth.forTasks(
        [
          task(
            id: 'overdue',
            status: ScrumTaskStatus.todo,
            dueAt: DateTime(2026, 1, 9),
          ),
          task(
            id: 'soon',
            status: ScrumTaskStatus.todo,
            dueAt: DateTime(2026, 1, 11),
          ),
          task(
            id: 'review',
            status: ScrumTaskStatus.review,
            createdAt: DateTime(2026, 1, 1),
          ),
          task(
            id: 'done',
            status: ScrumTaskStatus.done,
            dueAt: DateTime(2026, 1, 9),
          ),
        ],
        now: now,
        dueSoonDays: 2,
        reviewAgeWarningDays: 3,
        statusStartedAtForTask: (task) {
          if (task.id == 'review') return DateTime(2026, 1, 5);
          return task.createdAt;
        },
      );

      expect(health.overdueTasks, 1);
      expect(health.dueSoonTasks, 1);
      expect(health.agedReviewTasks, 1);
      expect(health.hasSignals, isTrue);
    });

    test('derives current status start from move activity', () {
      var currentTime = DateTime(2026, 1, 5);
      final controller = ScrumBoardController(
        initialTasks: [
          task(
            id: 'aging',
            status: ScrumTaskStatus.todo,
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        clock: () => currentTime,
      );

      controller.moveTask('aging', ScrumTaskStatus.review);
      final movedAt = currentTime;

      currentTime = DateTime(2026, 1, 6);
      controller.updateTask(
        controller.taskById('aging')!.copyWith(title: 'Updated title'),
      );

      expect(
        controller.statusStartedAtForTask(controller.taskById('aging')!),
        movedAt,
      );
    });

    test('records task activity history in newest-first order', () {
      var tick = 0;
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.todo),
          task(id: 'b', status: ScrumTaskStatus.todo),
        ],
        activityActor: 'Alya',
        clock: () => DateTime(2026, 1, 2, 9).add(Duration(minutes: tick++)),
      );

      controller.addTask(task(id: 'new', status: ScrumTaskStatus.backlog));
      controller.placeTask('new', ScrumTaskStatus.todo, beforeTaskId: 'a');
      controller.updateTask(
        controller.taskById('new')!.copyWith(title: 'Renamed task'),
      );
      controller.placeTask('new', ScrumTaskStatus.todo, beforeTaskId: 'b');
      controller.deleteTask('new');

      expect(controller.activities.map((activity) => activity.type), [
        ScrumActivityType.taskDeleted,
        ScrumActivityType.taskReordered,
        ScrumActivityType.taskUpdated,
        ScrumActivityType.taskMoved,
        ScrumActivityType.taskCreated,
      ]);
      expect(controller.activities.first.taskTitle, 'Renamed task');
      expect(controller.activities.first.actor, 'Alya');
      expect(controller.activities.last.toStatus, ScrumTaskStatus.backlog);
      expect(controller.activitiesForTask('new', limit: 2), hasLength(2));
    });

    test('records trimmed task notes in activity history', () {
      final controller = ScrumBoardController(
        initialTasks: [task(id: 'note-task', status: ScrumTaskStatus.todo)],
        activityActor: 'Alya',
        clock: () => DateTime(2026, 1, 2, 9),
      );

      expect(
        controller.addTaskNote('note-task', '  Waiting on gateway keys.  '),
        isTrue,
      );
      expect(controller.addTaskNote('note-task', '   '), isFalse);
      expect(controller.addTaskNote('missing-task', 'Follow up.'), isFalse);

      expect(controller.activities, hasLength(1));
      expect(controller.activities.first.type, ScrumActivityType.taskCommented);
      expect(controller.activities.first.taskId, 'note-task');
      expect(controller.activities.first.taskTitle, 'Task note-task');
      expect(controller.activities.first.actor, 'Alya');
      expect(controller.activities.first.note, 'Waiting on gateway keys.');
    });

    test('records priority changes with transition metadata', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(
            id: 'priority-task',
            status: ScrumTaskStatus.todo,
            priority: ScrumTaskPriority.low,
          ),
        ],
        activityActor: 'Alya',
        clock: () => DateTime(2026, 1, 2, 10),
      );

      final updatedCount = controller.updateTaskPriorities([
        'priority-task',
        'missing-task',
      ], ScrumTaskPriority.critical);

      expect(updatedCount, 1);
      expect(controller.activities, hasLength(1));
      expect(
        controller.activities.first.type,
        ScrumActivityType.taskPriorityChanged,
      );
      expect(controller.activities.first.fromPriority, ScrumTaskPriority.low);
      expect(
        controller.activities.first.toPriority,
        ScrumTaskPriority.critical,
      );
      expect(controller.activities.first.fromStatus, isNull);
      expect(controller.activities.first.toStatus, isNull);
      expect(controller.activities.first.actor, 'Alya');
    });

    test('filters tasks by query within a status', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(id: 'billing', status: ScrumTaskStatus.backlog),
          task(id: 'auth', status: ScrumTaskStatus.backlog),
        ],
      );

      expect(
        controller.tasksFor(ScrumTaskStatus.backlog, query: 'AUTH'),
        hasLength(1),
      );
      expect(
        controller.tasksFor(ScrumTaskStatus.backlog, query: 'AUTH').single.id,
        'auth',
      );
    });

    test('filters tasks by priority, assignee, status, and query', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(
            id: 'a',
            status: ScrumTaskStatus.todo,
            assignee: 'Alya',
            priority: ScrumTaskPriority.critical,
          ),
          task(
            id: 'b',
            status: ScrumTaskStatus.todo,
            assignee: 'Bayu',
            priority: ScrumTaskPriority.critical,
          ),
          task(
            id: 'c',
            status: ScrumTaskStatus.review,
            assignee: 'Alya',
            priority: ScrumTaskPriority.critical,
          ),
        ],
      );
      const filter = ScrumBoardFilter(
        query: 'task',
        status: ScrumTaskStatus.todo,
        priorities: {ScrumTaskPriority.critical},
        assignees: {'Alya'},
      );

      expect(controller.filteredTasks(filter).map((task) => task.id), ['a']);
      expect(controller.tasksFor(ScrumTaskStatus.todo, filter: filter), [
        controller.taskById('a'),
      ]);
      expect(controller.assignees(), ['Alya', 'Bayu']);
    });

    test('removes individual board filter facets', () {
      const filter = ScrumBoardFilter(
        query: 'incident',
        status: ScrumTaskStatus.todo,
        priorities: {ScrumTaskPriority.critical, ScrumTaskPriority.low},
        assignees: {'Alya', 'Bayu'},
        sort: ScrumTaskSort.dueDate,
      );

      expect(filter.clearQuery().query, isEmpty);
      expect(filter.withStatus(null).status, isNull);
      expect(
        filter.withoutPriority(ScrumTaskPriority.critical).priorities,
        isNot(contains(ScrumTaskPriority.critical)),
      );
      expect(filter.withoutAssignee('Alya').assignees, isNot(contains('Alya')));
      expect(filter.clearSort().sort, ScrumTaskSort.laneOrder);
    });

    test('matches and normalizes board view presets', () {
      const preset = ScrumBoardViewPreset(
        id: 'alya-critical',
        label: 'Alya Critical',
        filter: ScrumBoardFilter(
          priorities: {ScrumTaskPriority.critical},
          assignees: {'Alya'},
          sort: ScrumTaskSort.priority,
        ),
      );
      const config = ScrumBoardConfig(
        viewPresets: [
          preset,
          ScrumBoardViewPreset(
            id: 'alya-critical',
            label: 'Duplicate',
            filter: ScrumBoardFilter(),
          ),
        ],
      );

      expect(
        preset.matches(
          const ScrumBoardFilter(
            priorities: {ScrumTaskPriority.critical},
            assignees: {'Alya'},
            sort: ScrumTaskSort.priority,
          ),
        ),
        isTrue,
      );
      expect(config.visibleViewPresets, hasLength(1));
      expect(config.presetById('alya-critical')?.label, 'Alya Critical');
    });

    test('sorts filtered tasks by due date and priority', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(
            id: 'later',
            status: ScrumTaskStatus.todo,
            dueAt: DateTime(2026, 1, 20),
            priority: ScrumTaskPriority.low,
          ),
          task(
            id: 'critical',
            status: ScrumTaskStatus.todo,
            dueAt: DateTime(2026, 1, 14),
            priority: ScrumTaskPriority.critical,
          ),
          task(
            id: 'soon',
            status: ScrumTaskStatus.todo,
            dueAt: DateTime(2026, 1, 10),
            priority: ScrumTaskPriority.medium,
          ),
        ],
      );

      expect(
        controller
            .tasksFor(
              ScrumTaskStatus.todo,
              filter: const ScrumBoardFilter(sort: ScrumTaskSort.dueDate),
            )
            .map((task) => task.id),
        ['soon', 'critical', 'later'],
      );
      expect(
        controller
            .tasksFor(
              ScrumTaskStatus.todo,
              filter: const ScrumBoardFilter(sort: ScrumTaskSort.priority),
            )
            .map((task) => task.id),
        ['critical', 'soon', 'later'],
      );
    });

    test('creates workflow insights from WIP and due-date pressure', () {
      final now = DateTime(2026, 1, 10);
      final controller = ScrumBoardController(
        policy: const ScrumWorkflowPolicy(
          wipLimits: {ScrumTaskStatus.inProgress: 1},
          dueSoonDays: 2,
        ),
        initialTasks: [
          task(
            id: 'a',
            status: ScrumTaskStatus.inProgress,
            dueAt: DateTime(2026, 1, 9),
          ),
          task(
            id: 'b',
            status: ScrumTaskStatus.inProgress,
            dueAt: DateTime(2026, 1, 12),
            priority: ScrumTaskPriority.critical,
          ),
        ],
      );

      final insightKeys = controller
          .insights(now: now)
          .map((insight) => insight.key)
          .toSet();

      expect(insightKeys, contains('wip-inProgress'));
      expect(insightKeys, contains('overdue'));
      expect(insightKeys, contains('due-soon'));
      expect(insightKeys, contains('critical-open'));
    });

    test('uses board config labels and policy for insights', () {
      final controller = ScrumBoardController(
        config: const ScrumBoardConfig(
          statusLabels: {ScrumTaskStatus.inProgress: 'Doing'},
          policy: ScrumWorkflowPolicy(
            wipLimits: {ScrumTaskStatus.inProgress: 1},
          ),
        ),
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.inProgress),
          task(id: 'b', status: ScrumTaskStatus.inProgress),
        ],
      );

      expect(controller.policy.limitFor(ScrumTaskStatus.inProgress), 1);
      expect(controller.insights().first.title, 'Doing WIP is high');
    });

    test('creates sprint capacity and date insights', () {
      final controller = ScrumBoardController(
        config: ScrumBoardConfig(
          sprint: ScrumSprint(
            id: 'sprint-1',
            name: 'Sprint 1',
            goal: 'Finish core planning',
            startAt: DateTime(2026, 1, 1),
            endAt: DateTime(2026, 1, 10),
            capacityStoryPoints: 5,
            velocityTargetStoryPoints: 3,
          ),
        ),
        initialTasks: [
          task(id: 'done', status: ScrumTaskStatus.done, points: 3),
          task(id: 'active', status: ScrumTaskStatus.inProgress, points: 5),
        ],
      );

      final insightKeys = controller
          .insights(now: DateTime(2026, 1, 10))
          .map((insight) => insight.key)
          .toSet();

      expect(insightKeys, contains('sprint-capacity'));
      expect(insightKeys, contains('velocity-target-met'));
      expect(insightKeys, contains('sprint-ending-soon'));
    });

    test('creates sprint overrun insight after sprint end', () {
      final controller = ScrumBoardController(
        config: ScrumBoardConfig(
          sprint: ScrumSprint(
            id: 'sprint-1',
            name: 'Sprint 1',
            goal: 'Finish core planning',
            startAt: DateTime(2026, 1, 1),
            endAt: DateTime(2026, 1, 5),
          ),
        ),
        initialTasks: [
          task(id: 'active', status: ScrumTaskStatus.inProgress, points: 5),
        ],
      );

      expect(
        controller
            .insights(now: DateTime(2026, 1, 6))
            .map((insight) => insight.key),
        contains('sprint-overrun'),
      );
    });

    test('summarizes active workload by assignee', () {
      final controller = ScrumBoardController(
        initialTasks: [
          task(
            id: 'a',
            status: ScrumTaskStatus.inProgress,
            assignee: 'Alya',
            points: 5,
          ),
          task(
            id: 'b',
            status: ScrumTaskStatus.todo,
            assignee: 'Alya',
            points: 3,
            priority: ScrumTaskPriority.critical,
          ),
          task(
            id: 'c',
            status: ScrumTaskStatus.done,
            assignee: 'Alya',
            points: 8,
          ),
        ],
      );

      final load = controller.assigneeLoads().single;

      expect(load.assignee, 'Alya');
      expect(load.activeTasks, 2);
      expect(load.activeStoryPoints, 8);
      expect(load.criticalTasks, 1);
    });

    test('loads tasks through a repository boundary', () async {
      final repository = InMemoryScrumTaskRepository(
        initialTasks: [task(id: 'repo-task', status: ScrumTaskStatus.todo)],
      );
      final controller = ScrumBoardController(repository: repository);

      await controller.loadTasks();

      expect(controller.hasPersistenceBoundary, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.tasks.single.id, 'repo-task');
    });

    test('persists task mutations through the repository', () async {
      final repository = InMemoryScrumTaskRepository(
        initialTasks: [task(id: 'repo-task', status: ScrumTaskStatus.todo)],
      );
      final controller = ScrumBoardController(repository: repository);

      await controller.loadTasks();
      controller.moveTask('repo-task', ScrumTaskStatus.done);
      controller.addTask(task(id: 'new-task', status: ScrumTaskStatus.backlog));
      controller.deleteTask('new-task');
      await controller.pendingPersistence;

      final persistedTasks = await repository.loadTasks();

      expect(persistedTasks, hasLength(1));
      expect(persistedTasks.single.id, 'repo-task');
      expect(persistedTasks.single.status, ScrumTaskStatus.done);
    });

    test('persists activity history through the repository', () async {
      final activityRepository = InMemoryScrumActivityRepository();
      final controller = ScrumBoardController(
        activityRepository: activityRepository,
        clock: () => DateTime(2026, 1, 2, 9),
      );

      controller.addTask(task(id: 'logged', status: ScrumTaskStatus.todo));
      await controller.pendingPersistence;

      final loadedController = ScrumBoardController(
        activityRepository: activityRepository,
      );
      await loadedController.loadActivities();

      expect(loadedController.hasActivityBoundary, isTrue);
      expect(
        loadedController.activities.single.type,
        ScrumActivityType.taskCreated,
      );
      expect(loadedController.activities.single.taskId, 'logged');
    });

    test('persists reordered task ranks through the repository', () async {
      final repository = InMemoryScrumTaskRepository(
        initialTasks: [
          task(id: 'a', status: ScrumTaskStatus.todo),
          task(id: 'b', status: ScrumTaskStatus.todo),
          task(id: 'c', status: ScrumTaskStatus.todo),
        ],
      );
      final controller = ScrumBoardController(repository: repository);

      await controller.loadTasks();
      controller.placeTask('c', ScrumTaskStatus.todo, beforeTaskId: 'a');
      await controller.pendingPersistence;

      final persistedController = ScrumBoardController(
        initialTasks: await repository.loadTasks(),
      );

      expect(
        persistedController
            .tasksFor(ScrumTaskStatus.todo)
            .map((task) => task.id),
        ['c', 'a', 'b'],
      );
    });

    test('replaces all tasks through the repository', () async {
      final repository = InMemoryScrumTaskRepository(
        initialTasks: [task(id: 'old-task', status: ScrumTaskStatus.todo)],
      );
      final controller = ScrumBoardController(repository: repository);
      final replacement = task(
        id: 'replacement-task',
        status: ScrumTaskStatus.review,
      );

      await controller.replaceTasks([replacement]);

      final persistedTasks = await repository.loadTasks();
      expect(controller.tasks.single.id, 'replacement-task');
      expect(persistedTasks.single.id, 'replacement-task');
    });
  });

  group('BoardTaskQuery', () {
    ScrumTask task({
      required String id,
      required ScrumTaskStatus status,
      required String title,
      DateTime? createdAt,
      DateTime? dueAt,
      int points = 3,
      String assignee = 'Team',
      ScrumTaskPriority priority = ScrumTaskPriority.medium,
      String? label,
    }) {
      return ScrumTask(
        id: id,
        title: title,
        description: 'Description for $title',
        assignee: assignee,
        storyPoints: points,
        createdAt: createdAt ?? DateTime(2026, 1, 1),
        dueAt: dueAt,
        status: status,
        priority: priority,
        label: label,
        accentColor: Colors.blue,
      );
    }

    test(
      'filters, sorts, and summarizes board tasks without controller state',
      () {
        final query = BoardTaskQuery(
          config: const ScrumBoardConfig(),
          tasks: [
            task(
              id: 'later',
              status: ScrumTaskStatus.todo,
              title: 'Later API follow-up',
              dueAt: DateTime(2026, 1, 20),
              assignee: 'Bima',
              points: 5,
            ),
            task(
              id: 'soon',
              status: ScrumTaskStatus.todo,
              title: 'Payments release readiness',
              dueAt: DateTime(2026, 1, 12),
              assignee: 'Alya',
              points: 8,
              label: 'Payments',
            ),
            task(
              id: 'unplanned',
              status: ScrumTaskStatus.todo,
              title: 'Unplanned polish',
              assignee: 'Alya',
              points: 2,
            ),
            task(
              id: 'done',
              status: ScrumTaskStatus.done,
              title: 'Completed cleanup',
              assignee: 'Bima',
              points: 3,
            ),
          ],
        );

        final dueFirstTasks = query.tasksFor(
          ScrumTaskStatus.todo,
          filter: const ScrumBoardFilter(sort: ScrumTaskSort.dueDate),
        );
        final paymentTasks = query.filteredTasks(
          const ScrumBoardFilter(query: 'payments'),
        );

        expect(dueFirstTasks.map((task) => task.id), [
          'soon',
          'later',
          'unplanned',
        ]);
        expect(paymentTasks.map((task) => task.id), ['soon']);
        expect(query.assignees(), ['Alya', 'Bima']);
        expect(query.summary.totalStoryPoints, 18);
        expect(query.summary.completedStoryPoints, 3);
        expect(query.storyPointsFor(ScrumTaskStatus.todo), 15);
        expect(query.assigneeLoads().map((load) => load.assignee), [
          'Alya',
          'Bima',
        ]);
      },
    );

    test('builds prioritized flow insights without controller state', () {
      final query = BoardTaskQuery(
        config: ScrumBoardConfig(
          sprint: ScrumSprint(
            id: 'sprint-1',
            name: 'Sprint 1',
            goal: 'Close delivery pressure',
            startAt: DateTime(2026, 1, 1),
            endAt: DateTime(2026, 1, 8),
            capacityStoryPoints: 5,
          ),
          statusLabels: const {ScrumTaskStatus.todo: 'Ready'},
          policy: const ScrumWorkflowPolicy(
            wipLimits: {ScrumTaskStatus.todo: 1},
            enforceWipLimits: true,
          ),
        ),
        tasks: [
          task(
            id: 'overdue',
            status: ScrumTaskStatus.todo,
            title: 'Overdue payment reconciliation',
            dueAt: DateTime(2026, 1, 9),
            priority: ScrumTaskPriority.critical,
            points: 5,
          ),
          task(
            id: 'extra-ready',
            status: ScrumTaskStatus.todo,
            title: 'Ready lane overflow',
            points: 3,
          ),
        ],
      );

      final insights = query.insights(now: DateTime(2026, 1, 10));
      final keys = insights.map((insight) => insight.key);

      expect(insights.first.severity, ScrumBoardInsightSeverity.critical);
      expect(
        keys,
        containsAll([
          'sprint-capacity',
          'sprint-overrun',
          'wip-todo',
          'overdue',
          'critical-open',
        ]),
      );
      expect(
        insights.firstWhere((insight) => insight.key == 'wip-todo').title,
        'Ready WIP is high',
      );
    });
  });

  group('BoardTaskBatch', () {
    ScrumTask task(String id, {String title = ''}) {
      return ScrumTask(
        id: id,
        title: title.isEmpty ? 'Task $id' : title,
        description: 'Deduplicates task batches.',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: ScrumTaskStatus.todo,
      );
    }

    test('keeps first-seen task id order when deduplicating', () {
      final batch = BoardTaskBatch(['a', 'b', 'a', 'missing', 'b', 'c']);

      expect(batch.uniqueIds, ['a', 'b', 'missing', 'c']);
    });

    test('runs command helpers once per unique task id', () {
      final batch = BoardTaskBatch(['a', 'a', 'b', 'c']);
      final visitedIds = <String>[];

      final labels = batch.map((id) {
        visitedIds.add(id);
        return 'task:$id';
      });
      final acceptedCount = batch.countWhere((id) => id != 'c');

      expect(visitedIds, ['a', 'b', 'c']);
      expect(labels, ['task:a', 'task:b', 'task:c']);
      expect(acceptedCount, 2);
    });

    test('deduplicates tasks by id using the latest task value', () {
      final tasks = uniqueTasksById([
        task('a', title: 'Original A'),
        task('b', title: 'Original B'),
        task('a', title: 'Updated A'),
      ]);

      expect(tasks.map((task) => task.id), ['a', 'b']);
      expect(tasks.first.title, 'Updated A');
      expect(tasks.last.title, 'Original B');
    });
  });

  group('BoardActionFeedback', () {
    const feedback = BoardActionFeedback();

    test('formats pluralized task action messages', () {
      expect(feedback.deletedTasks(1), '1 task deleted.');
      expect(feedback.deletedTasks(3), '3 tasks deleted.');
      expect(feedback.restoredTasks(1), '1 task restored.');
      expect(feedback.restoredTasks(2), '2 tasks restored.');
      expect(feedback.movedTasks(1, 'Review'), '1 task moved to Review.');
      expect(feedback.movedTasks(4, 'Done'), '4 tasks moved to Done.');
    });

    test('formats blocked move feedback from the first blocked result', () {
      final message = feedback.blockedMoveResults([
        ScrumTaskMoveResult.blocked(
          taskId: 'blocked',
          toStatus: ScrumTaskStatus.inProgress,
          reason: ScrumTaskMoveBlockReason.wipLimit,
          message: 'In Progress is at its WIP limit of 2 tasks.',
        ),
      ]);

      expect(
        message,
        '1 selected task could not move. '
        'In Progress is at its WIP limit of 2 tasks.',
      );
    });

    test('formats detail action feedback', () {
      expect(
        feedback.priorityChanged(ScrumTaskPriority.critical),
        'Task priority changed to Critical.',
      );
      expect(feedback.taskNoteAdded(), 'Task note added.');
    });
  });

  group('BoardSnackBarPresenter', () {
    const presenter = BoardSnackBarPresenter();

    test('builds floating snackbars with optional actions', () {
      final action = SnackBarAction(label: 'Undo', onPressed: () {});

      final snackBar = presenter.snackBar('Saved.', action: action);

      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.action, action);
      expect(snackBar.content, isA<Text>());
      expect((snackBar.content as Text).data, 'Saved.');
    });
  });

  group('BoardTaskDeletionPlanner', () {
    ScrumTask task(String id) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Plans deletion flow.',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: ScrumTaskStatus.todo,
      );
    }

    test('plans selected tasks that still exist on the board', () {
      final tasksById = {'a': task('a'), 'b': task('b')};
      final planner = BoardTaskDeletionPlanner(taskById: (id) => tasksById[id]);

      final plan = planner.planSelectedTasks(['a', 'missing', 'b']);

      expect(plan.canConfirm, isTrue);
      expect(plan.taskCount, 2);
      expect(plan.selectedTasks.map((task) => task.id), ['a', 'b']);
    });

    test('detects captured tasks that are restorable after deletion', () {
      final removedTask = task('removed');
      final existingTask = task('existing');
      final tasksById = {'existing': existingTask};
      final planner = BoardTaskDeletionPlanner(taskById: (id) => tasksById[id]);

      final restorableTasks = planner.restorableTasks([
        removedTask,
        existingTask,
      ]);

      expect(restorableTasks.map((task) => task.id), ['removed']);
    });
  });

  group('BoardTaskMoveOutcomePlanner', () {
    const planner = BoardTaskMoveOutcomePlanner();

    test('collects movable ids from preview changed results', () {
      final preview = ScrumTaskMovePreview(
        toStatus: ScrumTaskStatus.review,
        results: [
          ScrumTaskMoveResult.moved(
            taskId: 'movable',
            fromStatus: ScrumTaskStatus.todo,
            toStatus: ScrumTaskStatus.review,
            targetCount: 1,
          ),
          ScrumTaskMoveResult.unchanged(
            taskId: 'same',
            status: ScrumTaskStatus.review,
          ),
          ScrumTaskMoveResult.blocked(
            taskId: 'blocked',
            toStatus: ScrumTaskStatus.review,
            reason: ScrumTaskMoveBlockReason.wipLimit,
            message: 'Review is at its WIP limit.',
          ),
        ],
      );

      expect(planner.movableTaskIds(preview), ['movable']);
    });

    test('summarizes changed ids and success feedback', () {
      final outcome = planner.summarize(
        statusLabel: 'Review',
        results: [
          ScrumTaskMoveResult.moved(
            taskId: 'first',
            fromStatus: ScrumTaskStatus.todo,
            toStatus: ScrumTaskStatus.review,
            targetCount: 1,
          ),
          ScrumTaskMoveResult.moved(
            taskId: 'second',
            fromStatus: ScrumTaskStatus.todo,
            toStatus: ScrumTaskStatus.review,
            targetCount: 2,
          ),
        ],
      );

      expect(outcome.hasBlockedResults, isFalse);
      expect(outcome.changedTaskIds, ['first', 'second']);
      expect(outcome.message, '2 tasks moved to Review.');
    });

    test('summarizes blocked feedback before success feedback', () {
      final outcome = planner.summarize(
        statusLabel: 'Review',
        results: [
          ScrumTaskMoveResult.moved(
            taskId: 'first',
            fromStatus: ScrumTaskStatus.todo,
            toStatus: ScrumTaskStatus.review,
            targetCount: 1,
          ),
          ScrumTaskMoveResult.blocked(
            taskId: 'blocked',
            toStatus: ScrumTaskStatus.review,
            reason: ScrumTaskMoveBlockReason.wipLimit,
            message: 'Review is at its WIP limit.',
          ),
        ],
      );

      expect(outcome.hasBlockedResults, isTrue);
      expect(outcome.blockedResults.single.taskId, 'blocked');
      expect(outcome.changedTaskIds, ['first']);
      expect(
        outcome.message,
        '1 selected task could not move. Review is at its WIP limit.',
      );
    });
  });

  group('BoardTaskDetailActionDispatcher', () {
    ScrumTask task() {
      return ScrumTask(
        id: 'detail',
        title: 'Detail task',
        description: 'Routes task detail actions.',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: ScrumTaskStatus.todo,
      );
    }

    BoardTaskDetailActionDispatcher dispatcher(List<String> actions) {
      return BoardTaskDetailActionDispatcher(
        onEdit: (task) => actions.add('edit:${task.id}'),
        onDelete: (task) => actions.add('delete:${task.id}'),
        onMove: (task, status) => actions.add('move:${task.id}:${status.name}'),
        onPriorityChanged: (task, priority) {
          actions.add('priority:${task.id}:${priority.name}');
        },
        onNoteAdded: (task, note) => actions.add('note:${task.id}:$note'),
      );
    }

    test('routes edit and delete actions', () async {
      final actions = <String>[];
      final actionDispatcher = dispatcher(actions);
      final detailTask = task();

      await actionDispatcher.dispatch(
        detailTask,
        const ScrumTaskDetailResult.edit(),
      );
      await actionDispatcher.dispatch(
        detailTask,
        const ScrumTaskDetailResult.delete(),
      );

      expect(actions, ['edit:detail', 'delete:detail']);
    });

    test('routes move, priority, and note payload actions', () async {
      final actions = <String>[];
      final actionDispatcher = dispatcher(actions);
      final detailTask = task();

      await actionDispatcher.dispatch(
        detailTask,
        const ScrumTaskDetailResult.move(ScrumTaskStatus.review),
      );
      await actionDispatcher.dispatch(
        detailTask,
        const ScrumTaskDetailResult.priority(ScrumTaskPriority.critical),
      );
      await actionDispatcher.dispatch(
        detailTask,
        const ScrumTaskDetailResult.note('Waiting on release notes.'),
      );

      expect(actions, [
        'move:detail:review',
        'priority:detail:critical',
        'note:detail:Waiting on release notes.',
      ]);
    });

    test('ignores a dismissed task detail panel', () async {
      final actions = <String>[];

      await dispatcher(actions).dispatch(task(), null);

      expect(actions, isEmpty);
    });
  });

  group('BoardTaskOrderEditor', () {
    ScrumTask task({
      required String id,
      ScrumTaskStatus status = ScrumTaskStatus.todo,
      int sortOrder = 0,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
        sortOrder: sortOrder,
      );
    }

    test('appends and normalizes lane order in a mutable task list', () {
      final tasks = [
        task(id: 'later', sortOrder: 2000),
        task(id: 'first', sortOrder: 1000),
      ];
      final editor = BoardTaskOrderEditor(tasks: tasks);

      final appended = editor.orderedForAppend(
        task(id: 'new'),
        ScrumTaskStatus.todo,
      );
      tasks.add(appended);
      final changedTasks = editor.normalizeStatus(ScrumTaskStatus.todo);

      expect(appended.sortOrder, 3000);
      expect(
        editor.tasksForStatus(ScrumTaskStatus.todo).map((task) => task.id),
        ['first', 'later', 'new'],
      );
      expect(changedTasks, isEmpty);
    });

    test('applies a provided visual order to one lane', () {
      final tasks = [
        task(id: 'a', sortOrder: 1000),
        task(id: 'b', sortOrder: 2000),
        task(id: 'c', sortOrder: 3000),
      ];
      final editor = BoardTaskOrderEditor(tasks: tasks);

      final changedTasks = editor.applyOrderedColumn(ScrumTaskStatus.todo, [
        tasks[2],
        tasks[0],
        tasks[1],
      ]);

      expect(changedTasks.map((task) => task.id), ['c', 'a', 'b']);
      expect(
        editor.tasksForStatus(ScrumTaskStatus.todo).map((task) => task.id),
        ['c', 'a', 'b'],
      );
    });
  });

  group('BoardTaskUpsertEditor', () {
    ScrumTask task({
      required String id,
      ScrumTaskStatus status = ScrumTaskStatus.todo,
      ScrumTaskPriority priority = ScrumTaskPriority.medium,
      int sortOrder = 0,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
        priority: priority,
        sortOrder: sortOrder,
      );
    }

    test('creates new tasks with creation activity context', () {
      final tasks = [task(id: 'existing', sortOrder: 1000)];
      final orderEditor = BoardTaskOrderEditor(tasks: tasks);
      final editor = BoardTaskUpsertEditor(
        tasks: tasks,
        orderEditor: orderEditor,
      );

      final application = editor.addOrUpdate(task(id: 'new'));

      expect(application.applied, isTrue);
      expect(application.created, isTrue);
      expect(application.activityType, ScrumActivityType.taskCreated);
      expect(application.toStatus, ScrumTaskStatus.todo);
      expect(application.changedTasks.single.id, 'new');
      expect(application.updatedTask?.sortOrder, 2000);
      expect(
        orderEditor.tasksForStatus(ScrumTaskStatus.todo).map((task) => task.id),
        ['existing', 'new'],
      );
    });

    test('updates existing tasks with priority transition metadata', () {
      final tasks = [
        task(id: 'target', priority: ScrumTaskPriority.medium, sortOrder: 1000),
      ];
      final editor = BoardTaskUpsertEditor(
        tasks: tasks,
        orderEditor: BoardTaskOrderEditor(tasks: tasks),
      );

      final application = editor.update(
        task(
          id: 'target',
          priority: ScrumTaskPriority.critical,
          sortOrder: 1000,
        ),
      );

      expect(application.applied, isTrue);
      expect(application.created, isFalse);
      expect(application.activityType, ScrumActivityType.taskPriorityChanged);
      expect(application.fromPriority, ScrumTaskPriority.medium);
      expect(application.toPriority, ScrumTaskPriority.critical);
      expect(application.fromStatus, isNull);
      expect(application.toStatus, isNull);
      expect(
        application.changedTasks.single.priority,
        ScrumTaskPriority.critical,
      );
    });
  });

  group('BoardTaskRemovalEditor', () {
    ScrumTask task({
      required String id,
      ScrumTaskStatus status = ScrumTaskStatus.todo,
      int sortOrder = 0,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
        sortOrder: sortOrder,
      );
    }

    test('deletes a task and returns removed task context', () {
      final tasks = [
        task(id: 'keep', sortOrder: 1000),
        task(id: 'delete', sortOrder: 2000),
      ];
      final editor = BoardTaskRemovalEditor(
        tasks: tasks,
        orderEditor: BoardTaskOrderEditor(tasks: tasks),
      );

      final application = editor.delete('delete');

      expect(application.applied, isTrue);
      expect(application.removedTask?.id, 'delete');
      expect(tasks.map((task) => task.id), ['keep']);
    });

    test('restores missing tasks once and normalizes affected lanes', () {
      final tasks = [task(id: 'existing', sortOrder: 1000)];
      final orderEditor = BoardTaskOrderEditor(tasks: tasks);
      final editor = BoardTaskRemovalEditor(
        tasks: tasks,
        orderEditor: orderEditor,
      );

      final application = editor.restore([
        task(id: 'restored', sortOrder: 4000),
        task(id: 'restored', sortOrder: 2000),
        task(id: 'existing', sortOrder: 1000),
      ]);

      expect(application.applied, isTrue);
      expect(application.restoredCount, 1);
      expect(application.restoredTasks.single.id, 'restored');
      expect(
        orderEditor.tasksForStatus(ScrumTaskStatus.todo).map((task) => task.id),
        ['existing', 'restored'],
      );
      expect(
        orderEditor.tasksForStatus(ScrumTaskStatus.todo).last.sortOrder,
        2000,
      );
    });
  });

  group('BoardTaskReplacementEditor', () {
    ScrumTask task({
      required String id,
      ScrumTaskStatus status = ScrumTaskStatus.todo,
      int sortOrder = 0,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
        sortOrder: sortOrder,
      );
    }

    test('replaces board tasks and normalizes lane order', () {
      final tasks = [task(id: 'old', sortOrder: 1000)];
      final editor = BoardTaskReplacementEditor(tasks: tasks);

      final application = editor.replace([
        task(id: 'later', sortOrder: 3000),
        task(id: 'first', sortOrder: 1000),
        task(id: 'unranked'),
      ]);

      expect(tasks.map((task) => task.id), ['later', 'first', 'unranked']);
      expect(tasks.firstWhere((task) => task.id == 'first').sortOrder, 1000);
      expect(tasks.firstWhere((task) => task.id == 'later').sortOrder, 2000);
      expect(tasks.firstWhere((task) => task.id == 'unranked').sortOrder, 3000);
      expect(application.replacedTasks.map((task) => task.id), [
        'later',
        'first',
        'unranked',
      ]);
      expect(application.taskCount, 3);
      expect(application.activityType, ScrumActivityType.boardReplaced);
      expect(application.note, '3 tasks loaded into the board.');
    });

    test('supports replacing the board with an empty task list', () {
      final tasks = [task(id: 'old', sortOrder: 1000)];
      final editor = BoardTaskReplacementEditor(tasks: tasks);

      final application = editor.replace([]);

      expect(tasks, isEmpty);
      expect(application.replacedTasks, isEmpty);
      expect(application.taskCount, 0);
      expect(application.note, '0 tasks loaded into the board.');
    });
  });

  group('BoardTaskBulkEditor', () {
    ScrumTask task({
      required String id,
      ScrumTaskPriority priority = ScrumTaskPriority.medium,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: ScrumTaskStatus.todo,
        priority: priority,
      );
    }

    test('updates unique task priorities as one batch', () {
      final tasks = [
        task(id: 'a'),
        task(id: 'b'),
        task(id: 'already', priority: ScrumTaskPriority.critical),
      ];
      final upsertEditor = BoardTaskUpsertEditor(
        tasks: tasks,
        orderEditor: BoardTaskOrderEditor(tasks: tasks),
      );
      final editor = BoardTaskBulkEditor(
        tasks: tasks,
        upsertEditor: upsertEditor,
      );

      final application = editor.updatePriorities([
        'a',
        'a',
        'missing',
        'already',
        'b',
      ], ScrumTaskPriority.critical);

      expect(application.applied, isTrue);
      expect(application.updatedCount, 2);
      expect(
        application.applications.map(
          (application) => application.updatedTask?.id,
        ),
        ['a', 'b'],
      );
      expect(
        application.applications.map((application) => application.activityType),
        [
          ScrumActivityType.taskPriorityChanged,
          ScrumActivityType.taskPriorityChanged,
        ],
      );
      expect(tasks.map((task) => task.priority), [
        ScrumTaskPriority.critical,
        ScrumTaskPriority.critical,
        ScrumTaskPriority.critical,
      ]);
    });
  });

  group('BoardTaskNoteEditor', () {
    ScrumTask task({required String id}) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: ScrumTaskStatus.todo,
      );
    }

    test('trims notes and returns comment activity context', () {
      final editor = BoardTaskNoteEditor(tasks: [task(id: 'note')]);

      final application = editor.addNote(
        'note',
        '  Waiting on gateway keys.  ',
      );

      expect(application.applied, isTrue);
      expect(application.task?.id, 'note');
      expect(application.note, 'Waiting on gateway keys.');
      expect(application.activityType, ScrumActivityType.taskCommented);
    });

    test('rejects missing tasks and blank notes', () {
      final editor = BoardTaskNoteEditor(tasks: [task(id: 'note')]);

      expect(editor.addNote('missing', 'Follow up.').applied, isFalse);
      expect(editor.addNote('note', '   ').applied, isFalse);
    });
  });

  group('BoardMoveApplier', () {
    ScrumTask task({
      required String id,
      required ScrumTaskStatus status,
      int sortOrder = 0,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
        sortOrder: sortOrder,
      );
    }

    test('applies a cross-lane move and returns activity context', () {
      final tasks = [
        task(id: 'todo', status: ScrumTaskStatus.todo, sortOrder: 1000),
        task(id: 'review-a', status: ScrumTaskStatus.review, sortOrder: 1000),
        task(id: 'review-b', status: ScrumTaskStatus.review, sortOrder: 2000),
      ];
      final orderEditor = BoardTaskOrderEditor(tasks: tasks);
      final applier = BoardMoveApplier(
        tasks: tasks,
        config: const ScrumBoardConfig(),
        orderEditor: orderEditor,
      );

      final application = applier.apply(
        ScrumTaskMoveResult.moved(
          taskId: 'todo',
          fromStatus: ScrumTaskStatus.todo,
          toStatus: ScrumTaskStatus.review,
          targetCount: 3,
        ),
        beforeTaskId: 'review-b',
      );

      expect(application.result.changed, isTrue);
      expect(application.activityType, ScrumActivityType.taskMoved);
      expect(application.previousTask?.status, ScrumTaskStatus.todo);
      expect(application.updatedTask?.status, ScrumTaskStatus.review);
      expect(application.note, 'Placed before Task review-b.');
      expect(application.changedTasks.map((task) => task.id), [
        'todo',
        'review-b',
      ]);
      expect(
        orderEditor
            .tasksForStatus(ScrumTaskStatus.review)
            .map((task) => task.id),
        ['review-a', 'todo', 'review-b'],
      );
    });

    test('applies same-lane reorder as a reorder activity', () {
      final tasks = [
        task(id: 'a', status: ScrumTaskStatus.inProgress, sortOrder: 1000),
        task(id: 'b', status: ScrumTaskStatus.inProgress, sortOrder: 2000),
      ];
      final orderEditor = BoardTaskOrderEditor(tasks: tasks);
      final applier = BoardMoveApplier(
        tasks: tasks,
        config: const ScrumBoardConfig(),
        orderEditor: orderEditor,
      );

      final application = applier.apply(
        ScrumTaskMoveResult.moved(
          taskId: 'b',
          fromStatus: ScrumTaskStatus.inProgress,
          toStatus: ScrumTaskStatus.inProgress,
          targetCount: 2,
        ),
        beforeTaskId: 'a',
      );

      expect(application.activityType, ScrumActivityType.taskReordered);
      expect(application.changedTasks.map((task) => task.id), ['b', 'a']);
      expect(
        orderEditor
            .tasksForStatus(ScrumTaskStatus.inProgress)
            .map((task) => task.id),
        ['b', 'a'],
      );
    });
  });

  group('BoardMovePlanner', () {
    ScrumTask task({
      required String id,
      required ScrumTaskStatus status,
      int points = 3,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: points,
        createdAt: DateTime(2026, 1, 1),
        status: status,
        accentColor: Colors.blue,
      );
    }

    test('previews batch moves against projected WIP capacity', () {
      final planner = BoardMovePlanner(
        config: const ScrumBoardConfig(
          policy: ScrumWorkflowPolicy(
            wipLimits: {ScrumTaskStatus.inProgress: 2},
            enforceWipLimits: true,
          ),
        ),
        tasks: [
          task(id: 'active', status: ScrumTaskStatus.inProgress),
          task(id: 'first', status: ScrumTaskStatus.todo),
          task(id: 'second', status: ScrumTaskStatus.todo),
        ],
      );

      final preview = planner.previewTaskMoves([
        'first',
        'first',
        'second',
        'missing',
      ], ScrumTaskStatus.inProgress);

      expect(preview.results.map((result) => result.taskId), [
        'first',
        'second',
        'missing',
      ]);
      expect(preview.results[0].changed, isTrue);
      expect(preview.results[0].targetCount, 2);
      expect(preview.results[1].blockReason, ScrumTaskMoveBlockReason.wipLimit);
      expect(preview.results[1].targetCount, 3);
      expect(
        preview.results[2].blockReason,
        ScrumTaskMoveBlockReason.taskNotFound,
      );
    });

    test('allows same-lane reordering under enforced WIP limits', () {
      final planner = BoardMovePlanner(
        config: const ScrumBoardConfig(
          policy: ScrumWorkflowPolicy(
            wipLimits: {ScrumTaskStatus.inProgress: 1},
            enforceWipLimits: true,
          ),
        ),
        tasks: [
          task(id: 'first', status: ScrumTaskStatus.inProgress),
          task(id: 'second', status: ScrumTaskStatus.inProgress),
        ],
      );

      final result = planner.validateTaskMove(
        'second',
        ScrumTaskStatus.inProgress,
        beforeTaskId: 'first',
      );

      expect(result.accepted, isTrue);
      expect(result.changed, isTrue);
      expect(result.targetCount, 2);
      expect(result.targetLimit, 1);
    });
  });

  group('BoardActivityQuery', () {
    ScrumTask task({
      String id = 'task',
      ScrumTaskStatus status = ScrumTaskStatus.review,
      DateTime? createdAt,
      ScrumTaskPriority priority = ScrumTaskPriority.medium,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: createdAt ?? DateTime(2026, 1, 1),
        status: status,
        priority: priority,
        accentColor: Colors.blue,
      );
    }

    ScrumActivity activity({
      required String id,
      required ScrumActivityType type,
      required DateTime createdAt,
      String taskId = 'task',
      ScrumTaskStatus? toStatus,
    }) {
      return ScrumActivity(
        id: id,
        type: type,
        createdAt: createdAt,
        taskId: taskId,
        taskTitle: 'Task $taskId',
        toStatus: toStatus,
      );
    }

    test('normalizes activities newest first and deduplicates ids', () {
      final normalized = normalizedActivityList([
        activity(
          id: 'older',
          type: ScrumActivityType.taskCreated,
          createdAt: DateTime(2026, 1, 1, 9),
        ),
        activity(
          id: 'newer',
          type: ScrumActivityType.taskMoved,
          createdAt: DateTime(2026, 1, 2, 9),
        ),
        activity(
          id: 'older',
          type: ScrumActivityType.taskCommented,
          createdAt: DateTime(2026, 1, 3, 9),
        ),
      ]);

      expect(normalized.map((activity) => activity.id), ['newer', 'older']);
      expect(normalized.last.type, ScrumActivityType.taskCreated);
    });

    test('queries task history and classifies update activity types', () {
      final boardTask = task(
        status: ScrumTaskStatus.review,
        createdAt: DateTime(2026, 1, 1),
      );
      final query = BoardActivityQuery(
        activities: normalizedActivityList([
          activity(
            id: 'updated',
            type: ScrumActivityType.taskUpdated,
            createdAt: DateTime(2026, 1, 5),
            toStatus: ScrumTaskStatus.review,
          ),
          activity(
            id: 'moved',
            type: ScrumActivityType.taskMoved,
            createdAt: DateTime(2026, 1, 3),
            toStatus: ScrumTaskStatus.review,
          ),
          activity(
            id: 'created',
            type: ScrumActivityType.taskCreated,
            createdAt: DateTime(2026, 1, 1),
            toStatus: ScrumTaskStatus.todo,
          ),
        ]),
      );

      expect(query.recentActivities(limit: 1).single.id, 'updated');
      expect(query.activitiesForTask('task', limit: 2), hasLength(2));
      expect(query.statusStartedAtForTask(boardTask), DateTime(2026, 1, 3));
      expect(
        activityTypeForTaskUpdate(
          boardTask,
          boardTask.copyWith(priority: ScrumTaskPriority.critical),
        ),
        ScrumActivityType.taskPriorityChanged,
      );
      expect(
        activityTypeForTaskUpdate(
          boardTask,
          boardTask.copyWith(status: ScrumTaskStatus.done),
        ),
        ScrumActivityType.taskMoved,
      );
    });

    test('formats activity feed metadata with stable relative time', () {
      final now = DateTime(2026, 1, 2, 12);
      final movedActivity = ScrumActivity(
        id: 'moved',
        type: ScrumActivityType.taskMoved,
        createdAt: DateTime(2026, 1, 2, 10),
        taskId: 'checkout',
        taskTitle: 'Checkout copy',
        fromStatus: ScrumTaskStatus.todo,
        toStatus: ScrumTaskStatus.review,
        actor: 'Alya',
      );
      final priorityActivity = ScrumActivity(
        id: 'priority',
        type: ScrumActivityType.taskPriorityChanged,
        createdAt: DateTime(2026, 1, 2, 11, 55),
        taskId: 'checkout',
        taskTitle: 'Checkout copy',
        fromPriority: ScrumTaskPriority.medium,
        toPriority: ScrumTaskPriority.critical,
      );
      final noteActivity = ScrumActivity(
        id: 'note',
        type: ScrumActivityType.taskCommented,
        createdAt: DateTime(2026, 1, 2, 12, 1),
        taskId: 'checkout',
        taskTitle: 'Checkout copy',
        note: '  Waiting on design review.  ',
      );

      expect(
        activityFeedMetaText(movedActivity, (status) => status.label, now: now),
        'To Do to Review - Alya - 2h ago',
      );
      expect(
        activityFeedMetaText(
          priorityActivity,
          (status) => status.label,
          now: now,
        ),
        'Medium to Critical - 5m ago',
      );
      expect(
        activityFeedMetaText(noteActivity, (status) => status.label, now: now),
        'Waiting on design review. - Just now',
      );
    });

    test('counts and filters activity timeline types', () {
      final activities = [
        ScrumActivity(
          id: 'moved-1',
          type: ScrumActivityType.taskMoved,
          createdAt: DateTime(2026, 1, 2, 9),
        ),
        ScrumActivity(
          id: 'moved-2',
          type: ScrumActivityType.taskMoved,
          createdAt: DateTime(2026, 1, 2, 10),
        ),
        ScrumActivity(
          id: 'note',
          type: ScrumActivityType.taskCommented,
          createdAt: DateTime(2026, 1, 2, 11),
        ),
      ];

      final counts = activityTypeCounts(activities);

      expect(counts[ScrumActivityType.taskMoved], 2);
      expect(counts[ScrumActivityType.taskCommented], 1);
      expect(orderedVisibleActivityTypes(counts), [
        ScrumActivityType.taskMoved,
        ScrumActivityType.taskCommented,
      ]);
      expect(
        filterActivitiesByType(
          activities,
          ScrumActivityType.taskCommented,
        ).single.id,
        'note',
      );
      expect(filterActivitiesByType(activities, null), activities);
    });
  });

  group('BoardActivityRecorder', () {
    ScrumTask task({
      String id = 'task',
      ScrumTaskStatus status = ScrumTaskStatus.todo,
      ScrumTaskPriority priority = ScrumTaskPriority.medium,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
        priority: priority,
      );
    }

    test('records actor and task metadata with stable generated ids', () {
      final createdAt = DateTime(2026, 1, 2, 9);
      final activities = <ScrumActivity>[];
      final recorder = BoardActivityRecorder(
        activities: activities,
        clock: () => createdAt,
        actor: 'Alya',
      );
      final boardTask = task();

      final created = recorder.record(
        ScrumActivityType.taskCreated,
        task: boardTask,
        toStatus: ScrumTaskStatus.todo,
      );
      final commented = recorder.record(
        ScrumActivityType.taskCommented,
        task: boardTask,
        note: 'Ready for planning.',
      );

      expect(activities, [commented, created]);
      expect(created.id, 'activity-${createdAt.microsecondsSinceEpoch}-0');
      expect(commented.id, 'activity-${createdAt.microsecondsSinceEpoch}-1');
      expect(commented.actor, 'Alya');
      expect(commented.taskId, 'task');
      expect(commented.taskTitle, 'Task task');
      expect(commented.note, 'Ready for planning.');
    });

    test('records previous task metadata for deletion history', () {
      final activities = <ScrumActivity>[];
      final recorder = BoardActivityRecorder(
        activities: activities,
        clock: () => DateTime(2026, 1, 2, 10),
      );
      final deletedTask = task(id: 'deleted', status: ScrumTaskStatus.review);

      final activity = recorder.record(
        ScrumActivityType.taskDeleted,
        previousTask: deletedTask,
        fromStatus: ScrumTaskStatus.review,
      );

      expect(activity.taskId, 'deleted');
      expect(activity.taskTitle, 'Task deleted');
      expect(activity.fromStatus, ScrumTaskStatus.review);
      expect(activities.single, activity);
    });
  });

  group('BoardInteractionState', () {
    test('tracks selected tasks as a reusable presentation state', () {
      final state = BoardInteractionState();

      state.setTaskSelection('checkout', true);
      state.setTaskGroupSelection(['review', 'release', 'review'], true);
      state.setTaskSelection('review', false);
      state.removeSelectedTasks(['missing', 'release']);

      expect(state.selectedCount, 1);
      expect(state.hasSelection, isTrue);
      expect(state.selectedTaskIds, contains('checkout'));
      expect(state.selectedTaskIds, isNot(contains('review')));
      expect(state.selectedTaskIdList(), ['checkout']);

      state.clearSelection();

      expect(state.selectedTaskIds, isEmpty);
      expect(state.hasSelection, isFalse);
    });

    test('prunes deleted selections and exposes readonly selected ids', () {
      final state = BoardInteractionState();

      state.setTaskGroupSelection(['keep', 'drop'], true);
      state.pruneSelection((taskId) => taskId == 'keep');

      expect(state.selectedTaskIds, contains('keep'));
      expect(state.selectedTaskIds, isNot(contains('drop')));
      expect(
        () => state.selectedTaskIds.add('outside'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('tracks collapsed lane state across visible status changes', () {
      final state = BoardInteractionState();

      state.setColumnCollapsed(ScrumTaskStatus.todo, true);
      state.setVisibleColumnsCollapsed([
        ScrumTaskStatus.review,
        ScrumTaskStatus.done,
      ], true);
      state.setVisibleColumnsCollapsed([
        ScrumTaskStatus.todo,
        ScrumTaskStatus.review,
      ], false);
      state.retainCollapsedStatusesWhere(
        (status) => status != ScrumTaskStatus.done,
      );

      expect(state.collapsedStatuses, isEmpty);
    });
  });

  group('BoardFilterState', () {
    test('uses configured view preset before status fallback', () {
      final state = BoardFilterState(
        config: const ScrumBoardConfig(
          initialViewPresetId: 'critical',
          initialStatusFilter: ScrumTaskStatus.todo,
        ),
      );

      expect(state.filter.priorities, {ScrumTaskPriority.critical});
      expect(state.filter.status, isNull);
    });

    test(
      'falls back to a valid initial status and clears unavailable status',
      () {
        final state = BoardFilterState(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.review],
            initialStatusFilter: ScrumTaskStatus.review,
          ),
        );

        expect(state.filter.status, ScrumTaskStatus.review);

        state.reconcileConfig(
          const ScrumBoardConfig(statuses: [ScrumTaskStatus.todo]),
        );

        expect(state.filter.status, isNull);
      },
    );
  });

  group('BoardPersistenceQueue', () {
    test('runs queued writes sequentially', () async {
      final queue = BoardPersistenceQueue();
      final events = <String>[];

      queue.queue(() async {
        events.add('first-start');
        await Future<void>.delayed(Duration.zero);
        events.add('first-end');
      });
      queue.queue(() async {
        events.add('second-start');
      });

      await queue.pending;

      expect(events, ['first-start', 'first-end', 'second-start']);
      expect(queue.lastError, isNull);
    });

    test('tracks write errors and clears them after a later success', () async {
      final queue = BoardPersistenceQueue();
      var errorTransitions = 0;

      await queue.queue(
        () async => throw StateError('write failed'),
        onErrorChanged: () => errorTransitions += 1,
      );

      expect(queue.lastError, isA<StateError>());

      await queue.queue(
        () async {},
        onErrorChanged: () => errorTransitions += 1,
      );

      expect(queue.lastError, isNull);
      expect(errorTransitions, 2);
    });
  });

  group('BoardPersistenceWriter', () {
    ScrumTask task({
      required String id,
      ScrumTaskStatus status = ScrumTaskStatus.todo,
    }) {
      return ScrumTask(
        id: id,
        title: 'Task $id',
        description: 'Description $id',
        assignee: 'Team',
        storyPoints: 3,
        createdAt: DateTime(2026, 1),
        status: status,
      );
    }

    test('writes task and activity changes through repositories', () async {
      final taskRepository = InMemoryScrumTaskRepository();
      final activityRepository = InMemoryScrumActivityRepository();
      final writer = BoardPersistenceWriter(
        taskRepository: taskRepository,
        activityRepository: activityRepository,
      );
      final activity = ScrumActivity(
        id: 'activity',
        type: ScrumActivityType.taskCreated,
        createdAt: DateTime(2026, 1, 2),
        taskId: 'kept',
      );

      await writer.replaceTasks([task(id: 'old')]);
      await writer.queueTaskWrites([
        task(id: 'kept', status: ScrumTaskStatus.done),
        task(id: 'deleted', status: ScrumTaskStatus.review),
      ]);
      await writer.queueTaskDelete('deleted');
      await writer.queueActivityWrite(activity);
      await writer.pending;

      final persistedTasks = await taskRepository.loadTasks();
      final persistedActivities = await activityRepository.loadActivities();

      expect(writer.hasTaskRepository, isTrue);
      expect(writer.hasActivityRepository, isTrue);
      expect(persistedTasks.map((task) => task.id), ['old', 'kept']);
      expect(persistedTasks.last.status, ScrumTaskStatus.done);
      expect(persistedActivities.single, activity);
    });

    test('deduplicates task write batches before repository upserts', () async {
      final taskRepository = _RecordingScrumTaskRepository();
      final writer = BoardPersistenceWriter(taskRepository: taskRepository);

      await writer.queueTaskWrites([
        task(id: 'dup'),
        task(id: 'keep', status: ScrumTaskStatus.review),
        task(id: 'dup', status: ScrumTaskStatus.done),
      ]);
      await writer.pending;

      expect(taskRepository.upsertedTasks.map((task) => task.id), [
        'dup',
        'keep',
      ]);
      expect(taskRepository.upsertedTasks.first.status, ScrumTaskStatus.done);
      expect(taskRepository.upsertedTasks.last.status, ScrumTaskStatus.review);
    });
  });

  group('BoardLoadCoordinator', () {
    test('loads values and reports loading transitions', () async {
      final writer = BoardPersistenceWriter();
      late final BoardLoadCoordinator coordinator;
      final loadingStates = <bool>[];
      final loadedValues = <int>[];
      coordinator = BoardLoadCoordinator(
        persistenceWriter: writer,
        onLoadingChanged: () => loadingStates.add(coordinator.isLoading),
      );

      await coordinator.load<int>(() async => 7, apply: loadedValues.add);

      expect(loadedValues, [7]);
      expect(loadingStates, [true, false]);
      expect(coordinator.isLoading, isFalse);
      expect(writer.lastError, isNull);
    });

    test('tracks load errors and resets loading state', () async {
      final writer = BoardPersistenceWriter();
      late final BoardLoadCoordinator coordinator;
      final loadingStates = <bool>[];
      coordinator = BoardLoadCoordinator(
        persistenceWriter: writer,
        onLoadingChanged: () => loadingStates.add(coordinator.isLoading),
      );

      await expectLater(
        coordinator.load<int>(
          () async => throw StateError('load failed'),
          apply: (_) {},
        ),
        throwsA(isA<StateError>()),
      );

      expect(loadingStates, [true, false]);
      expect(coordinator.isLoading, isFalse);
      expect(writer.lastError, isA<StateError>());

      await coordinator.load<int>(() async => 9, apply: (_) {});

      expect(writer.lastError, isNull);
    });
  });

  testWidgets('renders the scrumboard screen', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'task',
                title: 'Route scrumboard into sidebar',
                description: 'Expose a reusable board from the package.',
                assignee: 'Team',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Scrum Board'), findsOneWidget);
    expect(find.text('Sprint Intelligence'), findsOneWidget);
    expect(find.text('Route scrumboard into sidebar'), findsOneWidget);
  });

  testWidgets('renders the extracted board viewport', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'viewport-task',
          title: 'Viewport-owned lane layout',
          description: 'Keep board layout separate from screen orchestration.',
          assignee: 'Team',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrumBoardViewport(
            controller: controller,
            config: const ScrumBoardConfig(),
            filter: const ScrumBoardFilter(),
            selectedTaskIds: const {},
            collapsedStatuses: const {},
            onFilterChanged: (_) {},
            onColumnCollapsedChanged: (_, _) {},
            onVisibleColumnsCollapsedChanged: (_, _) {},
            onCreateTask: ({ScrumTaskStatus? status}) {},
            onTaskPressed: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('Sprint Intelligence'), findsOneWidget);
    expect(find.text('Viewport-owned lane layout'), findsOneWidget);
    expect(find.byTooltip('Collapse visible lanes'), findsOneWidget);
  });

  testWidgets('composes extracted lane surface controls', (tester) async {
    tester.view.physicalSize = const Size(620, 220);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Iterable<ScrumTaskStatus>? changedStatuses;
    bool? collapsedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 180,
            child: BoardLaneSurface(
              statuses: const [ScrumTaskStatus.todo, ScrumTaskStatus.review],
              collapsedStatuses: const {ScrumTaskStatus.review},
              onCollapsedChanged: (statuses, collapsed) {
                changedStatuses = statuses;
                collapsedValue = collapsed;
              },
              child: const Center(child: Text('Lane content')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Lane content'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand visible lanes'));
    expect(changedStatuses, [ScrumTaskStatus.todo, ScrumTaskStatus.review]);
    expect(collapsedValue, isFalse);

    await tester.tap(find.byTooltip('Collapse visible lanes'));
    expect(collapsedValue, isTrue);
  });

  testWidgets('renders the extracted lane collection', (tester) async {
    tester.view.physicalSize = const Size(920, 620);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    ScrumTaskStatus? createdStatus;
    ScrumTask? pressedTask;
    ScrumTaskStatus? collapsedStatus;
    bool? collapsedValue;
    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'lane-task',
          title: 'Collection-owned lane task',
          description: 'Lane collection renders this task.',
          assignee: 'Team',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BoardLaneCollection(
            controller: controller,
            config: const ScrumBoardConfig(
              statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.review],
              showInsights: false,
            ),
            filter: const ScrumBoardFilter(),
            statuses: const [ScrumTaskStatus.todo, ScrumTaskStatus.review],
            compact: false,
            selectedTaskIds: const {},
            collapsedStatuses: const {},
            onFilterChanged: (_) {},
            onColumnCollapsedChanged: (status, collapsed) {
              collapsedStatus = status;
              collapsedValue = collapsed;
            },
            onCreateTask: ({ScrumTaskStatus? status}) {
              createdStatus = status;
            },
            onTaskPressed: (task) => pressedTask = task,
          ),
        ),
      ),
    );

    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Collection-owned lane task'), findsOneWidget);

    await tester.tap(find.byTooltip('Add task').first);
    expect(createdStatus, ScrumTaskStatus.todo);

    await tester.tap(find.text('Collection-owned lane task'));
    expect(pressedTask?.id, 'lane-task');

    await tester.tap(find.byTooltip('Collapse To Do'));
    expect(collapsedStatus, ScrumTaskStatus.todo);
    expect(collapsedValue, isTrue);
  });

  testWidgets('renders the extracted lane task list', (tester) async {
    tester.view.physicalSize = const Size(420, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    ScrumTask? pressedTask;
    bool? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 340,
            height: 360,
            child: BoardLaneTaskList(
              color: const Color(0xFF2563EB),
              tasks: [
                ScrumTask(
                  id: 'task-list-card',
                  title: 'Task list card',
                  description: 'Rendered by the extracted task list.',
                  assignee: 'Alya',
                  storyPoints: 5,
                  createdAt: DateTime(2026, 1, 1),
                  status: ScrumTaskStatus.review,
                  priority: ScrumTaskPriority.high,
                  label: 'Payments',
                  accentColor: const Color(0xFF2563EB),
                ),
              ],
              statusLabel: 'Review',
              storyPoints: 5,
              hiddenTaskCount: 0,
              collapsed: false,
              selectedTaskIds: const {'task-list-card'},
              onTaskDropped: (_, _) {},
              onTaskPressed: (task) => pressedTask = task,
              onTaskSelectionChanged: (_, selected) {
                selectedValue = selected;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Task list card'), findsOneWidget);
    expect(find.text('Drop at end'), findsOneWidget);

    await tester.tap(find.byTooltip('Deselect task'));
    expect(selectedValue, isFalse);

    await tester.tap(find.text('Task list card'));
    expect(pressedTask?.id, 'task-list-card');
  });

  testWidgets('renders extracted lane header metrics', (tester) async {
    tester.view.physicalSize = const Size(320, 120);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BoardLaneMetaText(
                  count: 6,
                  storyPoints: 21,
                  wipLimit: 5,
                  overLimit: true,
                ),
                SizedBox(height: 12),
                BoardLaneCapacityMeter(
                  count: 6,
                  limit: 5,
                  color: Color(0xFF2563EB),
                  overLimit: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('6/5 tasks · 21 SP'), findsOneWidget);
    expect(find.byTooltip('WIP capacity: 6 of 5 tasks'), findsOneWidget);
  });

  testWidgets('composes extracted toolbar controls', (tester) async {
    tester.view.physicalSize = const Size(1200, 260);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var changedFilter = const ScrumBoardFilter();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrumBoardToolbar(
            filter: const ScrumBoardFilter(),
            statuses: const [
              ScrumTaskStatus.todo,
              ScrumTaskStatus.inProgress,
              ScrumTaskStatus.review,
            ],
            statusCounts: const {
              ScrumTaskStatus.todo: 2,
              ScrumTaskStatus.inProgress: 1,
              ScrumTaskStatus.review: 3,
            },
            viewPresets: defaultScrumBoardViewPresets,
            assignees: const ['Alya', 'Bima'],
            showPriorityFilter: true,
            showAssigneeFilter: true,
            showSortControl: true,
            showViewPresets: true,
            statusLabelFor: (status) => status.label,
            onFilterChanged: (filter) => changedFilter = filter,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'api');
    expect(changedFilter.query, 'api');

    await tester.tap(find.text('Review'));
    expect(changedFilter.status, ScrumTaskStatus.review);
    expect(find.byTooltip('Sort tasks'), findsOneWidget);
    expect(find.byTooltip('Board views'), findsOneWidget);
  });

  testWidgets('renders extracted bulk selection summary', (tester) async {
    var cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BulkSelectionSummary(
              selectedCount: 3,
              onClearSelection: () => cleared = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('3 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear selection'));

    expect(cleared, isTrue);
  });

  testWidgets('wires extracted bulk action buttons', (tester) async {
    ScrumTaskStatus? movedStatus;
    ScrumTaskPriority? changedPriority;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Wrap(
              children: [
                BulkStatusMenuButton(
                  statuses: const [ScrumTaskStatus.todo, ScrumTaskStatus.done],
                  statusLabelFor: (status) => status.label,
                  onMoveToStatus: (status) => movedStatus = status,
                ),
                BulkPriorityMenuButton(
                  onPriorityChanged: (priority) => changedPriority = priority,
                ),
                BulkDeleteButton(onPressed: () => deleted = true),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Move selected tasks'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(PopupMenuItem<ScrumTaskStatus>, 'Done'),
    );
    await tester.pumpAndSettle();

    expect(movedStatus, ScrumTaskStatus.done);

    await tester.tap(find.byTooltip('Set selected priority'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(PopupMenuItem<ScrumTaskPriority>, 'Critical'),
    );
    await tester.pumpAndSettle();

    expect(changedPriority, ScrumTaskPriority.critical);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));

    expect(deleted, isTrue);
  });

  testWidgets('renders extracted activity feed row', (tester) async {
    final now = DateTime(2026, 1, 2, 12);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ActivityFeedRow(
              activity: ScrumActivity(
                id: 'activity-row',
                type: ScrumActivityType.taskMoved,
                createdAt: DateTime(2026, 1, 2, 10),
                taskId: 'checkout',
                taskTitle: 'Checkout copy',
                fromStatus: ScrumTaskStatus.todo,
                toStatus: ScrumTaskStatus.review,
                actor: 'Alya',
              ),
              statusLabelFor: (status) => status.label,
              now: now,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Moved task'), findsOneWidget);
    expect(find.text('Checkout copy'), findsOneWidget);
    expect(find.text('To Do to Review - Alya - 2h ago'), findsOneWidget);
  });

  testWidgets('wires extracted activity filter controls', (tester) async {
    ScrumActivityType? selectedType = ScrumActivityType.taskMoved;
    final activities = [
      ScrumActivity(
        id: 'moved',
        type: ScrumActivityType.taskMoved,
        createdAt: DateTime(2026, 1, 2, 9),
      ),
      ScrumActivity(
        id: 'priority',
        type: ScrumActivityType.taskPriorityChanged,
        createdAt: DateTime(2026, 1, 2, 10),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityFilterControls(
            activities: activities,
            selectedType: selectedType,
            onSelectedTypeChanged: (type) => selectedType = type,
          ),
        ),
      ),
    );

    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Moved task 1'), findsOneWidget);
    expect(find.text('Changed priority 1'), findsOneWidget);

    await tester.tap(find.text('Changed priority 1'));

    expect(selectedType, ScrumActivityType.taskPriorityChanged);

    await tester.tap(find.text('All 2'));

    expect(selectedType, isNull);
  });

  testWidgets('wires extracted task detail action menus', (tester) async {
    ScrumTaskStatus? movedStatus;
    ScrumTaskPriority? changedPriority;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Wrap(
              children: [
                TaskDetailMoveMenu(
                  statuses: const [
                    ScrumTaskStatus.review,
                    ScrumTaskStatus.done,
                  ],
                  statusLabelFor: (status) => status.label,
                  onMove: (status) => movedStatus = status,
                ),
                TaskDetailPriorityMenu(
                  priorities: const [
                    ScrumTaskPriority.high,
                    ScrumTaskPriority.critical,
                  ],
                  onPriorityChanged: (priority) => changedPriority = priority,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Move task'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(PopupMenuItem<ScrumTaskStatus>, 'Done'),
    );
    await tester.pumpAndSettle();

    expect(movedStatus, ScrumTaskStatus.done);

    await tester.tap(find.byTooltip('Change priority'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(PopupMenuItem<ScrumTaskPriority>, 'Critical'),
    );
    await tester.pumpAndSettle();

    expect(changedPriority, ScrumTaskPriority.critical);
  });

  testWidgets('renders extracted task detail panel shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskDetailPanelShell(
            header: const Text('Shell header'),
            content: const Text('Shell content'),
            actions: TextButton(onPressed: () {}, child: const Text('Done')),
          ),
        ),
      ),
    );

    expect(find.text('Shell header'), findsOneWidget);
    expect(find.text('Shell content'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Done'), findsOneWidget);
  });

  testWidgets('renders public task detail dialog widget directly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrumTaskDetailDialog(
            task: ScrumTask(
              id: 'direct-detail',
              title: 'Direct detail task',
              description: 'The public detail dialog composes the shell.',
              assignee: 'Alya',
              storyPoints: 3,
              createdAt: DateTime(2026, 1, 1),
              status: ScrumTaskStatus.todo,
            ),
            activities: const [],
            statuses: const [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            statusLabelFor: (status) => status.label,
            dueSoonDays: 2,
            reviewAgeWarningDays: 3,
          ),
        ),
      ),
    );

    expect(find.text('Direct detail task'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(
      find.text('The public detail dialog composes the shell.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Close task details'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('renders extracted task detail content sections', (tester) async {
    final task = ScrumTask(
      id: 'section-detail',
      title: 'Section detail task',
      description: 'The extracted sections should compose task details.',
      assignee: 'Alya',
      storyPoints: 8,
      createdAt: DateTime(2026, 1, 1),
      dueAt: DateTime(2026, 1, 9),
      status: ScrumTaskStatus.review,
      priority: ScrumTaskPriority.critical,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskDetailSummaryPills(
                task: task,
                statusLabelFor: (status) => status.label,
              ),
              TaskDetailSignalSection(
                task: task,
                dueSoonDays: 2,
                reviewAgeWarningDays: 3,
                statusLabel: 'Review',
                statusStartedAt: DateTime(2026, 1, 5),
                now: DateTime(2026, 1, 10),
              ),
              TaskDetailDescriptionSection(description: task.description),
              TaskDetailMetadataSection(task: task),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('8 story points'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(
      find.text('The extracted sections should compose task details.'),
      findsOneWidget,
    );
    expect(find.text('Assignee'), findsOneWidget);
    expect(find.text('Alya'), findsOneWidget);
    expect(find.text('Created'), findsOneWidget);
    expect(find.text('1/1/2026'), findsOneWidget);
    expect(find.text('Due date'), findsOneWidget);
    expect(find.text('9/1/2026'), findsOneWidget);
  });

  testWidgets('renders shared task detail primitives', (tester) async {
    expect(scrumTaskDetailInitials('Alya Rahman'), 'AR');
    expect(scrumTaskDetailInitials('Alya'), 'A');
    expect(scrumTaskDetailInitials('   '), '?');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScrumTaskDetailPill(label: 'High', color: Color(0xFFDC2626)),
              ScrumTaskDetailValue(label: 'Assignee', value: 'Alya Rahman'),
              ScrumTaskDetailAvatar(
                name: 'Alya Rahman',
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('High'), findsOneWidget);
    expect(find.text('Assignee'), findsOneWidget);
    expect(find.text('Alya Rahman'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
  });

  testWidgets('wires extracted advanced filter controls', (tester) async {
    tester.view.physicalSize = const Size(920, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var changedFilter = const ScrumBoardFilter();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ScrumBoardFilterControls(
              filter: const ScrumBoardFilter(),
              viewPresets: defaultScrumBoardViewPresets,
              assignees: const ['Alya', 'Bima'],
              showPriorityFilter: true,
              showAssigneeFilter: true,
              showSortControl: true,
              showViewPresets: true,
              onFilterChanged: (filter) => changedFilter = filter,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Critical'));
    expect(changedFilter.priorities, contains(ScrumTaskPriority.critical));

    await tester.tap(find.byTooltip('Filter assignees'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckedPopupMenuItem<String>, 'Bima'));
    await tester.pumpAndSettle();
    expect(changedFilter.assignees, contains('Bima'));

    await tester.tap(find.byTooltip('Sort tasks'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<ScrumTaskSort>, 'Priority'),
    );
    await tester.pumpAndSettle();
    expect(changedFilter.sort, ScrumTaskSort.priority);
  });

  testWidgets('composes extracted board column pieces', (tester) async {
    tester.view.physicalSize = const Size(420, 620);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var addRequested = false;
    var collapseRequested = false;
    var batchSelectionRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ScrumBoardColumn(
              width: 320,
              height: 520,
              status: ScrumTaskStatus.todo,
              statusLabel: 'To Do',
              tasks: [
                ScrumTask(
                  id: 'column-task',
                  title: 'Extract lane presentation widgets',
                  description: 'Keep lane chrome reusable and testable.',
                  assignee: 'Team',
                  storyPoints: 5,
                  createdAt: DateTime(2026, 1, 1),
                  status: ScrumTaskStatus.todo,
                ),
              ],
              storyPoints: 5,
              health: const ScrumLaneHealth(
                overdueTasks: 0,
                dueSoonTasks: 1,
                agedReviewTasks: 0,
              ),
              wipLimit: 2,
              enforceWipLimit: true,
              onAddTask: () => addRequested = true,
              onTaskPressed: (_) {},
              onTaskDropped: (_, _) {},
              onTaskBatchSelectionChanged: (_, _) {
                batchSelectionRequested = true;
              },
              onCollapsedChanged: (_) => collapseRequested = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('To Do'), findsOneWidget);
    expect(find.text('Extract lane presentation widgets'), findsOneWidget);
    expect(find.byTooltip('WIP limit enforced'), findsOneWidget);
    expect(find.byTooltip('Select To Do tasks'), findsOneWidget);
    expect(find.byTooltip('Collapse To Do'), findsOneWidget);

    await tester.tap(find.byTooltip('Add task'));
    await tester.tap(find.byTooltip('Select To Do tasks'));
    await tester.tap(find.byTooltip('Collapse To Do'));

    expect(addRequested, isTrue);
    expect(batchSelectionRequested, isTrue);
    expect(collapseRequested, isTrue);
  });

  testWidgets('composes extracted task card sections', (tester) async {
    tester.view.physicalSize = const Size(420, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var cardPressed = false;
    bool? selectedValue;
    final now = DateTime(2026, 1, 10);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ScrumTaskCard(
                task: ScrumTask(
                  id: 'card-test',
                  title: 'Checkout readiness review',
                  description: 'Validate payment copy and release signals.',
                  assignee: 'Alya Rahman',
                  storyPoints: 5,
                  createdAt: DateTime(2026, 1, 3),
                  dueAt: now.add(const Duration(days: 1)),
                  status: ScrumTaskStatus.review,
                  priority: ScrumTaskPriority.high,
                  label: 'Payments',
                  accentColor: const Color(0xFF2563EB),
                ),
                selected: true,
                statusStartedAt: DateTime(2026, 1, 6),
                statusLabel: 'Review',
                now: now,
                onPressed: () => cardPressed = true,
                onSelectedChanged: (selected) => selectedValue = selected,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('5 SP'), findsOneWidget);
    expect(find.text('Checkout readiness review'), findsOneWidget);
    expect(find.text('Alya Rahman'), findsOneWidget);
    expect(find.text('Due in 1d'), findsOneWidget);
    expect(find.text('Review 4d'), findsOneWidget);

    await tester.tap(find.byTooltip('Deselect task'));
    expect(selectedValue, isFalse);

    await tester.tap(find.text('Checkout readiness review'));
    expect(cardPressed, isTrue);
  });

  testWidgets('creates tasks from the modular task editor', (tester) async {
    tester.view.physicalSize = const Size(900, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    ScrumTask? createdTask;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () {
                    showScrumTaskEditor(
                      context,
                      initialStatus: ScrumTaskStatus.review,
                      statuses: const [
                        ScrumTaskStatus.todo,
                        ScrumTaskStatus.review,
                      ],
                    ).then((task) => createdTask = task);
                  },
                  child: const Text('Open editor'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(6));
    await tester.enterText(fields.at(0), 'Editor-created task');
    await tester.enterText(fields.at(1), 'Created through the modular editor.');
    await tester.enterText(fields.at(2), 'Alya');
    await tester.enterText(fields.at(3), '8');
    await tester.enterText(fields.at(4), 'Payments');
    await tester.enterText(fields.at(5), '2026-01-12');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(createdTask, isNotNull);
    expect(createdTask?.title, 'Editor-created task');
    expect(createdTask?.description, 'Created through the modular editor.');
    expect(createdTask?.assignee, 'Alya');
    expect(createdTask?.status, ScrumTaskStatus.review);
    expect(createdTask?.storyPoints, 8);
    expect(createdTask?.label, 'Payments');
    expect(createdTask?.dueAt, DateTime(2026, 1, 12));
  });

  testWidgets('composes extracted insights panel sections', (tester) async {
    tester.view.physicalSize = const Size(460, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: ScrumBoardInsightsPanel(
                summary: const ScrumBoardSummary(
                  totalTasks: 8,
                  completedTasks: 3,
                  activeTasks: 5,
                  totalStoryPoints: 21,
                  completedStoryPoints: 8,
                  activeStoryPoints: 13,
                  tasksByStatus: {
                    ScrumTaskStatus.todo: 2,
                    ScrumTaskStatus.inProgress: 2,
                    ScrumTaskStatus.review: 1,
                    ScrumTaskStatus.done: 3,
                  },
                ),
                sprint: ScrumSprint(
                  id: 'sprint-test',
                  name: 'Modularity Sprint',
                  goal: 'Keep insights reusable and easy to test.',
                  startAt: DateTime(2026, 1, 1),
                  endAt: DateTime(2026, 1, 14),
                  capacityStoryPoints: 24,
                  velocityTargetStoryPoints: 12,
                ),
                insights: const [
                  ScrumBoardInsight(
                    key: 'review-pressure',
                    title: 'Review needs attention',
                    description: 'Two tasks are waiting for validation.',
                    severity: ScrumBoardInsightSeverity.warning,
                  ),
                ],
                recentActivities: [
                  ScrumActivity(
                    id: 'activity-test',
                    type: ScrumActivityType.taskMoved,
                    createdAt: DateTime(2026, 1, 4, 9),
                    taskId: 'task-test',
                    taskTitle: 'Refactor insights panel',
                    fromStatus: ScrumTaskStatus.inProgress,
                    toStatus: ScrumTaskStatus.review,
                  ),
                ],
                assigneeLoads: const [
                  ScrumAssigneeLoad(
                    assignee: 'Alya',
                    activeTasks: 2,
                    activeStoryPoints: 8,
                    criticalTasks: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sprint Intelligence'), findsOneWidget);
    expect(find.text('Modularity Sprint'), findsOneWidget);
    expect(find.text('Flow signals'), findsOneWidget);
    expect(find.text('Review needs attention'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Workload'), findsOneWidget);
    expect(find.text('Alya'), findsOneWidget);
  });

  testWidgets('renders configured sprint context', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: ScrumBoardConfig(
            sprint: ScrumSprint(
              id: 'sprint-foundation',
              name: 'Foundation Sprint',
              goal: 'Make delivery visible',
              startAt: DateTime(2026, 1, 1),
              endAt: DateTime(2026, 1, 14),
              capacityStoryPoints: 10,
              velocityTargetStoryPoints: 6,
            ),
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'task',
                title: 'Sprint-aware board',
                description: 'Expose sprint goal and progress.',
                assignee: 'Team',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.textContaining('Make delivery visible'), findsWidgets);
    expect(find.text('Foundation Sprint'), findsOneWidget);
  });

  testWidgets('renders recent activity in the intelligence panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'task',
          title: 'Track board activity',
          description: 'Show recent scrumboard changes.',
          assignee: 'Team',
          storyPoints: 5,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
      clock: () => DateTime(2026, 1, 2, 9),
    );
    controller.moveTask('task', ScrumTaskStatus.review);
    controller.updateTaskPriorities(['task'], ScrumTaskPriority.critical);

    await tester.pumpWidget(
      MaterialApp(home: ScrumBoardScreen(controller: controller)),
    );

    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Moved task 1'), findsOneWidget);
    expect(find.text('Changed priority 1'), findsOneWidget);
    expect(find.text('Changed priority'), findsOneWidget);
    expect(find.textContaining('Medium to Critical'), findsOneWidget);
    expect(find.text('Moved task'), findsOneWidget);
    expect(find.textContaining('Placed at the end of Review.'), findsOneWidget);
    expect(find.text('Track board activity'), findsWidgets);

    await tester.tap(find.text('Moved task 1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Placed at the end of Review.'), findsOneWidget);
    expect(find.textContaining('Medium to Critical'), findsNothing);

    await tester.tap(find.text('All 2'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Medium to Critical'), findsOneWidget);
  });

  testWidgets('surfaces due-date urgency on task cards', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final today = DateTime.now();

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'overdue',
                title: 'Overdue card',
                description: 'This task should show an overdue badge.',
                assignee: 'Alya',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                dueAt: today.subtract(const Duration(days: 1)),
                status: ScrumTaskStatus.todo,
              ),
              ScrumTask(
                id: 'soon',
                title: 'Due soon card',
                description: 'This task should show a due-soon badge.',
                assignee: 'Bayu',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                dueAt: today.add(const Duration(days: 1)),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Due in 1d'), findsOneWidget);
  });

  testWidgets('surfaces task signal badges in task details', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    final today = DateTime.now();
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
            policy: ScrumWorkflowPolicy(dueSoonDays: 2),
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'detail-signal',
                title: 'Detail due soon task',
                description: 'The detail dialog should repeat task signals.',
                assignee: 'Alya',
                storyPoints: 3,
                createdAt: today,
                dueAt: today.add(const Duration(days: 1)),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Due in 1d'), findsOneWidget);

    await tester.tap(find.text('Detail due soon task'));
    await tester.pumpAndSettle();

    expect(find.text('Description'), findsOneWidget);
    expect(find.byTooltip('Close task details'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Due in 1d'), findsNWidgets(2));
  });

  testWidgets('filters task activity in the task detail panel', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'detail-activity',
          title: 'Detail activity task',
          description: 'This task has several activity types.',
          assignee: 'Alya',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
          priority: ScrumTaskPriority.medium,
        ),
      ],
      clock: () => DateTime(2026, 1, 2, 9),
    );
    controller.updateTaskPriorities([
      'detail-activity',
    ], ScrumTaskPriority.critical);
    controller.addTaskNote('detail-activity', 'Waiting on design review.');

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.text('Detail activity task'));
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Changed priority 1'), findsOneWidget);
    expect(find.text('Added note 1'), findsOneWidget);
    expect(find.textContaining('Medium to Critical'), findsOneWidget);
    expect(find.textContaining('Waiting on design review.'), findsOneWidget);

    await tester.tap(find.text('Added note 1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Waiting on design review.'), findsOneWidget);
    expect(find.textContaining('Medium to Critical'), findsNothing);
  });

  testWidgets('moves a task from the task detail panel', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'detail-move',
          title: 'Detail move task',
          description: 'This task should move from the detail panel.',
          assignee: 'Alya',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.text('Detail move task'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Move task'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is PopupMenuItem<ScrumTaskStatus> &&
            widget.value == ScrumTaskStatus.done,
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.taskById('detail-move')?.status, ScrumTaskStatus.done);
    expect(find.text('1 task moved to Done.'), findsOneWidget);
  });

  testWidgets('changes task priority from the task detail panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'detail-priority',
          title: 'Detail priority task',
          description: 'This task should change priority from details.',
          assignee: 'Alya',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
          priority: ScrumTaskPriority.medium,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.text('Detail priority task'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Change priority'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is PopupMenuItem<ScrumTaskPriority> &&
            widget.value == ScrumTaskPriority.critical,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      controller.taskById('detail-priority')?.priority,
      ScrumTaskPriority.critical,
    );
    expect(
      controller.activities.first.type,
      ScrumActivityType.taskPriorityChanged,
    );
    expect(controller.activities.first.fromPriority, ScrumTaskPriority.medium);
    expect(controller.activities.first.toPriority, ScrumTaskPriority.critical);
    expect(find.text('Task priority changed to Critical.'), findsOneWidget);
  });

  testWidgets('adds a task note from the task detail panel', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'detail-note',
          title: 'Detail note task',
          description: 'This task should accept a lightweight note.',
          assignee: 'Alya',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.text('Detail note task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Note'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Note',
      ),
      'Waiting on stakeholder approval.',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add note'));
    await tester.pumpAndSettle();

    expect(controller.activities, hasLength(1));
    expect(controller.activities.first.type, ScrumActivityType.taskCommented);
    expect(
      controller.activities.first.note,
      'Waiting on stakeholder approval.',
    );
    expect(find.text('Task note added.'), findsOneWidget);
  });

  testWidgets('surfaces aged review work on task cards', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.review],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'aged-review',
                title: 'Aged review card',
                description: 'This task has waited in review.',
                assignee: 'Alya',
                storyPoints: 5,
                createdAt: DateTime.now().subtract(const Duration(days: 4)),
                status: ScrumTaskStatus.review,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Review 4d'), findsOneWidget);
    expect(find.byTooltip('Review for 4d'), findsOneWidget);
  });

  testWidgets('surfaces lane health signals in column headers', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    final today = DateTime.now();
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.review],
            showInsights: false,
            policy: ScrumWorkflowPolicy(
              dueSoonDays: 2,
              reviewAgeWarningDays: 3,
            ),
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'overdue',
                title: 'Overdue lane task',
                description: 'This task should count in lane health.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: today,
                dueAt: today.subtract(const Duration(days: 1)),
                status: ScrumTaskStatus.todo,
              ),
              ScrumTask(
                id: 'soon',
                title: 'Due soon lane task',
                description: 'This task should count in lane health.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: today,
                dueAt: today.add(const Duration(days: 1)),
                status: ScrumTaskStatus.todo,
              ),
              ScrumTask(
                id: 'aging',
                title: 'Aging review task',
                description: 'This task should count in lane health.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: today.subtract(const Duration(days: 5)),
                status: ScrumTaskStatus.review,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.text('1 due soon'), findsOneWidget);
    expect(find.text('1 aging'), findsOneWidget);
  });

  testWidgets('filters visible tasks by priority chip', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'critical',
                title: 'Priority incident',
                description: 'A blocking issue needs focus.',
                assignee: 'Alya',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.critical,
              ),
              ScrumTask(
                id: 'low',
                title: 'Quiet cleanup',
                description: 'A small follow-up can wait.',
                assignee: 'Bayu',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.low,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Priority incident'), findsOneWidget);
    expect(find.text('Quiet cleanup'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Critical'));
    await tester.pumpAndSettle();

    expect(find.text('Priority incident'), findsOneWidget);
    expect(find.text('Quiet cleanup'), findsNothing);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('shows live status counts in filter chips', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'critical',
                title: 'Counted critical task',
                description: 'This task is critical and todo.',
                assignee: 'Alya',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.critical,
              ),
              ScrumTask(
                id: 'low',
                title: 'Counted low task',
                description: 'This task is low and todo.',
                assignee: 'Bayu',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.low,
              ),
              ScrumTask(
                id: 'done',
                title: 'Counted done task',
                description: 'This task is done and low.',
                assignee: 'Citra',
                storyPoints: 1,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.done,
                priority: ScrumTaskPriority.low,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('All: 3 tasks'), findsOneWidget);
    expect(find.byTooltip('To Do: 2 tasks'), findsOneWidget);
    expect(find.byTooltip('Done: 1 task'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Critical'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('All: 1 task'), findsOneWidget);
    expect(find.byTooltip('To Do: 1 task'), findsOneWidget);
    expect(find.byTooltip('Done: 0 tasks'), findsOneWidget);
  });

  testWidgets('removes active filter chips from the summary bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'critical',
                title: 'Active chip incident',
                description: 'A blocking issue needs focus.',
                assignee: 'Alya',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.critical,
              ),
              ScrumTask(
                id: 'low',
                title: 'Active chip cleanup',
                description: 'A small follow-up can wait.',
                assignee: 'Bayu',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.low,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Critical'));
    await tester.pumpAndSettle();

    expect(find.text('Active chip incident'), findsOneWidget);
    expect(find.text('Active chip cleanup'), findsNothing);
    expect(find.byTooltip('Remove Critical priority filter'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove Critical priority filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active chip incident'), findsOneWidget);
    expect(find.text('Active chip cleanup'), findsOneWidget);
    expect(find.byTooltip('Remove Critical priority filter'), findsNothing);
  });

  testWidgets('explains filtered empty lanes and clears task facets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'low',
                title: 'Filtered lane task',
                description: 'This task is hidden by the selected priority.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.low,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Critical'));
    await tester.pumpAndSettle();

    expect(find.text('Filtered lane task'), findsNothing);
    expect(find.text('No matching tasks'), findsOneWidget);
    expect(find.text('1 task is hidden by filters.'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Show all tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Filtered lane task'), findsOneWidget);
    expect(find.text('No matching tasks'), findsNothing);
  });

  testWidgets('sorts visible tasks from the toolbar menu', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'low',
                title: 'Low priority task',
                description: 'Routine follow-up.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.low,
                sortOrder: 1000,
              ),
              ScrumTask(
                id: 'critical',
                title: 'Critical priority task',
                description: 'Urgent delivery risk.',
                assignee: 'Team',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
                priority: ScrumTaskPriority.critical,
                sortOrder: 2000,
              ),
            ],
          ),
        ),
      ),
    );

    final initialLowTop = tester.getTopLeft(find.text('Low priority task')).dy;
    final initialCriticalTop = tester
        .getTopLeft(find.text('Critical priority task'))
        .dy;
    expect(initialLowTop, lessThan(initialCriticalTop));

    await tester.tap(find.text('Lane order'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is CheckedPopupMenuItem<ScrumTaskSort> &&
            widget.value == ScrumTaskSort.priority,
      ),
    );
    await tester.pumpAndSettle();

    final sortedLowTop = tester.getTopLeft(find.text('Low priority task')).dy;
    final sortedCriticalTop = tester
        .getTopLeft(find.text('Critical priority task'))
        .dy;
    expect(sortedCriticalTop, lessThan(sortedLowTop));
  });

  testWidgets('applies board view presets from the toolbar', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'active',
                title: 'Active preset task',
                description: 'Still in progress.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
              ScrumTask(
                id: 'done',
                title: 'Completed preset task',
                description: 'Already finished.',
                assignee: 'Team',
                storyPoints: 5,
                createdAt: DateTime(2026, 1, 2),
                status: ScrumTaskStatus.done,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Active preset task'), findsOneWidget);
    expect(find.text('Completed preset task'), findsOneWidget);

    await tester.tap(find.text('All work'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is CheckedPopupMenuItem<ScrumBoardViewPreset> &&
            widget.value?.id == 'completed',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Completed preset task'), findsOneWidget);
    expect(find.text('Active preset task'), findsNothing);
  });

  testWidgets('renders extracted move preview summary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: Center(
            child: MovePreviewSummary(
              targetLabel: 'Done',
              changedCount: 2,
              blockedCount: 1,
              unchangedCount: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('2 tasks will move to Done.'), findsOneWidget);
    expect(find.text('2 movable'), findsOneWidget);
    expect(find.text('1 blocked'), findsOneWidget);
    expect(find.text('1 already there'), findsOneWidget);
  });

  testWidgets('renders extracted blocked move preview list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MovePreviewBlockedList(
              blockedResults: [
                ScrumTaskMoveResult.blocked(
                  taskId: 'blocked',
                  fromStatus: ScrumTaskStatus.todo,
                  toStatus: ScrumTaskStatus.inProgress,
                  reason: ScrumTaskMoveBlockReason.wipLimit,
                  targetCount: 3,
                  targetLimit: 2,
                  message: 'In Progress is at its WIP limit of 2 tasks.',
                ),
              ],
              extraBlockedCount: 1,
              taskTitleFor: (taskId) => 'Blocked checkout',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Blocked by workflow policy'), findsOneWidget);
    expect(
      find.text(
        'Blocked checkout: In Progress is at its WIP limit of 2 tasks.',
      ),
      findsOneWidget,
    );
    expect(find.text('+1 more blocked'), findsOneWidget);
  });

  testWidgets('moves selected tasks through the bulk action bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'selected',
          title: 'Selected bulk task',
          description: 'This task moves through the bulk action bar.',
          assignee: 'Alya',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
        ScrumTask(
          id: 'steady',
          title: 'Steady todo task',
          description: 'This task should remain in todo.',
          assignee: 'Bayu',
          storyPoints: 2,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Select task').first);
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is PopupMenuItem<ScrumTaskStatus> &&
            widget.value == ScrumTaskStatus.done,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Move selected tasks?'), findsOneWidget);
    expect(find.text('1 task will move to Done.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply move'));
    await tester.pumpAndSettle();

    expect(controller.taskById('selected')?.status, ScrumTaskStatus.done);
    expect(controller.taskById('steady')?.status, ScrumTaskStatus.todo);
    expect(find.text('1 selected'), findsNothing);
    expect(find.byTooltip('Select task'), findsWidgets);
  });

  testWidgets('selects visible lane tasks from the column header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'first',
          title: 'First visible lane task',
          description: 'This task should be selected from the lane header.',
          assignee: 'Alya',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
        ScrumTask(
          id: 'second',
          title: 'Second visible lane task',
          description: 'This task should also be selected.',
          assignee: 'Bayu',
          storyPoints: 2,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Select To Do tasks'));
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is PopupMenuItem<ScrumTaskStatus> &&
            widget.value == ScrumTaskStatus.done,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Move selected tasks?'), findsOneWidget);
    expect(find.text('2 tasks will move to Done.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply move'));
    await tester.pumpAndSettle();

    expect(controller.taskById('first')?.status, ScrumTaskStatus.done);
    expect(controller.taskById('second')?.status, ScrumTaskStatus.done);
    expect(find.text('2 selected'), findsNothing);
  });

  testWidgets('previews blocked bulk moves before applying movable tasks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    const config = ScrumBoardConfig(
      statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.inProgress],
      showInsights: false,
      policy: ScrumWorkflowPolicy(
        enforceWipLimits: true,
        wipLimits: {ScrumTaskStatus.inProgress: 2},
      ),
    );
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      config: config,
      initialTasks: [
        ScrumTask(
          id: 'active',
          title: 'Active task',
          description: 'Already in progress.',
          assignee: 'Team',
          storyPoints: 3,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.inProgress,
        ),
        ScrumTask(
          id: 'first',
          title: 'First movable task',
          description: 'This task can move before the WIP limit fills.',
          assignee: 'Team',
          storyPoints: 2,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
        ScrumTask(
          id: 'second',
          title: 'Second blocked task',
          description: 'This task should remain selected after apply.',
          assignee: 'Team',
          storyPoints: 2,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(config: config, controller: controller),
      ),
    );

    await tester.tap(find.byTooltip('Select To Do tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is PopupMenuItem<ScrumTaskStatus> &&
            widget.value == ScrumTaskStatus.inProgress,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 task will move to In Progress.'), findsOneWidget);
    expect(find.text('1 blocked'), findsOneWidget);
    expect(find.text('Blocked by workflow policy'), findsOneWidget);
    expect(
      find.text(
        'Second blocked task: In Progress is at its WIP limit of 2 tasks.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Apply move'));
    await tester.pumpAndSettle();

    expect(controller.taskById('first')?.status, ScrumTaskStatus.inProgress);
    expect(controller.taskById('second')?.status, ScrumTaskStatus.todo);
    expect(find.text('1 selected'), findsOneWidget);
  });

  testWidgets('confirms bulk deletion before removing selected tasks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = ScrumBoardController(
      initialTasks: [
        ScrumTask(
          id: 'delete-me',
          title: 'Delete with confirmation',
          description: 'Bulk delete should ask before removing this task.',
          assignee: 'Team',
          storyPoints: 2,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Select task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete task?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(controller.taskById('delete-me'), isNotNull);
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(controller.taskById('delete-me'), isNull);
    expect(find.text('Delete with confirmation'), findsNothing);
    expect(find.text('1 selected'), findsNothing);
    expect(find.text('1 task deleted.'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(controller.taskById('delete-me'), isNotNull);
    expect(find.text('Delete with confirmation'), findsOneWidget);
    expect(find.text('1 task restored.'), findsOneWidget);
  });

  testWidgets('collapses and expands board columns', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'foldable',
                title: 'Foldable lane task',
                description: 'This task should hide while the lane is folded.',
                assignee: 'Team',
                storyPoints: 3,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Foldable lane task'), findsOneWidget);
    expect(find.byTooltip('Collapse To Do'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse To Do'));
    await tester.pumpAndSettle();

    expect(find.text('Foldable lane task'), findsNothing);
    expect(find.byTooltip('Expand To Do'), findsOneWidget);
    expect(find.text('1 task'), findsOneWidget);
    expect(find.text('3 SP'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand To Do'));
    await tester.pumpAndSettle();

    expect(find.text('Foldable lane task'), findsOneWidget);
    expect(find.byTooltip('Collapse To Do'), findsOneWidget);
  });

  testWidgets('collapses and expands all visible board columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.done],
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'todo',
                title: 'Visible collapse todo task',
                description: 'This task should hide with visible lanes.',
                assignee: 'Team',
                storyPoints: 3,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
              ScrumTask(
                id: 'done',
                title: 'Visible collapse done task',
                description: 'This task should also hide with visible lanes.',
                assignee: 'Team',
                storyPoints: 2,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.done,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Visible collapse todo task'), findsOneWidget);
    expect(find.text('Visible collapse done task'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse visible lanes'));
    await tester.pumpAndSettle();

    expect(find.text('Visible collapse todo task'), findsNothing);
    expect(find.text('Visible collapse done task'), findsNothing);
    expect(find.byTooltip('Expand To Do'), findsOneWidget);
    expect(find.byTooltip('Expand Done'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand visible lanes'));
    await tester.pumpAndSettle();

    expect(find.text('Visible collapse todo task'), findsOneWidget);
    expect(find.text('Visible collapse done task'), findsOneWidget);
  });

  testWidgets('shows enforced WIP guardrails on columns', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    const config = ScrumBoardConfig(
      statuses: [ScrumTaskStatus.todo],
      showInsights: false,
      policy: ScrumWorkflowPolicy(
        enforceWipLimits: true,
        wipLimits: {ScrumTaskStatus.todo: 1},
      ),
    );
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: config,
          controller: ScrumBoardController(
            config: config,
            initialTasks: [
              ScrumTask(
                id: 'guarded',
                title: 'Guarded lane task',
                description: 'This lane has an enforced WIP limit.',
                assignee: 'Team',
                storyPoints: 3,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byTooltip('WIP capacity: 1 of 1 tasks'), findsOneWidget);
    expect(find.text('Guarded lane task'), findsOneWidget);
  });

  testWidgets('applies board configuration to visible lanes', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScrumBoardScreen(
          config: const ScrumBoardConfig(
            title: 'Ops Sprint',
            subtitle: 'Focused delivery lane',
            statuses: [ScrumTaskStatus.todo],
            statusLabels: {ScrumTaskStatus.todo: 'Ready'},
            showInsights: false,
          ),
          controller: ScrumBoardController(
            initialTasks: [
              ScrumTask(
                id: 'task',
                title: 'Configurable board',
                description: 'Only configured lanes should render.',
                assignee: 'Team',
                storyPoints: 3,
                createdAt: DateTime(2026, 1, 1),
                status: ScrumTaskStatus.todo,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Ops Sprint'), findsOneWidget);
    expect(find.text('Focused delivery lane'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Backlog'), findsNothing);
    expect(find.text('Sprint Intelligence'), findsNothing);
  });
}

class _RecordingScrumTaskRepository implements ScrumTaskRepository {
  final List<ScrumTask> upsertedTasks = [];

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<ScrumTask>> loadTasks() async => const [];

  @override
  Future<void> replaceTasks(List<ScrumTask> tasks) async {}

  @override
  Future<void> upsertTask(ScrumTask task) async {
    upsertedTasks.add(task);
  }
}
