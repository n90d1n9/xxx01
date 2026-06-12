import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollRiskRegisterPanel extends StatelessWidget {
  final PayrollRiskRegisterSummary summary;

  const PayrollRiskRegisterPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.health_and_safety_outlined,
      title: 'Risk register',
      subtitle:
          '${summary.periodLabel} - ${DateFormat('MMM d, yyyy').format(summary.asOfDate)}',
      emptyMessage: 'No active payroll close risks',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.items.length}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalCount}',
            ),
            HrisMetricStripItem(label: 'High', value: '${summary.highCount}'),
            HrisMetricStripItem(
              label: 'Due today',
              value: '${summary.dueTodayCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.priority_high_outlined,
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
        for (final item in summary.items) _RiskRegisterTile(item: item),
      ],
    );
  }
}

class _RiskRegisterTile extends StatelessWidget {
  final PayrollRiskRegisterItem item;

  const _RiskRegisterTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(item.severity);

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
            child: Icon(_categoryIcon(item.category), color: color, size: 20),
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
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${item.category.label} - ${item.sourceLabel}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: item.severity.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.person_pin_circle_outlined,
                      label: item.owner,
                    ),
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d, yyyy').format(item.dueDate),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.action,
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

Color _severityColor(PayrollRiskSeverity severity) {
  return switch (severity) {
    PayrollRiskSeverity.critical => const Color(0xFF991B1B),
    PayrollRiskSeverity.high => const Color(0xFFB45309),
    PayrollRiskSeverity.medium => const Color(0xFF2563EB),
    PayrollRiskSeverity.low => const Color(0xFF64748B),
  };
}

IconData _categoryIcon(PayrollRiskCategory category) {
  return switch (category) {
    PayrollRiskCategory.exception => Icons.report_problem_outlined,
    PayrollRiskCategory.approval => Icons.rule_folder_outlined,
    PayrollRiskCategory.funding => Icons.account_balance_wallet_outlined,
    PayrollRiskCategory.compliance => Icons.event_note_outlined,
    PayrollRiskCategory.release => Icons.send_to_mobile_outlined,
  };
}
