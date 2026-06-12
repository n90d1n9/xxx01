import '../gantt_dashboard.dart' as gantt;
import 'gantt_schedule_dependency_impact_service.dart';
import 'gantt_schedule_focus_service.dart';

class GanttScheduleRecoveryBrief {
  const GanttScheduleRecoveryBrief({
    required this.scopeLabel,
    required this.summary,
    required this.briefText,
    required this.focusItems,
    required this.dependencyImpactSummary,
  });

  final String scopeLabel;
  final GanttScheduleFocusSummary summary;
  final String briefText;
  final List<GanttScheduleFocusItem> focusItems;
  final GanttScheduleDependencyImpactSummary dependencyImpactSummary;

  String get title => '$scopeLabel schedule recovery brief';
}

GanttScheduleRecoveryBrief buildGanttScheduleRecoveryBrief({
  required List<gantt.GanttTask> tasks,
  List<gantt.GanttTask>? dependencyTasks,
  Map<String, String> projectNamesById = const {},
  String scopeLabel = 'Roadmap',
  DateTime? today,
  int maxItems = 4,
}) {
  final normalizedScope = scopeLabel.trim().isEmpty ? 'Roadmap' : scopeLabel;
  final summary = buildGanttScheduleFocusSummary(tasks: tasks, today: today);
  final focusItems = summary.prioritizedItems.take(maxItems).toList();
  final dependencyImpactSummary = buildGanttScheduleDependencyImpactSummary(
    focusItems: focusItems,
    dependencyTasks: dependencyTasks ?? tasks,
    today: today,
  );

  return GanttScheduleRecoveryBrief(
    scopeLabel: normalizedScope,
    summary: summary,
    focusItems: List.unmodifiable(focusItems),
    dependencyImpactSummary: dependencyImpactSummary,
    briefText: _briefText(
      scopeLabel: normalizedScope,
      summary: summary,
      focusItems: focusItems,
      dependencyImpactSummary: dependencyImpactSummary,
      projectNamesById: projectNamesById,
    ),
  );
}

String _briefText({
  required String scopeLabel,
  required GanttScheduleFocusSummary summary,
  required List<GanttScheduleFocusItem> focusItems,
  required GanttScheduleDependencyImpactSummary dependencyImpactSummary,
  required Map<String, String> projectNamesById,
}) {
  if (summary.totalTasks == 0) {
    return [
      '$scopeLabel schedule recovery brief',
      'Status: No linked tasks',
      'No timeline tasks are linked to this schedule scope yet.',
    ].join('\n');
  }

  if (summary.focusCount == 0) {
    return [
      '$scopeLabel schedule recovery brief',
      'Status: ${summary.level.label}',
      '${summary.totalTasks} tracked tasks are clear for the current window.',
      '',
      'Recommended action',
      '- Keep cadence and review schedule focus again next cycle.',
    ].join('\n');
  }

  final primary = focusItems.first;
  final dependencyLines = _dependencyLines(
    dependencyImpactSummary: dependencyImpactSummary,
    projectNamesById: projectNamesById,
  );

  return [
    '$scopeLabel schedule recovery brief',
    'Status: ${summary.level.label}',
    '${summary.focusCount} focus item${summary.focusCount == 1 ? '' : 's'} across ${summary.totalTasks} tracked task${summary.totalTasks == 1 ? '' : 's'}.',
    '',
    'Primary focus',
    '- ${_taskLabel(primary, projectNamesById)}: ${ganttScheduleFocusDetail(primary)}',
    '',
    'Recovery actions',
    for (final item in focusItems)
      '- ${_taskLabel(item, projectNamesById)}: ${item.action}',
    if (dependencyLines.isNotEmpty) ...[
      '',
      'Dependency impact',
      ...dependencyLines,
    ],
    '',
    'Schedule signals',
    '- Overdue: ${summary.overdueCount}',
    '- Behind baseline: ${summary.behindCount}',
    '- Starting soon: ${summary.startingSoonCount}',
  ].join('\n');
}

List<String> _dependencyLines({
  required GanttScheduleDependencyImpactSummary dependencyImpactSummary,
  required Map<String, String> projectNamesById,
}) {
  return [
    for (final impact in dependencyImpactSummary.items)
      '- ${_taskLabel(impact.focusItem, projectNamesById)}: ${impact.insight.detail}',
  ];
}

String _taskLabel(
  GanttScheduleFocusItem item,
  Map<String, String> projectNamesById,
) {
  final projectName = projectNamesById[item.task.projectId];
  if (projectName == null || projectName.isEmpty) return item.task.title;

  return '${item.task.title} ($projectName)';
}
