import '../models/gantt_task.dart';

class GanttTaskNode {
  const GanttTaskNode({
    required this.task,
    required this.depth,
    this.collapsed = false,
  });

  final GanttTask task;
  final int depth;
  final bool collapsed;

  bool get hasChildren => task.subtasks.isNotEmpty;
}

List<GanttTaskNode> flattenGanttTaskNodes(
  List<GanttTask> tasks, {
  int depth = 0,
  Set<String> collapsedTaskIds = const <String>{},
}) {
  return [
    for (final task in tasks) ...[
      GanttTaskNode(
        task: task,
        depth: depth,
        collapsed:
            task.subtasks.isNotEmpty && collapsedTaskIds.contains(task.id),
      ),
      if (task.subtasks.isNotEmpty && !collapsedTaskIds.contains(task.id))
        ...flattenGanttTaskNodes(
          task.subtasks,
          depth: depth + 1,
          collapsedTaskIds: collapsedTaskIds,
        ),
    ],
  ];
}

List<GanttTask> flattenGanttTasks(List<GanttTask> tasks) {
  return [
    for (final node in flattenGanttTaskNodes(tasks)) node.task,
  ];
}
