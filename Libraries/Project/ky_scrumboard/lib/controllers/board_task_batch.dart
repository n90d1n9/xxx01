import '../models/scrum_task.dart';

/// Preserves selected task order while deduplicating ids for bulk commands.
class BoardTaskBatch {
  const BoardTaskBatch(Iterable<String> ids) : _ids = ids;

  final Iterable<String> _ids;

  /// Unique task ids in the same order the user selected them.
  List<String> get uniqueIds {
    final uniqueIds = <String>[];
    final seenIds = <String>{};
    for (final id in _ids) {
      if (seenIds.add(id)) uniqueIds.add(id);
    }
    return uniqueIds;
  }

  /// Applies a command once for each unique task id.
  List<T> map<T>(T Function(String id) command) {
    return [for (final id in uniqueIds) command(id)];
  }

  /// Counts unique task ids accepted by a command predicate.
  int countWhere(bool Function(String id) command) {
    var count = 0;
    for (final id in uniqueIds) {
      if (command(id)) count += 1;
    }
    return count;
  }
}

/// Deduplicates tasks by id while preserving first-seen id order.
List<ScrumTask> uniqueTasksById(Iterable<ScrumTask> tasks) {
  final byId = <String, ScrumTask>{};
  for (final task in tasks) {
    byId[task.id] = task;
  }
  return byId.values.toList(growable: false);
}
