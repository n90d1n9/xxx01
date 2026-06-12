import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_accounting_impact.dart';

class AccountingNavigationWorkQueueAccountingImpactPanel
    extends StatelessWidget {
  const AccountingNavigationWorkQueueAccountingImpactPanel({
    required this.impact,
    super.key,
  });

  final AccountingWorkspaceWorkQueueAccountingImpact impact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_rounded,
                  color: colorScheme.primary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Accounting impact',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _ImpactLine(
              icon: Icons.summarize_rounded,
              label: 'Statement area',
              value: impact.statementAreaLabel,
            ),
            const SizedBox(height: 7),
            _ImpactLine(
              icon: Icons.verified_rounded,
              label: 'Assertion',
              value: impact.assertionLabel,
            ),
            const SizedBox(height: 7),
            _ImpactLine(
              icon: Icons.receipt_long_rounded,
              label: 'Tax impact',
              value: impact.taxImpactLabel,
            ),
            const SizedBox(height: 7),
            _ImpactLine(
              icon: Icons.lock_clock_rounded,
              label: 'Close gate',
              value: impact.closeGateLabel,
            ),
            const SizedBox(height: 9),
            Text(
              'Journal preview',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            _ImpactLine(
              icon: Icons.edit_note_rounded,
              label: 'Journal action',
              value: impact.journalActionLabel,
            ),
            const SizedBox(height: 7),
            _ImpactLine(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Ledger focus',
              value: impact.ledgerFocusLabel,
            ),
            const SizedBox(height: 7),
            _ImpactLine(
              icon: Icons.rule_rounded,
              label: 'Posting gate',
              value: impact.postingGateLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactLine extends StatelessWidget {
  const _ImpactLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
