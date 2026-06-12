import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

import '../gantt_dashboard.dart' as gantt;

class GanttTaskDateEditor extends StatelessWidget {
  const GanttTaskDateEditor({
    required this.task,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.onMilestoneDateChanged,
    super.key,
  });

  final gantt.GanttTask task;
  final ValueChanged<DateTime>? onStartDateChanged;
  final ValueChanged<DateTime>? onEndDateChanged;
  final ValueChanged<DateTime>? onMilestoneDateChanged;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = DateUtils.dateOnly(task.startDate);
    final endDate = DateUtils.dateOnly(task.endDate);

    if (task.isMilestone) {
      return _DateEditorRow(
        title: 'Milestone Date',
        subtitle: dateFormat.format(startDate),
        icon: Icons.event_available_outlined,
        accentColor: task.color,
        date: startDate,
        previousTooltip: 'Move milestone one day earlier',
        nextTooltip: 'Move milestone one day later',
        onChanged: onMilestoneDateChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateEditorRow(
          title: 'Start Date',
          subtitle: dateFormat.format(startDate),
          icon: Icons.event_outlined,
          accentColor: task.color,
          date: startDate,
          previousTooltip: 'Move start one day earlier',
          nextTooltip: 'Move start one day later',
          onChanged: onStartDateChanged,
        ),
        const SizedBox(height: 10),
        _DateEditorRow(
          title: 'End Date',
          subtitle: dateFormat.format(endDate),
          icon: Icons.event_available_outlined,
          accentColor: task.color,
          date: endDate,
          previousTooltip: 'Move end one day earlier',
          nextTooltip: 'Move end one day later',
          onChanged: onEndDateChanged,
        ),
      ],
    );
  }
}

class _DateEditorRow extends StatelessWidget {
  const _DateEditorRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.date,
    required this.previousTooltip,
    required this.nextTooltip,
    this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final DateTime date;
  final String previousTooltip;
  final String nextTooltip;
  final ValueChanged<DateTime>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: accentColor.withValues(alpha: 0.12),
      iconForegroundColor: accentColor,
      trailing: _DateStepper(
        date: date,
        previousTooltip: previousTooltip,
        nextTooltip: nextTooltip,
        enabled: onChanged != null,
        onChanged: onChanged,
      ),
    );
  }
}

class _DateStepper extends StatelessWidget {
  const _DateStepper({
    required this.date,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.enabled,
    this.onChanged,
  });

  final DateTime date;
  final String previousTooltip;
  final String nextTooltip;
  final bool enabled;
  final ValueChanged<DateTime>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: previousTooltip,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed:
                enabled
                    ? () =>
                        onChanged?.call(date.subtract(const Duration(days: 1)))
                    : null,
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: nextTooltip,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed:
                enabled
                    ? () => onChanged?.call(date.add(const Duration(days: 1)))
                    : null,
          ),
        ),
      ],
    );
  }
}
