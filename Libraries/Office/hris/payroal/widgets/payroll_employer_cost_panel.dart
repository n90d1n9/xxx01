import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollEmployerCostPanel extends StatelessWidget {
  final PayrollEmployerCostSummary summary;

  const PayrollEmployerCostPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Employer cost insights',
      subtitle: summary.periodLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Employer cost',
              value: payrollCurrencyFormat.format(summary.totalEmployerCost),
            ),
            HrisMetricStripItem(
              label: 'Liabilities',
              value: payrollCurrencyFormat.format(
                summary.totalLiabilityAllocation,
              ),
            ),
            HrisMetricStripItem(
              label: 'Budget left',
              value: payrollCurrencyFormat.format(summary.totalBudgetVariance),
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.watchCount + summary.overBudgetCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.trending_up_outlined,
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
        for (final line in summary.lines) _EmployerCostTile(line: line),
      ],
    );
  }
}

class _EmployerCostTile extends StatelessWidget {
  final PayrollEmployerCostLine line;

  const _EmployerCostTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(line.status);

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
            child: Icon(_statusIcon(line.status), color: color, size: 20),
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
                            line.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${line.owner} - ${line.employeeCount} employees',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                HrisProgressBar(
                  value: line.utilization.clamp(0, 1),
                  color: color,
                  label:
                      '${(line.utilization * 100).toStringAsFixed(1)}% employer cost budget used',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: payrollCurrencyFormat.format(
                        line.totalEmployerCost,
                      ),
                    ),
                    _MetricChip(
                      icon: Icons.receipt_long_outlined,
                      label: payrollCurrencyFormat.format(
                        line.liabilityAllocation,
                      ),
                    ),
                    _MetricChip(
                      icon: Icons.savings_outlined,
                      label:
                          '${(line.liabilityRate * 100).toStringAsFixed(1)}% liability load',
                    ),
                    _MetricChip(
                      icon: Icons.balance_outlined,
                      label: payrollCurrencyFormat.format(line.budgetVariance),
                    ),
                  ],
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

Color _statusColor(PayrollEmployerCostStatus status) {
  return switch (status) {
    PayrollEmployerCostStatus.onTrack => const Color(0xFF15803D),
    PayrollEmployerCostStatus.watch => const Color(0xFFB45309),
    PayrollEmployerCostStatus.overBudget => const Color(0xFFB91C1C),
  };
}

IconData _statusIcon(PayrollEmployerCostStatus status) {
  return switch (status) {
    PayrollEmployerCostStatus.onTrack => Icons.check_circle_outline,
    PayrollEmployerCostStatus.watch => Icons.visibility_outlined,
    PayrollEmployerCostStatus.overBudget => Icons.warning_amber_outlined,
  };
}
