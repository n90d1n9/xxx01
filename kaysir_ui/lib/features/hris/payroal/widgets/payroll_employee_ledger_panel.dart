import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollEmployeeLedgerPanel extends StatelessWidget {
  final PayrollEmployeeLedgerSummary summary;

  const PayrollEmployeeLedgerPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Employee payroll ledger',
      subtitle: summary.employee?.name ?? summary.periodLabel,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisMetricStrip(
                items: [
                  HrisMetricStripItem(
                    label: 'Credits',
                    value: payrollCurrencyFormat.format(summary.credits),
                  ),
                  HrisMetricStripItem(
                    label: 'Debits',
                    value: payrollCurrencyFormat.format(summary.debits),
                  ),
                  HrisMetricStripItem(
                    label: 'Attention',
                    value: '${summary.attentionCount}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.attentionCount > 0
                        ? Icons.warning_amber_outlined
                        : Icons.verified_outlined,
                    color:
                        summary.attentionCount > 0
                            ? const Color(0xFFB45309)
                            : const Color(0xFF15803D),
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
        if (summary.entries.isEmpty)
          const HrisEmptyState(
            message: 'Select an employee to review payroll ledger activity',
          )
        else
          for (final entry in summary.entries.take(8))
            _LedgerEntryTile(entry: entry),
      ],
    );
  }
}

class _LedgerEntryTile extends StatelessWidget {
  final PayrollEmployeeLedgerEntry entry;

  const _LedgerEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(entry.status);

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
            child: Icon(_typeIcon(entry.type), color: color, size: 20),
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
                            entry.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${entry.type.label} - ${entry.sourceLabel}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: entry.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(entry.eventDate),
                    ),
                    _MetaChip(
                      icon:
                          entry.isDebit
                              ? Icons.south_east_outlined
                              : Icons.north_east_outlined,
                      label: payrollCurrencyFormat.format(entry.amount),
                    ),
                    _MetaChip(icon: Icons.notes_outlined, label: entry.detail),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

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

Color _statusColor(PayrollEmployeeLedgerStatus status) {
  return switch (status) {
    PayrollEmployeeLedgerStatus.pending => const Color(0xFFB45309),
    PayrollEmployeeLedgerStatus.blocked => const Color(0xFFB91C1C),
    PayrollEmployeeLedgerStatus.approved => const Color(0xFF2563EB),
    PayrollEmployeeLedgerStatus.applied => const Color(0xFF7C3AED),
    PayrollEmployeeLedgerStatus.released => const Color(0xFF15803D),
    PayrollEmployeeLedgerStatus.published => const Color(0xFF0F766E),
  };
}

IconData _typeIcon(PayrollEmployeeLedgerEntryType type) {
  return switch (type) {
    PayrollEmployeeLedgerEntryType.regularPayroll =>
      Icons.account_balance_wallet_outlined,
    PayrollEmployeeLedgerEntryType.inputChange => Icons.input_outlined,
    PayrollEmployeeLedgerEntryType.attendance => Icons.schedule_outlined,
    PayrollEmployeeLedgerEntryType.loanRepayment =>
      Icons.account_balance_outlined,
    PayrollEmployeeLedgerEntryType.deductionAuthorization =>
      Icons.fact_check_outlined,
    PayrollEmployeeLedgerEntryType.offCycle => Icons.flash_on_outlined,
    PayrollEmployeeLedgerEntryType.payment => Icons.payments_outlined,
    PayrollEmployeeLedgerEntryType.payslip => Icons.description_outlined,
  };
}
