import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollAuditTrailPanel extends StatelessWidget {
  final PayrollAuditTrailSummary summary;

  const PayrollAuditTrailPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final latest = summary.latestEvent;

    return HrisSectionPanel(
      icon: Icons.history_outlined,
      title: 'Audit trail',
      subtitle: summary.periodLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Events',
              value: '${summary.events.length}',
            ),
            HrisMetricStripItem(
              label: 'Complete',
              value: '${summary.completedCount}',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${summary.attentionCount}',
            ),
            HrisMetricStripItem(
              label: 'Latest',
              value:
                  latest == null
                      ? '-'
                      : DateFormat('MMM d').format(latest.eventDate),
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.fact_check_outlined,
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
        for (final event in summary.events.take(10))
          _AuditTrailEventTile(event: event),
      ],
    );
  }
}

class _AuditTrailEventTile extends StatelessWidget {
  final PayrollAuditEvent event;

  const _AuditTrailEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(event.status);

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
            child: Icon(_typeIcon(event.type), color: color, size: 20),
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
                            event.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${event.type.label} - ${event.actor}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: event.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d, yyyy').format(event.eventDate),
                    ),
                    _MetricChip(
                      icon: Icons.person_pin_circle_outlined,
                      label: event.actor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.detail,
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

Color _statusColor(PayrollAuditEventStatus status) {
  return switch (status) {
    PayrollAuditEventStatus.attention => const Color(0xFFB91C1C),
    PayrollAuditEventStatus.pending => const Color(0xFFB45309),
    PayrollAuditEventStatus.recorded => const Color(0xFF2563EB),
    PayrollAuditEventStatus.complete => const Color(0xFF15803D),
  };
}

IconData _typeIcon(PayrollAuditEventType type) {
  return switch (type) {
    PayrollAuditEventType.run => Icons.flag_circle_outlined,
    PayrollAuditEventType.adjustment => Icons.tune_outlined,
    PayrollAuditEventType.exception => Icons.report_problem_outlined,
    PayrollAuditEventType.reconciliation => Icons.balance_outlined,
    PayrollAuditEventType.release => Icons.send_to_mobile_outlined,
    PayrollAuditEventType.compliance => Icons.policy_outlined,
    PayrollAuditEventType.distribution => Icons.ios_share_outlined,
    PayrollAuditEventType.finding => Icons.assignment_late_outlined,
    PayrollAuditEventType.archive => Icons.inventory_2_outlined,
  };
}
