import '../gantt_dashboard.dart' as gantt;
import 'gantt_schedule_health_service.dart';

class GanttBranchFocusSummary {
  const GanttBranchFocusSummary({
    required this.taskId,
    required this.title,
    required this.taskCount,
    required this.completedTaskCount,
    required this.riskTaskCount,
    required this.averageProgress,
    required this.startDate,
    required this.endDate,
  });

  final String taskId;
  final String title;
  final int taskCount;
  final int completedTaskCount;
  final int riskTaskCount;
  final double averageProgress;
  final DateTime startDate;
  final DateTime endDate;

  String get taskCountLabel => taskCount == 1 ? '1 task' : '$taskCount tasks';

  String get completedLabel =>
      completedTaskCount == 1 ? '1 done' : '$completedTaskCount done';

  String get progressLabel => '${(averageProgress * 100).round()}% avg';

  String get riskLabel =>
      riskTaskCount == 1 ? '1 risk' : '$riskTaskCount risks';

  String get dateRangeLabel {
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${_monthLabel(startDate.month)} ${startDate.day}-${endDate.day}';
    }

    return '${_dateLabel(startDate)} - ${_dateLabel(endDate)}';
  }
}

class GanttBranchFocusSummaryService {
  const GanttBranchFocusSummaryService();

  GanttBranchFocusSummary? summaryFor(
    gantt.GanttTask? task, {
    DateTime? today,
  }) {
    if (task == null) return null;

    final tasks = _flattenTaskTree(task);
    if (tasks.isEmpty) return null;

    var earliest = _orderedStart(tasks.first);
    var latest = _orderedEnd(tasks.first);
    var progressTotal = 0.0;
    var completedCount = 0;
    var riskCount = 0;

    for (final item in tasks) {
      progressTotal += item.progress;
      if (item.progress >= 1) completedCount += 1;

      final start = _orderedStart(item);
      final end = _orderedEnd(item);
      if (start.isBefore(earliest)) earliest = start;
      if (end.isAfter(latest)) latest = end;

      final health = ganttScheduleHealthFor(item, today: today);
      if (health == GanttScheduleHealth.overdue ||
          health == GanttScheduleHealth.dueSoon) {
        riskCount += 1;
      }
    }

    return GanttBranchFocusSummary(
      taskId: task.id,
      title: task.title,
      taskCount: tasks.length,
      completedTaskCount: completedCount,
      riskTaskCount: riskCount,
      averageProgress: progressTotal / tasks.length,
      startDate: earliest,
      endDate: latest,
    );
  }

  List<gantt.GanttTask> _flattenTaskTree(gantt.GanttTask task) {
    return [
      task,
      for (final subtask in task.subtasks) ..._flattenTaskTree(subtask),
    ];
  }

  DateTime _orderedStart(gantt.GanttTask task) {
    final start = _dateOnly(task.startDate);
    final end = _dateOnly(task.endDate);
    return start.isBefore(end) ? start : end;
  }

  DateTime _orderedEnd(gantt.GanttTask task) {
    final start = _dateOnly(task.startDate);
    final end = _dateOnly(task.endDate);
    return start.isAfter(end) ? start : end;
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _dateLabel(DateTime date) => '${_monthLabel(date.month)} ${date.day}';

String _monthLabel(int month) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return labels[month - 1];
}
