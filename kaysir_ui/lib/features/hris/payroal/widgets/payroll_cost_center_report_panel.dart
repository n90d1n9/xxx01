import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollCostCenterReportPanel extends StatelessWidget {
  final PayrollCostCenterReportSummary summary;
  final VoidCallback onExportReport;
  final VoidCallback onReopenReport;

  const PayrollCostCenterReportPanel({
    super.key,
    required this.summary,
    required this.onExportReport,
    required this.onReopenReport,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.assessment_outlined,
      title: 'Cost center payroll report',
      subtitle: '${summary.reportId} - ${summary.periodLabel}',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        HrisStatusPill(
                          label: summary.status.label,
                          color: statusColor,
                        ),
                        _MetricChip(
                          icon: Icons.account_tree_outlined,
                          label: '${summary.costCenterCount} centers',
                        ),
                        _MetricChip(
                          icon: Icons.verified_outlined,
                          label:
                              '${summary.approvedCount}/${summary.costCenterCount} approved',
                        ),
                        _MetricChip(
                          icon: Icons.warning_amber_outlined,
                          label: '${summary.blockedCount} blockers',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  summary.isExported
                      ? OutlinedButton.icon(
                        onPressed: onReopenReport,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reopen'),
                      )
                      : FilledButton.tonalIcon(
                        onPressed: summary.canExport ? onExportReport : null,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Export'),
                      ),
                ],
              ),
              const SizedBox(height: 12),
              HrisMetricStrip(
                items: [
                  HrisMetricStripItem(
                    label: 'Budget',
                    value: payrollCurrencyFormat.format(summary.totalBudget),
                  ),
                  HrisMetricStripItem(
                    label: 'Gross',
                    value: payrollCurrencyFormat.format(
                      summary.totalGrossPayroll,
                    ),
                  ),
                  HrisMetricStripItem(
                    label: 'Net',
                    value: payrollCurrencyFormat.format(
                      summary.totalNetPayroll,
                    ),
                  ),
                  HrisMetricStripItem(
                    label: 'Deductions',
                    value: payrollCurrencyFormat.format(
                      summary.totalDeductions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _statusIcon(summary.status),
                    color: statusColor,
                    size: 19,
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
            ],
          ),
        ),
        for (final line in summary.lines) _CostCenterReportLineTile(line: line),
      ],
    );
  }
}

class _CostCenterReportLineTile extends StatelessWidget {
  final PayrollCostCenterReportLine line;

  const _CostCenterReportLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.hasBlockers ? const Color(0xFFB45309) : const Color(0xFF15803D);
    final utilization = (line.utilization * 100).clamp(0, 999);

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
            child: Icon(Icons.summarize_outlined, color: color, size: 20),
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
                            line.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: line.hasBlockers ? 'Blocked' : 'Ready',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HrisProgressBar(
                  value: line.utilization.clamp(0, 1),
                  color: color,
                  label:
                      '${utilization.toStringAsFixed(1)}% of approved budget used',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.people_alt_outlined,
                      label: '${line.employeeCount} employees',
                    ),
                    _MetricChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: payrollCurrencyFormat.format(line.grossPayroll),
                    ),
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.netPayroll),
                    ),
                    _MetricChip(
                      icon: Icons.savings_outlined,
                      label:
                          '${payrollCurrencyFormat.format(line.remainingBudget)} remaining',
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

Color _statusColor(PayrollCostCenterReportStatus status) {
  return switch (status) {
    PayrollCostCenterReportStatus.blocked => const Color(0xFFB45309),
    PayrollCostCenterReportStatus.ready => const Color(0xFF15803D),
    PayrollCostCenterReportStatus.exported => HrisColors.primary,
  };
}

IconData _statusIcon(PayrollCostCenterReportStatus status) {
  return switch (status) {
    PayrollCostCenterReportStatus.blocked => Icons.pending_actions_outlined,
    PayrollCostCenterReportStatus.ready => Icons.assignment_turned_in_outlined,
    PayrollCostCenterReportStatus.exported => Icons.cloud_done_outlined,
  };
}
