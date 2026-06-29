import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_funding_authorization_form.dart';
import 'payroll_formatters.dart';

class PayrollFundingAuthorizationPanel extends StatelessWidget {
  final PayrollFundingAuthorizationSummary summary;
  final PayrollFundingAuthorizationDraft draft;
  final ValueChanged<String> onSelectAccount;
  final ValueChanged<String> onAuthorizedByChanged;
  final ValueChanged<String> onReferenceCodeChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmitAuthorization;
  final VoidCallback onCancelAuthorization;
  final ValueChanged<String> onReopenAccount;

  const PayrollFundingAuthorizationPanel({
    super.key,
    required this.summary,
    required this.draft,
    required this.onSelectAccount,
    required this.onAuthorizedByChanged,
    required this.onReferenceCodeChanged,
    required this.onNotesChanged,
    required this.onSubmitAuthorization,
    required this.onCancelAuthorization,
    required this.onReopenAccount,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Funding authorization',
      subtitle: summary.periodLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Accounts',
              value: '${summary.lines.length}',
            ),
            HrisMetricStripItem(
              label: 'Authorized',
              value: '${summary.authorizedCount}',
            ),
            HrisMetricStripItem(
              label: 'Pending net',
              value: payrollCurrencyFormat.format(summary.pendingNet),
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                summary.isAuthorizedForRelease
                    ? Icons.verified_outlined
                    : Icons.lock_clock_outlined,
                color:
                    summary.isAuthorizedForRelease
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                size: 20,
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
        ),
        PayrollFundingAuthorizationForm(
          draft: draft,
          onAuthorizedByChanged: onAuthorizedByChanged,
          onReferenceCodeChanged: onReferenceCodeChanged,
          onNotesChanged: onNotesChanged,
          onSubmit: onSubmitAuthorization,
          onCancel: onCancelAuthorization,
        ),
        for (final line in summary.lines)
          _FundingAuthorizationLineTile(
            line: line,
            onSelectAccount: onSelectAccount,
            onReopenAccount: onReopenAccount,
          ),
      ],
    );
  }
}

class _FundingAuthorizationLineTile extends StatelessWidget {
  final PayrollFundingAuthorizationLine line;
  final ValueChanged<String> onSelectAccount;
  final ValueChanged<String> onReopenAccount;

  const _FundingAuthorizationLineTile({
    required this.line,
    required this.onSelectAccount,
    required this.onReopenAccount,
  });

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
            child: Icon(Icons.account_balance_wallet_outlined, color: color),
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
                            line.accountLabel,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${line.recipientCount} scheduled recipients',
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.pendingNet),
                    ),
                    _MetricChip(
                      icon:
                          line.hasBlockers
                              ? Icons.report_problem_outlined
                              : line.isAuthorized
                              ? Icons.assignment_turned_in_outlined
                              : Icons.verified_outlined,
                      label:
                          line.hasBlockers
                              ? line.blockers.first
                              : line.isAuthorized
                              ? line.authorization!.referenceCode
                              : 'Authorization packet ready',
                    ),
                    if (line.isAuthorized)
                      _MetricChip(
                        icon: Icons.how_to_reg_outlined,
                        label: line.authorization!.authorizedBy,
                      ),
                  ],
                ),
                if (line.canAuthorize || line.isAuthorized) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        line.isAuthorized
                            ? OutlinedButton.icon(
                              onPressed:
                                  () => onReopenAccount(line.accountLabel),
                              icon: const Icon(Icons.undo_outlined, size: 18),
                              label: const Text('Reopen authorization'),
                            )
                            : OutlinedButton.icon(
                              onPressed:
                                  () => onSelectAccount(line.accountLabel),
                              icon: const Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                              ),
                              label: const Text('Prepare authorization'),
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

Color _statusColor(PayrollFundingAuthorizationStatus status) {
  return switch (status) {
    PayrollFundingAuthorizationStatus.blocked => const Color(0xFFB91C1C),
    PayrollFundingAuthorizationStatus.ready => const Color(0xFF2563EB),
    PayrollFundingAuthorizationStatus.authorized => const Color(0xFF15803D),
  };
}
