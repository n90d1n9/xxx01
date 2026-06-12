import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_insight_models.dart';

class EmployeeDirectoryInsightSignalTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;

  const EmployeeDirectoryInsightSignalTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeDirectoryInsightActionTile extends StatelessWidget {
  final EmployeeDirectoryInsightAction action;

  const EmployeeDirectoryInsightActionTile({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(action.priority);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_priorityIcon(action.priority), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        action.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: action.priority.label, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  action.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                _AffectedChip(count: action.affectedCount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AffectedChip extends StatelessWidget {
  final int count;

  const _AffectedChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_2_outlined, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            '$count affected',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

IconData _priorityIcon(EmployeeDirectoryInsightPriority priority) {
  return switch (priority) {
    EmployeeDirectoryInsightPriority.critical => Icons.priority_high_outlined,
    EmployeeDirectoryInsightPriority.elevated => Icons.trending_up_outlined,
    EmployeeDirectoryInsightPriority.steady => Icons.task_alt_outlined,
  };
}

Color _priorityColor(EmployeeDirectoryInsightPriority priority) {
  return switch (priority) {
    EmployeeDirectoryInsightPriority.critical => const Color(0xFFB91C1C),
    EmployeeDirectoryInsightPriority.elevated => const Color(0xFFD97706),
    EmployeeDirectoryInsightPriority.steady => HrisColors.primary,
  };
}
