import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollJournalPostingPanel extends StatelessWidget {
  final PayrollJournalPostingSummary summary;
  final VoidCallback onPostJournal;
  final VoidCallback onReopenPosting;

  const PayrollJournalPostingPanel({
    super.key,
    required this.summary,
    required this.onPostJournal,
    required this.onReopenPosting,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _summaryStatusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.request_quote_outlined,
      title: 'Finance journal posting',
      subtitle:
          '${summary.journalId} - ${DateFormat('MMM d, yyyy').format(summary.postingDate)}',
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
                          icon: Icons.call_made_outlined,
                          label:
                              '${payrollCurrencyFormat.format(summary.totalDebits)} debits',
                        ),
                        _MetricChip(
                          icon: Icons.call_received_outlined,
                          label:
                              '${payrollCurrencyFormat.format(summary.totalCredits)} credits',
                        ),
                        _MetricChip(
                          icon: Icons.balance_outlined,
                          label:
                              '${payrollCurrencyFormat.format(summary.balanceVariance)} variance',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (summary.status == PayrollJournalPostingStatus.posted)
                    OutlinedButton.icon(
                      onPressed: onReopenPosting,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: summary.canPost ? onPostJournal : null,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Post journal'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _summaryIcon(summary.status),
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
              if (summary.hasBlockers) ...[
                const SizedBox(height: 8),
                Text(
                  summary.blockers.first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        for (final line in summary.lines) _JournalLineTile(line: line),
      ],
    );
  }
}

class _JournalLineTile extends StatelessWidget {
  final PayrollJournalLine line;

  const _JournalLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _lineTypeColor(line.type);

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
            child: Icon(_lineTypeIcon(line.type), color: color, size: 20),
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
                            '${line.accountCode} ${line.accountName}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.memo,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.type.label, color: color),
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
                      icon: Icons.receipt_long_outlined,
                      label: line.id,
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

Color _summaryStatusColor(PayrollJournalPostingStatus status) {
  return switch (status) {
    PayrollJournalPostingStatus.blocked => const Color(0xFFB91C1C),
    PayrollJournalPostingStatus.ready => const Color(0xFF2563EB),
    PayrollJournalPostingStatus.posted => const Color(0xFF15803D),
  };
}

IconData _summaryIcon(PayrollJournalPostingStatus status) {
  return switch (status) {
    PayrollJournalPostingStatus.blocked => Icons.lock_outlined,
    PayrollJournalPostingStatus.ready => Icons.playlist_add_check_outlined,
    PayrollJournalPostingStatus.posted => Icons.verified_outlined,
  };
}

Color _lineTypeColor(PayrollJournalLineType type) {
  return switch (type) {
    PayrollJournalLineType.debit => const Color(0xFF2563EB),
    PayrollJournalLineType.credit => const Color(0xFF15803D),
  };
}

IconData _lineTypeIcon(PayrollJournalLineType type) {
  return switch (type) {
    PayrollJournalLineType.debit => Icons.call_made_outlined,
    PayrollJournalLineType.credit => Icons.call_received_outlined,
  };
}
