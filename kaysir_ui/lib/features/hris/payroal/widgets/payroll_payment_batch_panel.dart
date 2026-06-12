import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollPaymentBatchPanel extends StatelessWidget {
  final PayrollPaymentBatchSummary batch;
  final VoidCallback onReleaseBatch;

  const PayrollPaymentBatchPanel({
    super.key,
    required this.batch,
    required this.onReleaseBatch,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _batchStatusColor(batch.status);

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Payment batch',
      subtitle:
          '${batch.batchId} - ${DateFormat('MMM d, yyyy').format(batch.payDate)}',
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
                          label: batch.status.label,
                          color: statusColor,
                        ),
                        _MetricChip(
                          icon: Icons.payments_outlined,
                          label:
                              '${payrollCurrencyFormat.format(batch.pendingNet)} pending',
                        ),
                        _MetricChip(
                          icon: Icons.people_alt_outlined,
                          label:
                              '${batch.readyRecipientCount}/${batch.pendingCount} ready',
                        ),
                        _MetricChip(
                          icon: Icons.rocket_launch_outlined,
                          label: batch.activeRunPlanLabel,
                        ),
                        _MetricChip(
                          icon: Icons.tune_outlined,
                          label:
                              '${payrollCurrencyFormat.format(batch.adjustmentTotal)} adjustments',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: batch.canRelease ? onReleaseBatch : null,
                    icon: const Icon(Icons.send_to_mobile_outlined),
                    label: const Text('Release batch'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_batchIcon(batch.status), color: statusColor, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      batch.nextAction,
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
        for (final line in batch.lines) _PaymentBatchLineTile(line: line),
      ],
    );
  }
}

class _PaymentBatchLineTile extends StatelessWidget {
  final PayrollPaymentBatchLine line;

  const _PaymentBatchLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _lineStatusColor(line);

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
            child: Icon(_lineStatusIcon(line), color: color, size: 20),
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
                            line.position,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.savings_outlined,
                      label: payrollCurrencyFormat.format(line.netAmount),
                    ),
                    _MetricChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: line.method.label,
                    ),
                    _MetricChip(
                      icon: Icons.credit_card_outlined,
                      label: line.destinationLabel,
                    ),
                    _MetricChip(
                      icon: Icons.confirmation_number_outlined,
                      label: line.referenceCode,
                    ),
                  ],
                ),
                if (line.hasBlockers) ...[
                  const SizedBox(height: 8),
                  Text(
                    line.blockers.first,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
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

Color _batchStatusColor(PayrollPaymentBatchStatus status) {
  return switch (status) {
    PayrollPaymentBatchStatus.blocked => const Color(0xFFB91C1C),
    PayrollPaymentBatchStatus.ready => const Color(0xFF2563EB),
    PayrollPaymentBatchStatus.releasing => const Color(0xFFB45309),
    PayrollPaymentBatchStatus.released => const Color(0xFF15803D),
  };
}

IconData _batchIcon(PayrollPaymentBatchStatus status) {
  return switch (status) {
    PayrollPaymentBatchStatus.blocked => Icons.lock_outlined,
    PayrollPaymentBatchStatus.ready => Icons.playlist_add_check_outlined,
    PayrollPaymentBatchStatus.releasing => Icons.sync_outlined,
    PayrollPaymentBatchStatus.released => Icons.verified_outlined,
  };
}

Color _lineStatusColor(PayrollPaymentBatchLine line) {
  if (line.isPaid) return const Color(0xFF15803D);
  if (line.hasBlockers) return const Color(0xFFB91C1C);
  return const Color(0xFF2563EB);
}

IconData _lineStatusIcon(PayrollPaymentBatchLine line) {
  if (line.isPaid) return Icons.verified_outlined;
  if (line.hasBlockers) return Icons.warning_amber_outlined;
  return Icons.schedule_send_outlined;
}
