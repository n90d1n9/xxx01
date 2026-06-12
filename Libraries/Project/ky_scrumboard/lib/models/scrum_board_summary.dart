import 'scrum_task_status.dart';

class ScrumBoardSummary {
  const ScrumBoardSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.activeTasks,
    required this.totalStoryPoints,
    required this.completedStoryPoints,
    required this.activeStoryPoints,
    required this.tasksByStatus,
  });

  final int totalTasks;
  final int completedTasks;
  final int activeTasks;
  final int totalStoryPoints;
  final int completedStoryPoints;
  final int activeStoryPoints;
  final Map<ScrumTaskStatus, int> tasksByStatus;

  double get completionRate {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }

  double get storyPointCompletionRate {
    if (totalStoryPoints == 0) return 0;
    return completedStoryPoints / totalStoryPoints;
  }
}
