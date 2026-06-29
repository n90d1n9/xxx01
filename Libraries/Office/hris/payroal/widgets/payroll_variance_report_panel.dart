import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollVarianceReportPanel extends StatelessWidget {
  final PayrollVarianceReportSummary summary;
  final VoidCallback onExportReport;
  final VoidCallback onReopenReport;

  const PayrollVarianceReportPanel({
    super.key,
    required this.summary,
    required this.onExportReport,
    required this.onReopenReport,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.difference_outlined,
      title: 'Variance report',
      subtitle: '${summary.periodLabel} vs ${summary.baselinePeriodLabel}',
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
                          icon: Icons.trending_up_outlined,
                          label:
                              '${summary.materialVarianceCount} material variances',
                        ),
                        _MetricChip(
                          icon: Icons.payments_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.largestVarianceAmount,
                          ),
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
        for (final line in summary.lines) _VarianceReportLine(line: line),
      ],
    );
  }
}

class _VarianceReportLine extends StatelessWidget {
  final PayrollVarianceLine line;

  const _VarianceReportLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _lineStatusColor(line.status);

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
            child: Icon(_lineIcon(line), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(label: line.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label:
                          'Current ${payrollCurrencyFormat.format(line.currentAmount)}',
                    ),
                    _MetricChip(
                      icon: Icons.history_outlined,
                      label:
                          'Baseline ${payrollCurrencyFormat.format(line.baselineAmount)}',
                    ),
                    _MetricChip(
                      icon:
                          line.delta >= 0
                              ? Icons.arrow_upward_outlined
                              : Icons.arrow_downward_outlined,
                      label:
                          '${payrollCurrencyFormat.format(line.delta.abs())} ${_formatPercent(line.percentChange)}',
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

String _formatPercent(double value) {
  final sign = value >= 0 ? '+' : '-';
  return '($sign${value.abs().toStringAsFixed(1)}%)';
}

Color _statusColor(PayrollVarianceReportStatus status) {
  return switch (status) {
    PayrollVarianceReportStatus.blocked => const Color(0xFFB91C1C),
    PayrollVarianceReportStatus.ready => const Color(0xFF2563EB),
    PayrollVarianceReportStatus.exported => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollVarianceReportStatus status) {
  return switch (status) {
    PayrollVarianceReportStatus.blocked => Icons.lock_outlined,
    PayrollVarianceReportStatus.ready => Icons.file_download_outlined,
    PayrollVarianceReportStatus.exported => Icons.assignment_turned_in_outlined,
  };
}

Color _lineStatusColor(PayrollVarianceStatus status) {
  return switch (status) {
    PayrollVarianceStatus.stable => const Color(0xFF15803D),
    PayrollVarianceStatus.watch => const Color(0xFFB45309),
    PayrollVarianceStatus.review => const Color(0xFFB91C1C),
  };
}

IconData _lineIcon(PayrollVarianceLine line) {
  if (line.status == PayrollVarianceStatus.stable) {
    return Icons.check_circle_outline;
  }
  if (line.delta >= 0) return Icons.trending_up_outlined;
  return Icons.trending_down_outlined;
}
