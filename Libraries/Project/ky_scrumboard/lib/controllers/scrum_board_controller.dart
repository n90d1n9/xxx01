import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/demo_scrum_tasks.dart';
import '../models/scrum_activity.dart';
import '../models/scrum_assignee_load.dart';
import '../models/scrum_board_config.dart';
import '../models/scrum_board_filter.dart';
import '../models/scrum_board_insight.dart';
import '../models/scrum_board_summary.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_move_preview.dart';
import '../models/scrum_task_move_result.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';
import '../models/scrum_workflow_policy.dart';
import '../repositories/scrum_activity_repository.dart';
import '../repositories/scrum_task_repository.dart';
import 'board_activity_recorder.dart';
import 'board_activity_query.dart';
import 'board_load_coordinator.dart';
import 'board_move_applier.dart';
import 'board_move_planner.dart';
import 'board_persistence_writer.dart';
import 'board_query.dart';
import 'board_task_batch.dart';
import 'board_task_bulk_editor.dart';
import 'board_task_note_editor.dart';
import 'board_task_order_editor.dart';
import 'board_task_removal_editor.dart';
import 'board_task_replacement_editor.dart';
import 'board_task_upsert_editor.dart';
import 'task_ordering.dart';

/// Coordinates board task state, persistence, activities, and task movement.
class ScrumBoardController extends ChangeNotifier {
  ScrumBoardController({
    Iterable<ScrumTask> initialTasks = const [],
    ScrumBoardConfig config = const ScrumBoardConfig(),
    ScrumWorkflowPolicy? policy,
    this.repository,
    this.activityRepository,
    Iterable<ScrumActivity> initialActivities = const [],
    this.activityActor,
    DateTime Function()? clock,
  }) : config = policy == null ? config : config.copyWith(policy: policy),
       _tasks = normalizedTaskList(List<ScrumTask>.of(initialTasks)),
       _activities = normalizedActivityList(
         List<ScrumActivity>.of(initialActivities),
       ),
       _clock = clock ?? DateTime.now {
    _activityRecorder = BoardActivityRecorder(
      activities: _activities,
      clock: _clock,
      actor: activityActor,
    );
    _persistenceWriter = BoardPersistenceWriter(
      taskRepository: repository,
      activityRepository: activityRepository,
      onErrorChanged: notifyListeners,
    );
    _loadCoordinator = BoardLoadCoordinator(
      persistenceWriter: _persistenceWriter,
      onLoadingChanged: notifyListeners,
    );
    _taskOrderEditor = BoardTaskOrderEditor(tasks: _tasks);
    _taskUpsertEditor = BoardTaskUpsertEditor(
      tasks: _tasks,
      orderEditor: _taskOrderEditor,
    );
    _taskBulkEditor = BoardTaskBulkEditor(
      tasks: _tasks,
      upsertEditor: _taskUpsertEditor,
    );
    _taskNoteEditor = BoardTaskNoteEditor(tasks: _tasks);
    _taskRemovalEditor = BoardTaskRemovalEditor(
      tasks: _tasks,
      orderEditor: _taskOrderEditor,
    );
    _taskReplacementEditor = BoardTaskReplacementEditor(tasks: _tasks);
    _moveApplier = BoardMoveApplier(
      tasks: _tasks,
      config: this.config,
      orderEditor: _taskOrderEditor,
    );
  }

  factory ScrumBoardController.demo({
    ScrumBoardConfig config = const ScrumBoardConfig(),
    ScrumTaskRepository? repository,
    ScrumActivityRepository? activityRepository,
  }) {
    return ScrumBoardController(
      initialTasks: demoScrumTasks(DateTime.now()),
      config: config,
      repository: repository,
      activityRepository: activityRepository,
    );
  }

  final ScrumBoardConfig config;
  final ScrumTaskRepository? repository;
  final ScrumActivityRepository? activityRepository;
  final String? activityActor;
  final DateTime Function() _clock;
  final List<ScrumTask> _tasks;
  final List<ScrumActivity> _activities;
  late final BoardActivityRecorder _activityRecorder;
  late final BoardLoadCoordinator _loadCoordinator;
  late final BoardPersistenceWriter _persistenceWriter;
  late final BoardTaskBulkEditor _taskBulkEditor;
  late final BoardTaskNoteEditor _taskNoteEditor;
  late final BoardTaskOrderEditor _taskOrderEditor;
  late final BoardTaskRemovalEditor _taskRemovalEditor;
  late final BoardTaskReplacementEditor _taskReplacementEditor;
  late final BoardTaskUpsertEditor _taskUpsertEditor;
  late final BoardMoveApplier _moveApplier;

