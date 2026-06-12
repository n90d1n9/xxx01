import 'restaurant_models.dart';

/// Summarizes completion and attention counts for shift follow-up tasks.
class RestaurantTaskSummary {
  const RestaurantTaskSummary({
    required this.totalCount,
    required this.completedCount,
    required this.openCount,
    required this.attentionCount,
  });

  factory RestaurantTaskSummary.fromTasks(List<RestaurantShiftTask> tasks) {
    var completedCount = 0;
    var attentionCount = 0;

    for (final task in tasks) {
      final complete = task.progress >= 1;
      if (complete) {
        completedCount += 1;
      } else if (task.status.priorityScore >=
          RestaurantServiceStatus.busy.priorityScore) {
        attentionCount += 1;
      }
    }

    return RestaurantTaskSummary(
      totalCount: tasks.length,
      completedCount: completedCount,
      openCount: tasks.length - completedCount,
      attentionCount: attentionCount,
    );
  }

  final int totalCount;
  final int completedCount;
  final int openCount;
  final int attentionCount;

  double get completionRate {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  String get completionLabel => '${(completionRate * 100).round()}% complete';
}
