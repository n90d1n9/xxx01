import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollReconciliationPanel extends StatelessWidget {
  final PayrollReconciliationSummary summary;
  final VoidCallback onMarkReviewed;
  final VoidCallback onReopenReview;

  const PayrollReconciliationPanel({
    super.key,
    required this.summary,
    required this.onMarkReviewed,
    required this.onReopenReview,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        summary.isReviewed
            ? const Color(0xFF15803D)
            : _reconciliationStatusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.balance_outlined,
      title: 'Payroll reconciliation',
      subtitle: '${summary.baselinePeriodLabel} baseline',
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
                          label:
                              summary.isReviewed
                                  ? 'Reviewed'
                                  : summary.status.label,
                          color: statusColor,
                        ),
                        _MetricChip(
                          icon: Icons.account_balance_outlined,
                          label:
                              summary.fundingGap > 0
                                  ? '${payrollCurrencyFormat.format(summary.fundingGap)} gap'
                                  : '${payrollCurrencyFormat.format(summary.fundingBuffer)} buffer',
                        ),
                        _MetricChip(
                          icon: Icons.trending_up_outlined,
                          label:
                              '${summary.materialVarianceCount} material variances',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (summary.isReviewed)
                    OutlinedButton.icon(
                      onPressed: onReopenReview,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: summary.canReview ? onMarkReviewed : null,
                      icon: const Icon(Icons.task_alt_outlined),
                      label: const Text('Mark reviewed'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _reconciliationIcon(summary),
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
        for (final line in summary.varianceLines) _VarianceLineTile(line: line),
      ],
    );
  }
}

class _VarianceLineTile extends StatelessWidget {
  final PayrollVarianceLine line;

  const _VarianceLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _varianceStatusColor(line.status);

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
            child: Icon(_varianceIcon(line), color: color, size: 20),
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
                          'Prior ${payrollCurrencyFormat.format(line.baselineAmount)}',
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

Color _reconciliationStatusColor(PayrollReconciliationStatus status) {
  return switch (status) {
    PayrollReconciliationStatus.blocked => const Color(0xFFB91C1C),
    PayrollReconciliationStatus.watch => const Color(0xFFB45309),
    PayrollReconciliationStatus.ready => const Color(0xFF15803D),
  };
}

Color _varianceStatusColor(PayrollVarianceStatus status) {
  return switch (status) {
    PayrollVarianceStatus.stable => const Color(0xFF15803D),
    PayrollVarianceStatus.watch => const Color(0xFFB45309),
    PayrollVarianceStatus.review => const Color(0xFFB91C1C),
  };
}

IconData _reconciliationIcon(PayrollReconciliationSummary summary) {
  if (summary.isReviewed) return Icons.verified_outlined;
  if (summary.status == PayrollReconciliationStatus.blocked) {
    return Icons.warning_amber_outlined;
  }
  return Icons.fact_check_outlined;
}

IconData _varianceIcon(PayrollVarianceLine line) {
  return switch (line.status) {
    PayrollVarianceStatus.stable => Icons.check_circle_outline,
    PayrollVarianceStatus.watch => Icons.troubleshoot_outlined,
    PayrollVarianceStatus.review => Icons.priority_high_outlined,
  };
}
