import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_relations_models.dart';
import 'employee_relations_styles.dart';

class EmployeeRelationsSummaryStrip extends StatelessWidget {
  final EmployeeRelationsProfile profile;

  const EmployeeRelationsSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Recognition',
          value: '${profile.recognitionCount}',
        ),
        HrisMetricStripItem(
          label: 'Corrective',
          value: '${profile.correctiveOpenCount}',
        ),
        HrisMetricStripItem(
          label: 'Overdue',
          value: '${profile.overdueFollowUpCount}',
        ),
        HrisMetricStripItem(
          label: 'Attention',
          value: '${profile.attentionCount}',
        ),
      ],
    );
  }
}

class EmployeeRelationsEventTile extends StatelessWidget {
  final EmployeeRelationsEvent event;
  final DateTime asOfDate;
  final VoidCallback onStartFollowUp;
  final VoidCallback onResolve;
  final VoidCallback onArchive;

  const EmployeeRelationsEventTile({
    super.key,
    required this.event,
    required this.asOfDate,
    required this.onStartFollowUp,
    required this.onResolve,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = event.isOverdue(asOfDate);
    final statusColor =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeRelationsStatusColor(event.status);
    final severityColor = employeeRelationsSeverityColor(event.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeRelationsEventTypeIcon(event.type),
            title: event.title,
            subtitle: '${event.type.label} - ${event.owner}',
            color: event.isPositive ? const Color(0xFF7C3AED) : statusColor,
            status: HrisStatusPill(
              label: overdue ? 'Overdue' : event.status.label,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            event.summary,
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
                icon: Icons.event_available_outlined,
                label: 'Occurred ${_formatDate(event.occurredAt)}',
              ),
              if (event.followUpDate != null)
                _MetaChip(
                  icon: Icons.notification_important_outlined,
                  label: 'Follow-up ${_formatDate(event.followUpDate!)}',
                  color: overdue ? const Color(0xFFB91C1C) : null,
                ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: event.severity.label,
                color: severityColor,
              ),
              _MetaChip(
                icon: employeeRelationsVisibilityIcon(event.visibility),
                label: event.visibility.label,
                color:
                    event.visibility == EmployeeRelationsVisibility.confidential
                        ? const Color(0xFFB45309)
                        : null,
              ),
            ],
          ),
          if (event.isOpen ||
              event.status == EmployeeRelationsStatus.documented) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (event.isOpen &&
                    event.status != EmployeeRelationsStatus.inProgress)
                  OutlinedButton.icon(
                    onPressed: onStartFollowUp,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Start follow-up'),
                  ),
                if (event.isOpen)
                  FilledButton.tonalIcon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Resolve'),
                  ),
                OutlinedButton.icon(
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archive'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget status;

  const _TileHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status,
      ],
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

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
