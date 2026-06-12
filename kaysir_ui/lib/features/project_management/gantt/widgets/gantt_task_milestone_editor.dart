import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

import '../gantt_dashboard.dart' as gantt;

class GanttTaskMilestoneEditor extends StatelessWidget {
  const GanttTaskMilestoneEditor({
    required this.task,
    this.onTaskKindChanged,
    super.key,
  });

  final gantt.GanttTask task;
  final ValueChanged<gantt.GanttTaskKind>? onTaskKindChanged;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final milestoneDate = DateUtils.dateOnly(task.startDate);

    return AppInfoRow(
      title: 'Task Type',
      subtitle:
          task.isMilestone
              ? 'Milestone marker on ${dateFormat.format(milestoneDate)}'
              : 'Scheduled task from ${dateFormat.format(task.startDate)}',
      icon:
          task.isMilestone
              ? Icons.diamond_outlined
              : Icons.view_timeline_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: task.color.withValues(alpha: 0.12),
      iconForegroundColor: task.color,
      subtitleMaxLines: 2,
      trailing: _TaskKindSegmentedControl(
        value: task.kind,
        enabled: onTaskKindChanged != null,
        onChanged: onTaskKindChanged,
      ),
    );
  }
}

class _TaskKindSegmentedControl extends StatelessWidget {
  const _TaskKindSegmentedControl({
    required this.value,
    required this.enabled,
    this.onChanged,
  });

  final gantt.GanttTaskKind value;
  final bool enabled;
  final ValueChanged<gantt.GanttTaskKind>? onChanged;

  @override
  Widget build(BuildContext context) {
    final control = SegmentedButton<gantt.GanttTaskKind>(
      showSelectedIcon: false,
      selected: {value},
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: WidgetStatePropertyAll(
          Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      segments: const [
        ButtonSegment(
          value: gantt.GanttTaskKind.task,
          label: Text('Task'),
          icon: Icon(Icons.view_timeline_outlined, size: 16),
        ),
        ButtonSegment(
          value: gantt.GanttTaskKind.milestone,
          label: Text('Milestone'),
          icon: Icon(Icons.diamond_outlined, size: 16),
        ),
      ],
      onSelectionChanged:
          enabled
              ? (selection) {
                final selected = selection.first;
                if (selected != value) {
                  onChanged?.call(selected);
                }
              }
              : null,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: control,
      ),
    );
  }
}
