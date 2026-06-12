import 'accounting_menu_saved_view.dart';

enum AccountingWorkspaceRolePreset { accountant, controller, tax, auditor }

extension AccountingWorkspaceRolePresetLabel on AccountingWorkspaceRolePreset {
  String get label {
    switch (this) {
      case AccountingWorkspaceRolePreset.accountant:
        return 'Accountant';
      case AccountingWorkspaceRolePreset.controller:
        return 'Controller';
      case AccountingWorkspaceRolePreset.tax:
        return 'Tax';
      case AccountingWorkspaceRolePreset.auditor:
        return 'Auditor';
    }
  }

  String get shortLabel {
    switch (this) {
      case AccountingWorkspaceRolePreset.accountant:
        return 'Acct';
      case AccountingWorkspaceRolePreset.controller:
        return 'Control';
      case AccountingWorkspaceRolePreset.tax:
        return 'Tax';
      case AccountingWorkspaceRolePreset.auditor:
        return 'Audit';
    }
  }

  String get icon {
    switch (this) {
      case AccountingWorkspaceRolePreset.accountant:
        return 'menu_book';
      case AccountingWorkspaceRolePreset.controller:
        return 'verified_user';
      case AccountingWorkspaceRolePreset.tax:
        return 'account_balance';
      case AccountingWorkspaceRolePreset.auditor:
        return 'fact_check';
    }
  }

  String get storageValue {
    switch (this) {
      case AccountingWorkspaceRolePreset.accountant:
        return 'accountant';
      case AccountingWorkspaceRolePreset.controller:
        return 'controller';
      case AccountingWorkspaceRolePreset.tax:
        return 'tax';
      case AccountingWorkspaceRolePreset.auditor:
        return 'auditor';
    }
  }
}

AccountingWorkspaceRolePreset? accountingWorkspaceRolePresetFromStorage(
  Object? value,
) {
  final normalized = value is String ? value.trim().toLowerCase() : '';

  switch (normalized) {
    case 'accountant':
    case 'acct':
      return AccountingWorkspaceRolePreset.accountant;
    case 'controller':
    case 'control':
      return AccountingWorkspaceRolePreset.controller;
    case 'tax':
      return AccountingWorkspaceRolePreset.tax;
    case 'auditor':
    case 'audit':
      return AccountingWorkspaceRolePreset.auditor;
    default:
      return null;
  }
}

List<AccountingMenuSavedView> accountingMenuSavedViewsForRole(
  AccountingWorkspaceRolePreset preset, {
  List<AccountingMenuSavedView> views = accountingMenuSavedViews,
}) {
  final byId = {for (final view in views) view.id: view};

  return List<AccountingMenuSavedView>.unmodifiable([
    for (final id in _savedViewIdsForRole(preset))
      if (byId[id] case final view?) view,
  ]);
}

List<String> _savedViewIdsForRole(AccountingWorkspaceRolePreset preset) {
  switch (preset) {
    case AccountingWorkspaceRolePreset.accountant:
      return const [
        'ledger-review',
        'close-controls',
        'reconciliation',
        'spt-statutory',
        'payables',
        'receivables',
      ];
    case AccountingWorkspaceRolePreset.controller:
      return const [
        'close-controls',
        'reconciliation',
        'report-pack',
        'release-shortcuts',
        'evidence',
      ];
    case AccountingWorkspaceRolePreset.tax:
      return const [
        'spt-statutory',
        'report-pack',
        'release-shortcuts',
        'evidence',
      ];
    case AccountingWorkspaceRolePreset.auditor:
      return const [
        'evidence',
        'reconciliation',
        'release-shortcuts',
        'report-pack',
      ];
  }
}
