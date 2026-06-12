import '../models/scrum_task.dart';
import 'scrum_task_repository.dart';

class InMemoryScrumTaskRepository implements ScrumTaskRepository {
  InMemoryScrumTaskRepository({Iterable<ScrumTask> initialTasks = const []})
    : _tasks = List<ScrumTask>.of(initialTasks);

  final List<ScrumTask> _tasks;

  @override
  Future<List<ScrumTask>> loadTasks() async {
    return List<ScrumTask>.unmodifiable(_tasks);
  }

  @override
  Future<void> replaceTasks(List<ScrumTask> tasks) async {
    _tasks
      ..clear()
      ..addAll(tasks);
  }

  @override
  Future<void> upsertTask(ScrumTask task) async {
    final existingIndex = _tasks.indexWhere((item) => item.id == task.id);
    if (existingIndex >= 0) {
      _tasks[existingIndex] = task;
    } else {
      _tasks.add(task);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
}
