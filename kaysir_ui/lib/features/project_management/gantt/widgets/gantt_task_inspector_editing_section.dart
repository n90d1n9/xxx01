import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_task_activity_strip.dart';
import 'gantt_task_date_editor.dart';
import 'gantt_task_milestone_editor.dart';
import 'gantt_task_progress_editor.dart';

class GanttTaskInspectorEditingSection extends StatelessWidget {
  const GanttTaskInspectorEditingSection({
    required this.task,
    this.recentEdits = const [],
    this.activityNow,
    this.onRecentEditSelected,
    this.onProgressChanged,
    this.onTaskKindChanged,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.onMilestoneDateChanged,
    super.key,
  });

  final gantt.GanttTask task;
  final List<gantt.GanttTaskEditActivity> recentEdits;
  final DateTime? activityNow;
  final ValueChanged<gantt.GanttTaskEditActivity>? onRecentEditSelected;
  final ValueChanged<double>? onProgressChanged;
  final ValueChanged<gantt.GanttTaskKind>? onTaskKindChanged;
  final ValueChanged<DateTime>? onStartDateChanged;
  final ValueChanged<DateTime>? onEndDateChanged;
  final ValueChanged<DateTime>? onMilestoneDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GanttTaskActivityStrip(
          activities: recentEdits,
          now: activityNow,
          selectedTaskId: task.id,
          onActivitySelected: onRecentEditSelected,
        ),
        if (recentEdits.isNotEmpty) const SizedBox(height: 12),
        GanttTaskProgressEditor(
          task: task,
          onProgressChanged: onProgressChanged,
        ),
        const SizedBox(height: 12),
        GanttTaskMilestoneEditor(
          task: task,
          onTaskKindChanged: onTaskKindChanged,
        ),
        const SizedBox(height: 12),
        GanttTaskDateEditor(
          task: task,
          onStartDateChanged: onStartDateChanged,
          onEndDateChanged: onEndDateChanged,
          onMilestoneDateChanged: onMilestoneDateChanged,
        ),
      ],
    );
  }
}
