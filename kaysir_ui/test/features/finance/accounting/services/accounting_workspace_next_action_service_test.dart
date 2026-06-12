import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_next_action_service.dart';

void main() {
  test('returns controller priority actions in operating order', () {
    const service = AccountingWorkspaceNextActionService();
    final actions = service.actionsFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    expect(actions.map((action) => action.path), [
      AccountingPath.periodClose,
      AccountingPath.reportPack,
      AccountingPath.reportRelease,
      AccountingPath.bankReconciliation,
    ]);
  });

  test('filters role priority actions by shortcut scope and query', () {
    const service = AccountingWorkspaceNextActionService();
    final actions = service.actionsFor(
      rolePreset: AccountingWorkspaceRolePreset.auditor,
      query: 'evidence',
      scope: AccountingMenuSearchScope.shortcuts,
    );

    expect(actions, hasLength(1));
    expect(actions.single.id, 'auditor-release-evidence');
    expect(actions.single.path, AccountingPath.reportReleaseEvidence);
    expect(actions.single.registerRoute, isFalse);
  });
}
