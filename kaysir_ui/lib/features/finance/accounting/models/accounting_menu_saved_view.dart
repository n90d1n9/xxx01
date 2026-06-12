import '../accounting_path.dart';
import 'accounting_menu_search.dart';

class AccountingMenuSavedView {
  const AccountingMenuSavedView({
    required this.id,
    required this.label,
    required this.query,
    required this.scope,
    required this.icon,
  });

  final String id;
  final String label;
  final String query;
  final AccountingMenuSearchScope scope;
  final String icon;

  String get path {
    return AccountingPath.workspaceWithSearch(
      query: query,
      scope: scope == AccountingMenuSearchScope.all ? null : scope.queryValue,
    );
  }

  bool isSelected({
    required String query,
    required AccountingMenuSearchScope scope,
  }) {
    return this.query.trim().toLowerCase() == query.trim().toLowerCase() &&
        this.scope == scope;
  }
}

const accountingMenuSavedViews = <AccountingMenuSavedView>[
  AccountingMenuSavedView(
    id: 'ledger-review',
    label: 'Ledger review',
    query: 'ledger',
    scope: AccountingMenuSearchScope.screens,
    icon: 'menu_book',
  ),
  AccountingMenuSavedView(
    id: 'release-shortcuts',
    label: 'Release shortcuts',
    query: '',
    scope: AccountingMenuSearchScope.shortcuts,
    icon: 'verified_user',
  ),
  AccountingMenuSavedView(
    id: 'spt-statutory',
    label: 'SPT / statutory',
    query: 'spt',
    scope: AccountingMenuSearchScope.shortcuts,
    icon: 'account_balance',
  ),
  AccountingMenuSavedView(
    id: 'reconciliation',
    label: 'Reconciliation',
    query: 'reconciliation',
    scope: AccountingMenuSearchScope.screens,
    icon: 'sync_alt',
  ),
  AccountingMenuSavedView(
    id: 'close-controls',
    label: 'Close controls',
    query: 'period close',
    scope: AccountingMenuSearchScope.screens,
    icon: 'lock_clock',
  ),
  AccountingMenuSavedView(
    id: 'report-pack',
    label: 'Report pack',
    query: 'report pack',
    scope: AccountingMenuSearchScope.screens,
    icon: 'inventory',
  ),
  AccountingMenuSavedView(
    id: 'evidence',
    label: 'Evidence',
    query: 'evidence',
    scope: AccountingMenuSearchScope.all,
    icon: 'fact_check',
  ),
  AccountingMenuSavedView(
    id: 'payables',
    label: 'Payables',
    query: 'payable',
    scope: AccountingMenuSearchScope.screens,
    icon: 'payments',
  ),
  AccountingMenuSavedView(
    id: 'receivables',
    label: 'Receivables',
    query: 'receivable',
    scope: AccountingMenuSearchScope.screens,
    icon: 'request_quote',
  ),
];
