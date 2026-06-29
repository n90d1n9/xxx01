import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollRegisterReportPanel extends StatelessWidget {
  final PayrollRegisterReportSummary summary;
  final VoidCallback onExportReport;
  final VoidCallback onReopenReport;

  const PayrollRegisterReportPanel({
    super.key,
    required this.summary,
    required this.onExportReport,
    required this.onReopenReport,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.summarize_outlined,
      title: 'Payroll register report',
      subtitle:
          '${summary.reportId} - ${DateFormat('MMM d, yyyy').format(summary.payDate)}',
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
                          icon: Icons.people_alt_outlined,
                          label: '${summary.employeeCount} employees',
                        ),
                        _MetricChip(
                          icon: Icons.task_alt_outlined,
                          label:
                              '${summary.completeLineCount}/${summary.employeeCount} complete',
                        ),
                        _MetricChip(
                          icon: Icons.savings_outlined,
                          label: payrollCurrencyFormat.format(summary.totalNet),
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
                    label: 'Gross',
                    value: payrollCurrencyFormat.format(summary.totalGross),
                  ),
                  HrisMetricStripItem(
                    label: 'Adjustments',
                    value: payrollCurrencyFormat.format(
                      summary.totalAdjustments,
                    ),
                  ),
                  HrisMetricStripItem(
                    label: 'Deductions',
                    value: payrollCurrencyFormat.format(
                      summary.totalDeductions,
                    ),
                  ),
                  HrisMetricStripItem(
                    label: 'Liabilities',
                    value: payrollCurrencyFormat.format(
                      summary.liabilityAmount,
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
        for (final line in summary.lines.take(4))
          _RegisterReportLineTile(line: line),
      ],
    );
  }
}

class _RegisterReportLineTile extends StatelessWidget {
  final PayrollRegisterReportLine line;

  const _RegisterReportLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.isComplete ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              line.isComplete
                  ? Icons.assignment_turned_in_outlined
                  : Icons.pending_actions_outlined,
              color: color,
              size: 20,
            ),
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
                            line.employeeName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.statementId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: line.isComplete ? 'Complete' : 'Pending',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.netAmount),
                    ),
                    _MetricChip(
                      icon: Icons.confirmation_number_outlined,
                      label: line.paymentReferenceCode,
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

Color _statusColor(PayrollRegisterReportStatus status) {
  return switch (status) {
    PayrollRegisterReportStatus.blocked => const Color(0xFFB91C1C),
    PayrollRegisterReportStatus.ready => const Color(0xFF2563EB),
    PayrollRegisterReportStatus.exported => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollRegisterReportStatus status) {
  return switch (status) {
    PayrollRegisterReportStatus.blocked => Icons.lock_outlined,
    PayrollRegisterReportStatus.ready => Icons.file_download_outlined,
    PayrollRegisterReportStatus.exported => Icons.assignment_turned_in_outlined,
  };
}