  UnmodifiableListView<ScrumTask> get tasks => UnmodifiableListView(_tasks);

  UnmodifiableListView<ScrumActivity> get activities {
    return UnmodifiableListView(_activities);
  }

  bool get isLoading => _loadCoordinator.isLoading;

  Object? get lastPersistenceError => _persistenceWriter.lastError;

  bool get hasPersistenceBoundary => _persistenceWriter.hasTaskRepository;

  bool get hasActivityBoundary => _persistenceWriter.hasActivityRepository;

  Future<void> get pendingPersistence => _persistenceWriter.pending;

  ScrumWorkflowPolicy get policy => config.policy;

  BoardTaskQuery get _query => BoardTaskQuery(tasks: _tasks, config: config);

  BoardMovePlanner get _movePlanner {
    return BoardMovePlanner(tasks: _tasks, config: config);
  }

  BoardActivityQuery get _activityQuery {
    return BoardActivityQuery(activities: _activities);
  }

  ScrumBoardSummary get summary => _query.summary;

  List<ScrumTask> tasksFor(
    ScrumTaskStatus status, {
    String query = '',
    ScrumBoardFilter filter = const ScrumBoardFilter(),
  }) {
    return _query.tasksFor(status, query: query, filter: filter);
  }

  List<ScrumTask> filteredTasks(ScrumBoardFilter filter) {
    return _query.filteredTasks(filter);
  }

  List<String> assignees() {
    return _query.assignees();
  }

  ScrumTask? taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  List<ScrumActivity> recentActivities({int limit = 8}) {
    return _activityQuery.recentActivities(limit: limit);
  }

  List<ScrumActivity> activitiesForTask(String taskId, {int? limit}) {
    return _activityQuery.activitiesForTask(taskId, limit: limit);
  }

  DateTime statusStartedAtForTask(ScrumTask task) {
    return _activityQuery.statusStartedAtForTask(task);
  }

  int countFor(ScrumTaskStatus status) {
    return _query.countFor(status);
  }

  int storyPointsFor(ScrumTaskStatus status) {
    return _query.storyPointsFor(status);
  }

  List<ScrumBoardInsight> insights({DateTime? now}) {
    return _query.insights(now: now);
  }

  List<ScrumAssigneeLoad> assigneeLoads() {
    return _query.assigneeLoads();
  }

  Future<void> loadTasks() async {
    final repository = this.repository;
    if (repository == null) return;

    await _loadCoordinator.load<List<ScrumTask>>(
      repository.loadTasks,
      apply: (loadedTasks) {
        _tasks
          ..clear()
          ..addAll(normalizedTaskList(loadedTasks));
      },
    );
  }

  Future<void> loadActivities() async {
    final repository = activityRepository;
    if (repository == null) return;

    await _loadCoordinator.load<List<ScrumActivity>>(
      repository.loadActivities,
      apply: (loadedActivities) {
        _activities
          ..clear()
          ..addAll(normalizedActivityList(loadedActivities));
      },
    );
  }

  Future<void> loadBoard() async {
    await loadTasks();
    await loadActivities();
  }

  Future<void> replaceTasks(List<ScrumTask> tasks) async {
    final application = _taskReplacementEditor.replace(tasks);
    _recordActivity(application.activityType, note: application.note);
    notifyListeners();

    await _persistenceWriter.replaceTasks(application.replacedTasks);
  }

  void addTask(ScrumTask task) {
    final application = _taskUpsertEditor.addOrUpdate(task);
    _recordTaskUpsertActivity(application);
    notifyListeners();
    _persistenceWriter.queueTaskWrites(application.changedTasks);
  }

  bool updateTask(ScrumTask task) {
    final application = _taskUpsertEditor.update(task);
    if (!application.applied) return false;

    _recordTaskUpsertActivity(application);
    notifyListeners();
    _persistenceWriter.queueTaskWrites(application.changedTasks);
    return true;
  }

  bool deleteTask(String id) {
    final application = _taskRemovalEditor.delete(id);
    if (!application.applied) return false;

    final removedTask = application.removedTask;
    if (removedTask == null) return false;
    _recordActivity(
      ScrumActivityType.taskDeleted,
      previousTask: removedTask,
      fromStatus: removedTask.status,
    );
    notifyListeners();
    _persistenceWriter.queueTaskDelete(id);
    return true;
  }

