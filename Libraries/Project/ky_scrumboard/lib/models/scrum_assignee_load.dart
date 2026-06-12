class ScrumAssigneeLoad {
  const ScrumAssigneeLoad({
    required this.assignee,
    required this.activeTasks,
    required this.activeStoryPoints,
    required this.criticalTasks,
  });

  final String assignee;
  final int activeTasks;
  final int activeStoryPoints;
  final int criticalTasks;
}
