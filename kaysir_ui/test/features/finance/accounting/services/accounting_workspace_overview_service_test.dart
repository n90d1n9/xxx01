import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_next_action_service.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_overview_service.dart';

void main() {
  test('summarizes accounting workspace coverage for the current context', () {
    const overviewService = AccountingWorkspaceOverviewService();
    const nextActionService = AccountingWorkspaceNextActionService();
    final sections = filterAccountingMenuSections(
      'evidence',
      scope: AccountingMenuSearchScope.shortcuts,
    );
    final savedViews = accountingMenuSavedViewsForRole(
      AccountingWorkspaceRolePreset.auditor,
    );
    final actions = nextActionService.actionsFor(
      rolePreset: AccountingWorkspaceRolePreset.auditor,
      query: 'evidence',
      scope: AccountingMenuSearchScope.shortcuts,
    );

    final overview = overviewService.summarize(
      sections: sections,
      savedViews: savedViews,
      priorityActions: actions,
    );

    expect(overview.sectionCount, 1);
    expect(overview.screenCount, 0);
    expect(overview.shortcutCount, 1);
    expect(overview.savedViewCount, 4);
    expect(overview.priorityActionCount, 1);
  });
}
