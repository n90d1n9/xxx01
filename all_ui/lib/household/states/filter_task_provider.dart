import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_task.dart';
import 'daily_task_provider.dart';

final filteredTasksProvider = Provider.family<List<DailyTask>, TaskFilter>((
  ref,
  filter,
) {
  final tasks = ref.watch(dailyTasksProvider);
  switch (filter) {
    case TaskFilter.all:
      return tasks;
    case TaskFilter.active:
      return tasks.where((t) => !t.completed).toList();
    case TaskFilter.completed:
      return tasks.where((t) => t.completed).toList();
  }
});

enum TaskFilter { all, active, completed }
