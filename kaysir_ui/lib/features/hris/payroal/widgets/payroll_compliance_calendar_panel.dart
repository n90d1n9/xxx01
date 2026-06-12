import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollComplianceCalendarPanel extends StatelessWidget {
  final PayrollComplianceCalendarSummary summary;

  const PayrollComplianceCalendarPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.event_note_outlined,
      title: 'Compliance calendar',
      subtitle:
          '${summary.periodLabel} - ${DateFormat('MMM d, yyyy').format(summary.asOfDate)}',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Complete',
              value: '${summary.completedCount}/${summary.milestones.length}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.flag_circle_outlined,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.nextAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final milestone in summary.milestones)
          _ComplianceMilestoneTile(milestone: milestone),
      ],
    );
  }
}

class _ComplianceMilestoneTile extends StatelessWidget {
  final PayrollComplianceMilestone milestone;

  const _ComplianceMilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(milestone.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(milestone.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            milestone.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: milestone.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat(
                        'MMM d, yyyy',
                      ).format(milestone.dueDate),
                    ),
                    _MetricChip(
                      icon: Icons.badge_outlined,
                      label: milestone.owner,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  milestone.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollComplianceMilestoneStatus status) {
  return switch (status) {
    PayrollComplianceMilestoneStatus.blocked => const Color(0xFFB91C1C),
    PayrollComplianceMilestoneStatus.upcoming => const Color(0xFF64748B),
    PayrollComplianceMilestoneStatus.dueSoon => const Color(0xFFB45309),
    PayrollComplianceMilestoneStatus.overdue => const Color(0xFF991B1B),
    PayrollComplianceMilestoneStatus.complete => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollComplianceMilestoneStatus status) {
  return switch (status) {
    PayrollComplianceMilestoneStatus.blocked => Icons.lock_outlined,
    PayrollComplianceMilestoneStatus.upcoming => Icons.event_outlined,
    PayrollComplianceMilestoneStatus.dueSoon => Icons.schedule_outlined,
    PayrollComplianceMilestoneStatus.overdue => Icons.warning_amber_outlined,
    PayrollComplianceMilestoneStatus.complete => Icons.verified_outlined,
  };
}
