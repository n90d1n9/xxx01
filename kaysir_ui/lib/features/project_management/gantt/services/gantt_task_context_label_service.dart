import 'package:ky_gantt/ky_gantt.dart' as ky;

String ganttTaskProgressContextLabel(ky.GanttTask task) {
  return '${ky.ganttTaskProgressLabel(task)} complete';
}

String ganttTaskScheduleContextLabel(ky.GanttTask task) {
  final dateRange = ky.ganttTaskDateRangeLabel(task);
  if (task.isMilestone) return 'Milestone $dateRange';

  return '$dateRange / ${ky.ganttTaskDurationLabel(task)}';
}

String ganttTaskDependencyContextLabel(String dependencyTitle) {
  return 'After $dependencyTitle';
}

String ganttTaskScheduleStatusContextLabel(
  ky.GanttTask task, {
  DateTime? today,
}) {
  return ky.ganttTaskScheduleStatusLabel(task, today: today);
}
