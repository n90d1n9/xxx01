import '../models/scrum_activity.dart';
import '../models/scrum_task.dart';

/// Read-only query for board activity history and task status timing.
class BoardActivityQuery {
  const BoardActivityQuery({required List<ScrumActivity> activities})
    : _activities = activities;

  final List<ScrumActivity> _activities;

  /// Returns the newest board activities up to the requested limit.
  List<ScrumActivity> recentActivities({int limit = 8}) {
    if (limit <= 0) return const [];
    return _activities.take(limit).toList(growable: false);
  }

  /// Returns task-scoped activities, optionally limited to the newest entries.
  List<ScrumActivity> activitiesForTask(String taskId, {int? limit}) {
    final activities = _activities.where(
      (activity) => activity.taskId == taskId,
    );
    if (limit == null) return activities.toList(growable: false);
    if (limit <= 0) return const [];
    return activities.take(limit).toList(growable: false);
  }

  /// Finds when a task most recently entered its current lane.
  DateTime statusStartedAtForTask(ScrumTask task) {
    for (final activity in _activities) {
      if (activity.taskId != task.id || activity.toStatus != task.status) {
        continue;
      }
      if (activity.type == ScrumActivityType.taskCreated ||
          activity.type == ScrumActivityType.taskMoved) {
        return activity.createdAt;
      }
    }
    return task.createdAt;
  }
}

/// Returns activity history deduplicated by id and ordered newest first.
List<ScrumActivity> normalizedActivityList(List<ScrumActivity> activities) {
  final activitiesById = <String, ScrumActivity>{};
  for (final activity in activities) {
    activitiesById.putIfAbsent(activity.id, () => activity);
  }

  final normalizedActivities = activitiesById.values.toList();
  normalizedActivities.sort(compareActivityRecency);
  return normalizedActivities;
}

/// Classifies a task update into the activity type it should record.
ScrumActivityType activityTypeForTaskUpdate(
  ScrumTask previousTask,
  ScrumTask updatedTask,
) {
  if (previousTask.status != updatedTask.status) {
    return ScrumActivityType.taskMoved;
  }
  if (previousTask.priority != updatedTask.priority) {
    return ScrumActivityType.taskPriorityChanged;
  }
  return ScrumActivityType.taskUpdated;
}

/// Compares activity entries by newest timestamp and stable id tie-breaker.
int compareActivityRecency(ScrumActivity a, ScrumActivity b) {
  final createdComparison = b.createdAt.compareTo(a.createdAt);
  if (createdComparison != 0) return createdComparison;
  return b.id.compareTo(a.id);
}
