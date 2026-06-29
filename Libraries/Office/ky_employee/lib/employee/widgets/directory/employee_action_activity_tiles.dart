import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_activity_models.dart';
import 'employee_action_activity_styles.dart';

class EmployeeActionActivitySummaryStrip extends StatelessWidget {
  final EmployeeActionActivityProfile profile;

  const EmployeeActionActivitySummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Updates',
          value: '${profile.entries.length}',
        ),
        HrisMetricStripItem(
          label: 'Blockers',
          value: '${profile.blockerCount}',
        ),
        HrisMetricStripItem(
          label: 'Escalated',
          value: '${profile.escalationCount}',
        ),
        HrisMetricStripItem(
          label: 'Pending',
          value: '${profile.pendingAcknowledgementCount}',
        ),
      ],
    );
  }
}

class EmployeeActionActivityEntryTile extends StatelessWidget {
  final EmployeeActionActivityEntry entry;
  final VoidCallback onAcknowledge;

  const EmployeeActionActivityEntryTile({
    super.key,
    required this.entry,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = employeeActionActivityTypeColor(entry.type);
    final visibilityColor =
        entry.visibility == EmployeeActionActivityVisibility.private
            ? const Color(0xFF7C3AED)
            : HrisColors.primary;

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
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeActionActivityTypeIcon(entry.type),
                  color: typeColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.taskTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: entry.type.label, color: typeColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.person_outline,
                label: entry.author,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon:
                    entry.visibility == EmployeeActionActivityVisibility.private
                        ? Icons.lock_outline
                        : Icons.groups_outlined,
                label: entry.visibility.label,
                color: visibilityColor,
              ),
              _MetaChip(
                icon: Icons.schedule_outlined,
                label: DateFormat('MMM d, yyyy').format(entry.createdAt),
              ),
              if (entry.requiresAcknowledgement)
                _MetaChip(
                  icon: Icons.notification_important_outlined,
                  label: 'Needs acknowledgement',
                  color: const Color(0xFFD97706),
                ),
            ],
          ),
          if (entry.requiresAcknowledgement) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Acknowledge'),
              ),
            ),
          ],
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
