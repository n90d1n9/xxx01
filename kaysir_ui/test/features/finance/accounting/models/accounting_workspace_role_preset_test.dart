import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';

void main() {
  test('returns accountant saved views in workflow order', () {
    final views = accountingMenuSavedViewsForRole(
      AccountingWorkspaceRolePreset.accountant,
    );

    expect(views.map((view) => view.id), [
      'ledger-review',
      'close-controls',
      'reconciliation',
      'spt-statutory',
      'payables',
      'receivables',
    ]);
  });

  test('returns distinct statutory and audit role saved views', () {
    final taxViews = accountingMenuSavedViewsForRole(
      AccountingWorkspaceRolePreset.tax,
    );
    final auditorViews = accountingMenuSavedViewsForRole(
      AccountingWorkspaceRolePreset.auditor,
    );

    expect(taxViews.map((view) => view.id), contains('spt-statutory'));
    expect(
      auditorViews.map((view) => view.id),
      isNot(contains('spt-statutory')),
    );
    expect(auditorViews.map((view) => view.id), contains('evidence'));
  });

  test('parses role preset storage values', () {
    expect(
      accountingWorkspaceRolePresetFromStorage('controller'),
      AccountingWorkspaceRolePreset.controller,
    );
    expect(
      accountingWorkspaceRolePresetFromStorage('audit'),
      AccountingWorkspaceRolePreset.auditor,
    );
    expect(accountingWorkspaceRolePresetFromStorage('missing'), isNull);
  });
}
