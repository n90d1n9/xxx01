import 'scrum_task.dart';
import 'scrum_task_age_state.dart';
import 'scrum_task_due_state.dart';

class ScrumLaneHealth {
  const ScrumLaneHealth({
    required this.overdueTasks,
    required this.dueSoonTasks,
    required this.agedReviewTasks,
  });

  static const empty = ScrumLaneHealth(
    overdueTasks: 0,
    dueSoonTasks: 0,
    agedReviewTasks: 0,
  );

  final int overdueTasks;
  final int dueSoonTasks;
  final int agedReviewTasks;

  bool get hasSignals {
    return overdueTasks > 0 || dueSoonTasks > 0 || agedReviewTasks > 0;
  }

  static ScrumLaneHealth forTasks(
    Iterable<ScrumTask> tasks, {
    DateTime? now,
    int dueSoonDays = 2,
    int reviewAgeWarningDays = 3,
    DateTime Function(ScrumTask task)? statusStartedAtForTask,
  }) {
    final currentTime = now ?? DateTime.now();
    var overdueTasks = 0;
    var dueSoonTasks = 0;
    var agedReviewTasks = 0;

    for (final task in tasks) {
      final dueState = ScrumTaskDueState.forTask(
        task,
        now: currentTime,
        dueSoonDays: dueSoonDays,
      );
      switch (dueState.status) {
        case ScrumTaskDueStatus.overdue:
          overdueTasks += 1;
          break;
        case ScrumTaskDueStatus.dueSoon:
          dueSoonTasks += 1;
          break;
        case ScrumTaskDueStatus.none:
        case ScrumTaskDueStatus.planned:
          break;
      }

      final ageState = ScrumTaskAgeState.forTask(
        task,
        statusStartedAt: statusStartedAtForTask?.call(task) ?? task.createdAt,
        now: currentTime,
        reviewAgeWarningDays: reviewAgeWarningDays,
      );
      if (ageState.shouldRender && ageState.isWarning) {
        agedReviewTasks += 1;
      }
    }

    return ScrumLaneHealth(
      overdueTasks: overdueTasks,
      dueSoonTasks: dueSoonTasks,
      agedReviewTasks: agedReviewTasks,
    );
  }
}
