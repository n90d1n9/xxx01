import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widget_previews.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_path.dart';
import '../states/chart_of_accounts_provider.dart';
import '../widgets/chart_of_accounts_components.dart';

/// Chart-of-accounts setup workspace for posting and report mapping readiness.
class ChartOfAccountsScreen extends ConsumerStatefulWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  ConsumerState<ChartOfAccountsScreen> createState() =>
      _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends ConsumerState<ChartOfAccountsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(chartOfAccountsProvider);
    final validation = ref.watch(chartOfAccountsValidationProvider);
    final filteredAccounts = _filteredAccounts(accounts);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Chart of Accounts'),
        actions: [
          IconButton(
            tooltip: 'Trial balance',
            onPressed: () => context.go(AccountingPath.trialBalance),
            icon: const Icon(Icons.balance_rounded),
          ),
          IconButton(
            tooltip: 'General ledger',
            onPressed: () => context.go(AccountingPath.gl),
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'CoA setup',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Maintain posting accounts, report mapping, cash-flow category, '
            'and tax tags used by ledger and financial reports.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ChartOfAccountsSummaryStrip(
            accounts: accounts,
            validation: validation,
          ),
          const SizedBox(height: 14),
          ChartOfAccountsToolbar(
            controller: _searchController,
            onQueryChanged: _updateQuery,
            onAddAccount: () => _showAddAccountDialog(accounts),
          ),
          const SizedBox(height: 14),
          ChartOfAccountsValidationPanel(validation: validation),
          const SizedBox(height: 14),
          if (filteredAccounts.isEmpty)
            _ChartOfAccountsEmptyState(query: _query)
          else
            for (final type in AccountingAccountType.values)
              ChartOfAccountsTypeSection(
                type: type,
                accounts: filteredAccounts
                    .where((account) => account.type == type)
                    .toList(growable: false),
                onToggleActive: _toggleActive,
              ),
        ],
      ),
    );
  }

  void _updateQuery(String value) {
    setState(() => _query = value.trim());
  }

  List<AccountingAccount> _filteredAccounts(List<AccountingAccount> accounts) {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
    if (terms.isEmpty) return accounts;

    return [
      for (final account in accounts)
        if (_matches(account, terms)) account,
    ];
  }

  bool _matches(AccountingAccount account, List<String> terms) {
    final value =
        [
          account.code,
          account.name,
          account.type.label,
          account.normalBalance.label,
          account.effectiveReportSection.label,
          account.cashFlowCategory.label,
          account.taxTag,
          account.currencyCode,
        ].whereType<String>().join(' ').toLowerCase();

    return terms.every(value.contains);
  }

  void _toggleActive(AccountingAccount account) {
    final notifier = ref.read(chartOfAccountsProvider.notifier);
    if (account.isActive) {
      notifier.deactivateAccount(account.id);
    } else {
      notifier.activateAccount(account.id);
    }
  }

  Future<void> _showAddAccountDialog(List<AccountingAccount> accounts) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return ChartOfAccountsAccountDialog(
          existingAccounts: accounts,
          onSubmit: ref.read(chartOfAccountsProvider.notifier).addAccount,
        );
      },
    );
  }
}

class _ChartOfAccountsEmptyState extends StatelessWidget {
  const _ChartOfAccountsEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          query.isEmpty
              ? 'No accounts configured.'
              : 'No accounts match "$query".',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

@Preview(name: 'Chart of accounts screen')
Widget chartOfAccountsScreenPreview() {
  return const ProviderScope(child: MaterialApp(home: ChartOfAccountsScreen()));
}
