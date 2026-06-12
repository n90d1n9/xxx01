import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../accounting_path.dart';
import '../widgets/bank_reconciliation_card.dart';
import '../widgets/payable_reconciliation_card.dart';
import '../widgets/receivable_reconciliation_card.dart';

enum AccountingReconciliationFocus { bank, payable, receivable }

class ReconciliationCenterScreen extends StatelessWidget {
  const ReconciliationCenterScreen({required this.focus, super.key});

  final AccountingReconciliationFocus focus;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(focus);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(config.title),
        actions: [
          IconButton(
            tooltip: 'General ledger',
            onPressed: () => context.go(AccountingPath.gl),
            icon: const Icon(Icons.menu_book_rounded),
          ),
          IconButton(
            tooltip: 'Period close',
            onPressed: () => context.go(AccountingPath.periodClose),
            icon: const Icon(Icons.lock_clock_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _ReconciliationHeader(config: config),
          const SizedBox(height: 14),
          config.body,
        ],
      ),
    );
  }

  _ReconciliationConfig _configFor(AccountingReconciliationFocus focus) {
    switch (focus) {
      case AccountingReconciliationFocus.bank:
        return const _ReconciliationConfig(
          title: 'Bank Reconciliation',
          subtitle: 'Cash and bank evidence',
          description:
              'Bank statement matching, timing differences, and suggested journal evidence.',
          icon: Icons.account_balance_rounded,
          body: BankReconciliationCard(),
        );
      case AccountingReconciliationFocus.payable:
        return const _ReconciliationConfig(
          title: 'Payable Reconciliation',
          subtitle: 'AP subledger evidence',
          description:
              'Vendor bill subledger tie-out against accounts payable control balances.',
          icon: Icons.fact_check_rounded,
          body: PayableReconciliationCard(),
        );
      case AccountingReconciliationFocus.receivable:
        return const _ReconciliationConfig(
          title: 'Receivable Reconciliation',
          subtitle: 'AR subledger evidence',
          description:
              'Customer invoice subledger tie-out against accounts receivable control balances.',
          icon: Icons.receipt_long_rounded,
          body: ReceivableReconciliationCard(),
        );
    }
  }
}

class _ReconciliationHeader extends StatelessWidget {
  const _ReconciliationHeader({required this.config});

  final _ReconciliationConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(config.icon, color: colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.subtitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconciliationConfig {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Widget body;

  const _ReconciliationConfig({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.body,
  });
}
