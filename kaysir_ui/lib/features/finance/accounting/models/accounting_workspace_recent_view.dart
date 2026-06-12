import '../accounting_path.dart';
import 'accounting_menu_saved_view.dart';
import 'accounting_menu_search.dart';

class AccountingWorkspaceRecentView {
  const AccountingWorkspaceRecentView({
    required this.id,
    required this.label,
    required this.query,
    required this.scope,
    required this.icon,
  });

  factory AccountingWorkspaceRecentView.fromSavedView(
    AccountingMenuSavedView view,
  ) {
    return AccountingWorkspaceRecentView(
      id: accountingWorkspaceRecentViewId(query: view.query, scope: view.scope),
      label: view.label,
      query: view.query.trim(),
      scope: view.scope,
      icon: view.icon,
    );
  }

  factory AccountingWorkspaceRecentView.fromSearch({
    required String query,
    required AccountingMenuSearchScope scope,
  }) {
    final normalizedQuery = query.trim();

    return AccountingWorkspaceRecentView(
      id: accountingWorkspaceRecentViewId(query: normalizedQuery, scope: scope),
      label:
          normalizedQuery.isEmpty
              ? '${scope.label} view'
              : '$normalizedQuery - ${scope.label}',
      query: normalizedQuery,
      scope: scope,
      icon: _iconForScope(scope),
    );
  }

  factory AccountingWorkspaceRecentView.fromJson(Map<String, Object?> json) {
    final query = _stringValue(json['query']).trim();
    final scope = accountingMenuSearchScopeFromQuery(
      _stringValue(json['scope']),
    );
    final label = _stringValue(json['label']).trim();
    final icon = _stringValue(json['icon']).trim();

    return AccountingWorkspaceRecentView(
      id: accountingWorkspaceRecentViewId(query: query, scope: scope),
      label: label.isEmpty ? _labelForSearch(query, scope) : label,
      query: query,
      scope: scope,
      icon: icon.isEmpty ? _iconForScope(scope) : icon,
    );
  }

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

  bool get isDefault {
    return query.trim().isEmpty && scope == AccountingMenuSearchScope.all;
  }

  bool isSelected({
    required String query,
    required AccountingMenuSearchScope scope,
  }) {
    return this.query.trim().toLowerCase() == query.trim().toLowerCase() &&
        this.scope == scope;
  }

  Map<String, Object?> toJson() {
    return {
      'label': label,
      'query': query,
      'scope': scope.queryValue,
      'icon': icon,
    };
  }
}

String accountingWorkspaceRecentViewId({
  required String query,
  required AccountingMenuSearchScope scope,
}) {
  return '${scope.queryValue}:${query.trim().toLowerCase()}';
}

String _iconForScope(AccountingMenuSearchScope scope) {
  switch (scope) {
    case AccountingMenuSearchScope.all:
      return 'account_tree';
    case AccountingMenuSearchScope.screens:
      return 'list';
    case AccountingMenuSearchScope.shortcuts:
      return 'verified_user';
  }
}

String _labelForSearch(String query, AccountingMenuSearchScope scope) {
  final normalizedQuery = query.trim();
  return normalizedQuery.isEmpty
      ? '${scope.label} view'
      : '$normalizedQuery - ${scope.label}';
}

String _stringValue(Object? value) {
  return value is String ? value : '';
}
