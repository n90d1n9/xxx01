import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollCostCenterPanel extends StatelessWidget {
  final PayrollCostCenterSummary summary;

  const PayrollCostCenterPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Cost center breakdown',
      subtitle: summary.periodLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Centers',
              value: '${summary.lines.length}',
            ),
            HrisMetricStripItem(
              label: 'Employees',
              value: '${summary.totalEmployeeCount}',
            ),
            HrisMetricStripItem(
              label: 'Gross',
              value: payrollCurrencyFormat.format(summary.totalGrossPayroll),
            ),
            HrisMetricStripItem(
              label: 'Risks',
              value: '${summary.totalRiskCount}',
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
        for (final line in summary.lines) _CostCenterLineTile(line: line),
      ],
    );
  }
}

class _CostCenterLineTile extends StatelessWidget {
  final PayrollCostCenterLine line;

  const _CostCenterLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.riskCount == 0 ? const Color(0xFF15803D) : const Color(0xFFB45309);

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
            child: Icon(Icons.business_center_outlined, color: color, size: 20),
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
                            '${line.employeeCount} employees',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label:
                          line.riskCount == 0
                              ? 'Clear'
                              : '${line.riskCount} risks',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HrisProgressBar(
                  value: line.completionRate,
                  color: color,
                  label:
                      '${line.paidCount}/${line.employeeCount} employee payments released',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: payrollCurrencyFormat.format(line.grossPayroll),
                    ),
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.netPayroll),
                    ),
                    _MetricChip(
                      icon: Icons.receipt_long_outlined,
                      label:
                          '${(line.deductionRate * 100).toStringAsFixed(1)}% deductions',
                    ),
                    _MetricChip(
                      icon: Icons.tune_outlined,
                      label:
                          '${payrollCurrencyFormat.format(line.approvedAdjustmentTotal)} adjustments',
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
