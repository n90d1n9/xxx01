import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_next_action_models.dart';
import 'employee_next_action_styles.dart';

class EmployeeNextActionSummaryStrip extends StatelessWidget {
  final EmployeeNextActionProfile profile;

  const EmployeeNextActionSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Urgent', value: '${profile.urgentCount}'),
        HrisMetricStripItem(label: 'Blocked', value: '${profile.blockedCount}'),
        HrisMetricStripItem(label: 'Due', value: '${profile.dueSoonCount}'),
        HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
      ],
    );
  }
}

class EmployeeNextActionTile extends StatelessWidget {
  final EmployeeNextAction action;

  const EmployeeNextActionTile({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final priorityColor = employeeNextActionPriorityColor(action.priority);
    final statusColor = employeeNextActionStatusColor(action.status);
    final areaIcon = employeeNextActionAreaIcon(action.area);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(areaIcon, color: priorityColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: action.priority.label,
                color: priorityColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(label: action.status.label, color: statusColor),
              _MetaChip(icon: areaIcon, label: action.area.label),
              _MetaChip(
                icon: Icons.person_outline,
                label: action.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.hub_outlined,
                label: action.sourceLabel,
                color: HrisColors.muted,
              ),
              if (action.dueDate != null)
                _MetaChip(
                  icon: Icons.event_outlined,
                  label: 'Due ${_formatDate(action.dueDate!)}',
                  color: statusColor,
                ),
              _MetaChip(
                icon: Icons.trending_up_outlined,
                label: 'Impact ${action.impactScore}',
                color: priorityColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
