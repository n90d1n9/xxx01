import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_audit_trail_models.dart';
import 'employee_audit_trail_styles.dart';

class EmployeeAuditTrailSummaryStrip extends StatelessWidget {
  final EmployeeAuditTrailProfile profile;

  const EmployeeAuditTrailSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Recent', value: '${profile.recentCount}'),
        HrisMetricStripItem(
          label: 'Review',
          value: '${profile.reviewRequiredCount}',
        ),
        HrisMetricStripItem(
          label: 'Escalated',
          value: '${profile.escalatedCount}',
        ),
        HrisMetricStripItem(
          label: 'Sensitive',
          value: '${profile.sensitiveCount}',
        ),
      ],
    );
  }
}

class EmployeeAuditTrailEntryTile extends StatelessWidget {
  final EmployeeAuditTrailEntry entry;
  final DateTime asOfDate;
  final VoidCallback onReview;
  final VoidCallback onEscalate;
  final VoidCallback onArchive;

  const EmployeeAuditTrailEntryTile({
    super.key,
    required this.entry,
    required this.asOfDate,
    required this.onReview,
    required this.onEscalate,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeAuditTrailReviewStatusColor(entry.reviewStatus);
    final severityColor = employeeAuditTrailSeverityColor(entry.severity);
    final retentionDue = entry.isRetentionDueSoon(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeAuditTrailSourceIcon(entry.source),
            title: entry.title,
            subtitle: '${entry.source.label} - ${entry.actor}',
            color: statusColor,
            status: HrisStatusPill(
              label: entry.reviewStatus.label,
              color: statusColor,
            ),
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
                icon: employeeAuditTrailActionIcon(entry.actionType),
                label: entry.actionType.label,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: entry.severity.label,
                color: severityColor,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Occurred ${_formatDate(entry.occurredAt)}',
              ),
              _MetaChip(
                icon: Icons.policy_outlined,
                label: 'Retain until ${_formatDate(entry.retentionUntil)}',
                color: retentionDue ? const Color(0xFFB45309) : null,
              ),
              if (entry.containsSensitiveData)
                _MetaChip(
                  icon: Icons.lock_outline,
                  label: 'Sensitive',
                  color: const Color(0xFF7C3AED),
                ),
            ],
          ),
          if (_hasActions) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (entry.canReview)
                  FilledButton.tonalIcon(
                    onPressed: onReview,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Mark reviewed'),
                  ),
                if (entry.canEscalate)
                  OutlinedButton.icon(
                    onPressed: onEscalate,
                    icon: const Icon(Icons.priority_high_outlined),
                    label: const Text('Escalate'),
                  ),
                if (entry.canArchive)
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

  bool get _hasActions {
    return entry.canReview || entry.canEscalate || entry.canArchive;
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
            overflow: TextOverflow.ellipsis,
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
