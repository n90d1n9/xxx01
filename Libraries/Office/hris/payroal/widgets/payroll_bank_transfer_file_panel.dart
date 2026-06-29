import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollBankTransferFilePanel extends StatelessWidget {
  final PayrollBankTransferFileSummary summary;
  final VoidCallback onExportFile;
  final VoidCallback onReopenFile;

  const PayrollBankTransferFilePanel({
    super.key,
    required this.summary,
    required this.onExportFile,
    required this.onReopenFile,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Bank transfer file',
      subtitle:
          '${summary.fileId} - ${DateFormat('MMM d, yyyy').format(summary.payDate)}',
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
                          label: '${summary.recipientCount} bank recipients',
                        ),
                        _MetricChip(
                          icon: Icons.wallet_outlined,
                          label:
                              '${summary.nonBankRecipientCount} non-bank recipients',
                        ),
                        _MetricChip(
                          icon: Icons.savings_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.totalAmount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  summary.isExported
                      ? OutlinedButton.icon(
                        onPressed: onReopenFile,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reopen'),
                      )
                      : FilledButton.tonalIcon(
                        onPressed: summary.canExport ? onExportFile : null,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Export file'),
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
        for (final line in summary.lines) _BankTransferLineTile(line: line),
      ],
    );
  }
}

class _BankTransferLineTile extends StatelessWidget {
  final PayrollBankTransferFileLine line;

  const _BankTransferLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.hasBlockers ? const Color(0xFFB91C1C) : const Color(0xFF2563EB);

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
              line.hasBlockers
                  ? Icons.warning_amber_outlined
                  : Icons.account_balance_wallet_outlined,
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
                            line.destinationLabel,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: line.isReleased ? 'Released' : 'Prepared',
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
                      label: line.referenceCode,
                    ),
                    _MetricChip(
                      icon: Icons.account_balance_outlined,
                      label: line.fundingSource,
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

Color _statusColor(PayrollBankTransferFileStatus status) {
  return switch (status) {
    PayrollBankTransferFileStatus.blocked => const Color(0xFFB91C1C),
    PayrollBankTransferFileStatus.ready => const Color(0xFF2563EB),
    PayrollBankTransferFileStatus.exported => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollBankTransferFileStatus status) {
  return switch (status) {
    PayrollBankTransferFileStatus.blocked => Icons.lock_outlined,
    PayrollBankTransferFileStatus.ready => Icons.file_download_outlined,
    PayrollBankTransferFileStatus.exported =>
      Icons.assignment_turned_in_outlined,
  };
}