  int deleteTasks(Iterable<String> ids) {
    return BoardTaskBatch(ids).countWhere(deleteTask);
  }

  int restoreTasks(Iterable<ScrumTask> tasks) {
    final application = _taskRemovalEditor.restore(tasks);
    if (!application.applied) return 0;

    for (final task in application.restoredTasks) {
      _recordActivity(
        ScrumActivityType.taskCreated,
        task: task,
        toStatus: task.status,
        note: 'Restored after deletion.',
      );
    }

    notifyListeners();
    _persistenceWriter.queueTaskWrites(application.changedTasks);
    return application.restoredCount;
  }

  int updateTaskPriorities(Iterable<String> ids, ScrumTaskPriority priority) {
    final application = _taskBulkEditor.updatePriorities(ids, priority);
    if (!application.applied) return 0;

    for (final upsertApplication in application.applications) {
      _recordTaskUpsertActivity(upsertApplication);
    }

    notifyListeners();
    _persistenceWriter.queueTaskWrites(application.changedTasks);
    return application.updatedCount;
  }

  bool addTaskNote(String id, String note) {
    final application = _taskNoteEditor.addNote(id, note);
    final activityType = application.activityType;
    final task = application.task;
    if (!application.applied || activityType == null || task == null) {
      return false;
    }

    _recordActivity(activityType, task: task, note: application.note);
    notifyListeners();
    return true;
  }

  bool moveTask(String id, ScrumTaskStatus status) {
    return placeTask(id, status);
  }

  List<ScrumTaskMoveResult> moveTasks(
    Iterable<String> ids,
    ScrumTaskStatus status,
  ) {
    return BoardTaskBatch(ids).map((id) => placeTaskWithResult(id, status));
  }

  ScrumTaskMovePreview previewTaskMoves(
    Iterable<String> ids,
    ScrumTaskStatus status,
  ) {
    return _movePlanner.previewTaskMoves(ids, status);
  }

  bool placeTask(String id, ScrumTaskStatus status, {String? beforeTaskId}) {
    return placeTaskWithResult(id, status, beforeTaskId: beforeTaskId).changed;
  }

  ScrumTaskMoveResult validateTaskMove(
    String id,
    ScrumTaskStatus status, {
    String? beforeTaskId,
  }) {
    return _movePlanner.validateTaskMove(
      id,
      status,
      beforeTaskId: beforeTaskId,
    );
  }

  ScrumTaskMoveResult placeTaskWithResult(
    String id,
    ScrumTaskStatus status, {
    String? beforeTaskId,
  }) {
    final validation = validateTaskMove(id, status, beforeTaskId: beforeTaskId);
    if (!validation.accepted || !validation.changed) return validation;

    final application = _moveApplier.apply(
      validation,
      beforeTaskId: beforeTaskId,
    );
    final result = application.result;
    if (!result.accepted || !result.changed) return result;

    final activityType = application.activityType;
    final updatedTask = application.updatedTask;
    final previousTask = application.previousTask;
    if (activityType != null && updatedTask != null && previousTask != null) {
      _recordActivity(
        activityType,
        task: updatedTask,
        previousTask: previousTask,
        fromStatus: previousTask.status,
        toStatus: result.toStatus,
        note: application.note,
      );
    }
    notifyListeners();
    _persistenceWriter.queueTaskWrites(application.changedTasks);
    return result;
  }

  void _recordTaskUpsertActivity(BoardTaskUpsertApplication application) {
    final activityType = application.activityType;
    final updatedTask = application.updatedTask;
    if (activityType == null || updatedTask == null) return;

    _recordActivity(
      activityType,
      task: updatedTask,
      previousTask: application.previousTask,
      fromStatus: application.fromStatus,
      toStatus: application.toStatus,
      fromPriority: application.fromPriority,
      toPriority: application.toPriority,
    );
  }

  void _recordActivity(
    ScrumActivityType type, {
    ScrumTask? task,
    ScrumTask? previousTask,
    ScrumTaskStatus? fromStatus,
    ScrumTaskStatus? toStatus,
    ScrumTaskPriority? fromPriority,
    ScrumTaskPriority? toPriority,
    String? note,
  }) {
    final activity = _activityRecorder.record(
      type,
      task: task,
      previousTask: previousTask,
      fromStatus: fromStatus,
      toStatus: toStatus,
      fromPriority: fromPriority,
      toPriority: toPriority,
      note: note,
    );
    _persistenceWriter.queueActivityWrite(activity);
  }
}
