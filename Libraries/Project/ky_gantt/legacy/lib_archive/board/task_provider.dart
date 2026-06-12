import '../task/task.dart';

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return tasks.where((task) {
    final matchesSearch = searchQuery.isEmpty ||
        task.title.toLowerCase().contains(searchQuery) ||
        task.description.toLowerCase().contains(searchQuery);

    final matchesPriority = filter.priority == null || task.priority == filter.priority;
    final matchesAssignee =
        filter.assignee == null || task.assignedTo == filter.assignee;
    final matchesLabel = filter.label == null ||
        task.labels.contains(filter.label);

    return matchesSearch && matchesPriority && matchesAssignee && matchesLabel;
  }).toList();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final box = await Hive.openBox<Task>('tasks');
    state = box.values.toList();
  }

  Future<void> addTask(Task task) async {
    final box = await Hive.openBox<Task>('tasks');
    await box.put(task.id, task);
    state = [...state, task];
  }

  Future<void> updateTask(Task task) async {
    final box = await Hive.openBox<Task>('tasks');
    await box.put(task.id, task);
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
  }

  Future<void> deleteTask(String taskId) async {
    final box = await Hive.openBox<Task>('tasks');
    await box.delete(taskId);
    state = state.where((task) => task.id != taskId).toList();
  }
}

class TaskFilter {
  final TaskPriority? priority;
  final String? assignee;
  final String? label;

  const TaskFilter({
    this.priority,
    this.assignee,
    this.label,
  });
}
