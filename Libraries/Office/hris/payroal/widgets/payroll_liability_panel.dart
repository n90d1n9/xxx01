import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollLiabilityPanel extends StatelessWidget {
  final PayrollLiabilitySummary summary;
  final VoidCallback onRemitLiabilities;
  final VoidCallback onReopenRemittance;

  const PayrollLiabilityPanel({
    super.key,
    required this.summary,
    required this.onRemitLiabilities,
    required this.onReopenRemittance,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);
    final nextDue = summary.nextDueLine;

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Payroll liabilities',
      subtitle:
          '${summary.remittanceId} - ${DateFormat('MMM d, yyyy').format(summary.payDate)}',
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
                          icon: Icons.receipt_long_outlined,
                          label:
                              '${summary.remittedCount}/${summary.lines.length} remitted',
                        ),
                        _MetricChip(
                          icon: Icons.payments_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.pendingAmount,
                          ),
                        ),
                        if (nextDue != null)
                          _MetricChip(
                            icon: Icons.event_outlined,
                            label:
                                'Next due ${DateFormat('MMM d').format(nextDue.dueDate)}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (summary.status ==
                      PayrollLiabilityRemittanceStatus.remitted)
                    OutlinedButton.icon(
                      onPressed: onReopenRemittance,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: summary.canRemit ? onRemitLiabilities : null,
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('Remit liabilities'),
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
        for (final line in summary.lines) _LiabilityLineTile(line: line),
      ],
    );
  }
}

class _LiabilityLineTile extends StatelessWidget {
  final PayrollLiabilityLine line;

  const _LiabilityLineTile({required this.line});

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
                            line.recipientName,
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
                      label: payrollCurrencyFormat.format(line.amount),
                    ),
                    _MetricChip(
                      icon: Icons.account_balance_outlined,
                      label: line.methodLabel,
                    ),
                    _MetricChip(
                      icon: Icons.confirmation_number_outlined,
                      label: line.referenceCode,
                    ),
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(line.dueDate),
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

Color _statusColor(PayrollLiabilityRemittanceStatus status) {
  return switch (status) {
    PayrollLiabilityRemittanceStatus.blocked => const Color(0xFFB91C1C),
    PayrollLiabilityRemittanceStatus.ready => const Color(0xFF2563EB),
    PayrollLiabilityRemittanceStatus.remitting => const Color(0xFFB45309),
    PayrollLiabilityRemittanceStatus.remitted => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollLiabilityRemittanceStatus status) {
  return switch (status) {
    PayrollLiabilityRemittanceStatus.blocked => Icons.lock_outlined,
    PayrollLiabilityRemittanceStatus.ready => Icons.playlist_add_check_outlined,
    PayrollLiabilityRemittanceStatus.remitting => Icons.sync_outlined,
    PayrollLiabilityRemittanceStatus.remitted => Icons.verified_outlined,
  };
}

Color _lineStatusColor(PayrollLiabilityLine line) {
  if (line.isRemitted) return const Color(0xFF15803D);
  if (line.hasBlockers) return const Color(0xFFB91C1C);
  return const Color(0xFF2563EB);
}

IconData _lineStatusIcon(PayrollLiabilityLine line) {
  if (line.isRemitted) return Icons.verified_outlined;
  if (line.hasBlockers) return Icons.warning_amber_outlined;
  return Icons.account_balance_wallet_outlined;
}
