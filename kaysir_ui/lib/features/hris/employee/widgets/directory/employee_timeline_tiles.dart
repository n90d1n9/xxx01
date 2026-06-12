import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_timeline_models.dart';
import 'employee_timeline_styles.dart';

class EmployeeTimelineSummaryStrip extends StatelessWidget {
  final EmployeeTimelineProfile profile;

  const EmployeeTimelineSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Pinned', value: '${profile.pinnedCount}'),
        HrisMetricStripItem(
          label: 'Follow-ups',
          value: '${profile.openFollowUpCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
        HrisMetricStripItem(label: 'Recent', value: '${profile.recentCount}'),
      ],
    );
  }
}

class EmployeeTimelineEntryTile extends StatelessWidget {
  final EmployeeTimelineEntry entry;
  final DateTime asOfDate;
  final VoidCallback onResolve;
  final VoidCallback onReopen;
  final VoidCallback onTogglePinned;

  const EmployeeTimelineEntryTile({
    super.key,
    required this.entry,
    required this.asOfDate,
    required this.onResolve,
    required this.onReopen,
    required this.onTogglePinned,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = entry.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeTimelinePriorityColor(entry.priority);
    final statusColor = employeeTimelineStatusColor(entry.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeTimelineTypeIcon(entry.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.type.label} - ${entry.owner}',
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
                label: overdue ? 'Overdue' : entry.priority.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.event_outlined,
                label: DateFormat('MMM d, yyyy').format(entry.occurredAt),
              ),
              if (entry.dueAt != null)
                _MetaChip(
                  icon: Icons.flag_outlined,
                  label:
                      'Follow-up ${DateFormat('MMM d').format(entry.dueAt!)}',
                  color: overdue ? const Color(0xFFB91C1C) : null,
                ),
              _MetaChip(
                icon: Icons.radio_button_checked_outlined,
                label: entry.status.label,
                color: statusColor,
              ),
              if (entry.pinned)
                _MetaChip(
                  icon: Icons.push_pin_outlined,
                  label: 'Pinned',
                  color: HrisColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onTogglePinned,
                icon: Icon(
                  entry.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                label: Text(entry.pinned ? 'Unpin' : 'Pin'),
              ),
              if (entry.canReopen)
                FilledButton.tonalIcon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reopen'),
                ),
              if (entry.canResolve)
                FilledButton.icon(
                  onPressed: onResolve,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Resolve'),
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
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
