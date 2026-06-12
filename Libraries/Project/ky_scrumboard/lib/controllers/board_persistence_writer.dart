import '../models/scrum_activity.dart';
import '../models/scrum_task.dart';
import '../repositories/scrum_activity_repository.dart';
import '../repositories/scrum_task_repository.dart';
import 'board_persistence_queue.dart';
import 'board_task_batch.dart';

/// Writes board task and activity changes through queued repositories.
class BoardPersistenceWriter {
  BoardPersistenceWriter({
    ScrumTaskRepository? taskRepository,
    ScrumActivityRepository? activityRepository,
    BoardPersistenceQueue? queue,
    void Function()? onErrorChanged,
  }) : _taskRepository = taskRepository,
       _activityRepository = activityRepository,
       _queue = queue ?? BoardPersistenceQueue(),
       _onErrorChanged = onErrorChanged;

  final ScrumTaskRepository? _taskRepository;
  final ScrumActivityRepository? _activityRepository;
  final BoardPersistenceQueue _queue;
  final void Function()? _onErrorChanged;

  /// Whether task writes have a repository boundary.
  bool get hasTaskRepository => _taskRepository != null;

  /// Whether activity writes have a repository boundary.
  bool get hasActivityRepository => _activityRepository != null;

  /// The current tail of the queued persistence writes.
  Future<void> get pending => _queue.pending;

  /// The latest persistence error reported by a load or queued write.
  Object? get lastError => _queue.lastError;

  /// Clears a previously tracked persistence error.
  void clearError() {
    _queue.clearError();
  }

  /// Stores a persistence error from a caller-owned load operation.
  void setError(Object error) {
    _queue.setError(error);
  }

  /// Replaces every persisted task when a full board import occurs.
  Future<void> replaceTasks(List<ScrumTask> tasks) {
    final repository = _taskRepository;
    if (repository == null) return Future<void>.value();

    return _queueWrite(
      () => repository.replaceTasks(List<ScrumTask>.unmodifiable(tasks)),
    );
  }

  /// Queues upsert writes for changed tasks.
  Future<void> queueTaskWrites(Iterable<ScrumTask> tasks) {
    final repository = _taskRepository;
    final uniqueTasks = uniqueTasksById(tasks);
    if (uniqueTasks.isEmpty || repository == null) return Future<void>.value();

    return _queueWrite(() async {
      for (final task in uniqueTasks) {
        await repository.upsertTask(task);
      }
    });
  }

  /// Queues a task deletion write.
  Future<void> queueTaskDelete(String id) {
    final repository = _taskRepository;
    if (repository == null) return Future<void>.value();

    return _queueWrite(() => repository.deleteTask(id));
  }

  /// Queues an activity history write.
  Future<void> queueActivityWrite(ScrumActivity activity) {
    final repository = _activityRepository;
    if (repository == null) return Future<void>.value();

    return _queueWrite(() => repository.addActivity(activity));
  }

  Future<void> _queueWrite(Future<void> Function() write) {
    return _queue.queue(write, onErrorChanged: _onErrorChanged);
  }
}
