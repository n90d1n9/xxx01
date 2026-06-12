import '../models/scrum_task.dart';

abstract interface class ScrumTaskRepository {
  Future<List<ScrumTask>> loadTasks();

  Future<void> replaceTasks(List<ScrumTask> tasks);

  Future<void> upsertTask(ScrumTask task);

  Future<void> deleteTask(String id);
}
