import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollReportsHubPanel extends StatelessWidget {
  final PayrollReportsHubSummary summary;

  const PayrollReportsHubPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.folder_copy_outlined,
      title: 'Payroll reports hub',
      subtitle: summary.periodLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Artifacts',
              value: summary.items.length.toString(),
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: summary.blockedCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Ready',
              value: summary.readyCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Complete',
              value: summary.completeCount.toString(),
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.rule_folder_outlined,
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
        for (final item in summary.items) _ReportHubItemTile(item: item),
      ],
    );
  }
}

class _ReportHubItemTile extends StatelessWidget {
  final PayrollReportHubItem item;

  const _ReportHubItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);

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
                            item.id,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: item.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.category_outlined,
                      label: item.category.label,
                    ),
                    _MetricChip(
                      icon: Icons.person_pin_circle_outlined,
                      label: item.owner,
                    ),
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(item.generatedOn),
                    ),
                    if (item.amount > 0)
                      _MetricChip(
                        icon: Icons.payments_outlined,
                        label: payrollCurrencyFormat.format(item.amount),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.nextAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: item.isBlocked ? color : HrisColors.ink,
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

Color _statusColor(PayrollReportHubStatus status) {
  return switch (status) {
    PayrollReportHubStatus.blocked => const Color(0xFFB91C1C),
    PayrollReportHubStatus.ready => const Color(0xFF2563EB),
    PayrollReportHubStatus.complete => const Color(0xFF15803D),
  };
}

IconData _categoryIcon(PayrollReportHubCategory category) {
  return switch (category) {
    PayrollReportHubCategory.finance => Icons.assessment_outlined,
    PayrollReportHubCategory.payments => Icons.account_balance_outlined,
    PayrollReportHubCategory.compliance => Icons.policy_outlined,
    PayrollReportHubCategory.audit => Icons.fact_check_outlined,
  };
}
