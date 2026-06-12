import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollCutoffCalendarPanel extends StatelessWidget {
  final PayrollCutoffCalendarSummary summary;

  const PayrollCutoffCalendarPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.event_available_outlined,
      title: 'Payroll cutoff rules',
      subtitle:
          '${summary.periodLabel} - pay date ${DateFormat('MMM d, yyyy').format(summary.payDate)}',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Complete',
              value: '${summary.completeCount}/${summary.rules.length}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: summary.blockedCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Due soon',
              value: summary.dueSoonCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Missed',
              value: summary.missedCount.toString(),
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.alarm_on_outlined,
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
        for (final rule in summary.rules)
          _CutoffRuleTile(rule: rule, asOfDate: summary.asOfDate),
      ],
    );
  }
}

class _CutoffRuleTile extends StatelessWidget {
  final PayrollCutoffRule rule;
  final DateTime asOfDate;

  const _CutoffRuleTile({required this.rule, required this.asOfDate});

  @override
  Widget build(BuildContext context) {
    final status = rule.statusOn(asOfDate);
    final color = _statusColor(status);

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
            child: Icon(_statusIcon(status), color: color, size: 20),
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
                            rule.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            rule.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                HrisProgressBar(
                  value: rule.completionRate.clamp(0, 1),
                  color: color,
                  label:
                      '${rule.completedCount}/${rule.requiredCount} required items complete',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d, yyyy').format(rule.cutoffAt),
                    ),
                    _MetricChip(
                      icon: Icons.warning_amber_outlined,
                      label: '${rule.blockerCount} blockers',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rule.detail,
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
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollCutoffRuleStatus status) {
  return switch (status) {
    PayrollCutoffRuleStatus.blocked => const Color(0xFFB91C1C),
    PayrollCutoffRuleStatus.open => const Color(0xFF64748B),
    PayrollCutoffRuleStatus.dueSoon => const Color(0xFFB45309),
    PayrollCutoffRuleStatus.missed => const Color(0xFF991B1B),
    PayrollCutoffRuleStatus.complete => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollCutoffRuleStatus status) {
  return switch (status) {
    PayrollCutoffRuleStatus.blocked => Icons.lock_outlined,
    PayrollCutoffRuleStatus.open => Icons.event_outlined,
    PayrollCutoffRuleStatus.dueSoon => Icons.schedule_outlined,
    PayrollCutoffRuleStatus.missed => Icons.alarm_off_outlined,
    PayrollCutoffRuleStatus.complete => Icons.verified_outlined,
  };
}
