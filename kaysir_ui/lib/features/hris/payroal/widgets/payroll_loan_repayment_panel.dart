import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollLoanRepaymentPanel extends StatelessWidget {
  final PayrollLoanRepaymentSummary summary;
  final VoidCallback onApplyReady;
  final VoidCallback onReopen;

  const PayrollLoanRepaymentPanel({
    super.key,
    required this.summary,
    required this.onApplyReady,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Loan repayment center',
      subtitle:
          summary.selectedEmployeeId == null
              ? '${summary.lines.length} loan accounts'
              : '${summary.visibleLines.length} selected employee loans',
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
                        _MetaChip(
                          icon: Icons.account_balance_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.outstandingBalance,
                          ),
                        ),
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.scheduledRepayment,
                          ),
                        ),
                        _MetaChip(
                          icon: Icons.pause_circle_outline,
                          label: '${summary.pausedCount} paused',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: summary.appliedCount > 0 ? onReopen : null,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reopen'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: summary.canApply ? onApplyReady : null,
                        icon: const Icon(Icons.playlist_add_check_outlined),
                        label: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: summary.readinessRate,
                color: statusColor,
                label:
                    '${(summary.readinessRate * 100).round()}% repayment ready',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_statusIcon(summary.status), color: statusColor),
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
        if (summary.visibleLines.isEmpty)
          const HrisEmptyState(
            message: 'No loan repayments for the selected employee',
          )
        else
          for (final line in summary.visibleLines)
            _LoanRepaymentLineTile(line: line),
      ],
    );
  }
}

class _LoanRepaymentLineTile extends StatelessWidget {
  final PayrollLoanRepaymentLine line;

  const _LoanRepaymentLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(line.status);

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
            child: Icon(_statusIcon(line.status), color: color, size: 20),
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
                            line.account.type.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${line.employeeName} - ${line.position}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.account_balance_outlined,
                      label: payrollCurrencyFormat.format(
                        line.account.outstandingBalance,
                      ),
                    ),
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.repaymentAmount),
                    ),
                    _MetaChip(
                      icon: Icons.speed_outlined,
                      label:
                          line.isCapped
                              ? 'Capped at ${payrollCurrencyFormat.format(line.capAmount)}'
                              : '${line.account.remainingInstallments} installments',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.nextAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        line.hasBlockers
                            ? const Color(0xFFB91C1C)
                            : HrisColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
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

Color _statusColor(PayrollLoanRepaymentStatus status) {
  return switch (status) {
    PayrollLoanRepaymentStatus.blocked => const Color(0xFFB91C1C),
    PayrollLoanRepaymentStatus.ready => const Color(0xFF2563EB),
    PayrollLoanRepaymentStatus.applied => const Color(0xFF15803D),
    PayrollLoanRepaymentStatus.paused => const Color(0xFF64748B),
  };
}

IconData _statusIcon(PayrollLoanRepaymentStatus status) {
  return switch (status) {
    PayrollLoanRepaymentStatus.blocked => Icons.warning_amber_outlined,
    PayrollLoanRepaymentStatus.ready => Icons.playlist_add_check_outlined,
    PayrollLoanRepaymentStatus.applied => Icons.verified_outlined,
    PayrollLoanRepaymentStatus.paused => Icons.pause_circle_outline,
  };
}
