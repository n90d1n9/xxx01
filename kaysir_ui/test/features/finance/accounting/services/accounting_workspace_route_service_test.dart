import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_route_service.dart';

void main() {
  test('parses work queue detail section route values', () {
    expect(
      accountingWorkspaceWorkQueueDetailSectionFromQuery('activity'),
      AccountingWorkspaceWorkQueueDetailSection.activity,
    );
    expect(
      accountingWorkspaceWorkQueueDetailSectionFromQuery('audit'),
      AccountingWorkspaceWorkQueueDetailSection.activity,
    );
    expect(
      accountingWorkspaceWorkQueueDetailSectionFromQuery('timeline'),
      AccountingWorkspaceWorkQueueDetailSection.activity,
    );
    expect(
      accountingWorkspaceWorkQueueDetailSectionFromQuery('unknown'),
      AccountingWorkspaceWorkQueueDetailSection.overview,
    );
  });

  test('builds shareable accounting workspace paths from workspace state', () {
    const service = AccountingWorkspaceRouteService();

    expect(
      service.buildPath(
        query: ' ledger ',
        scope: AccountingMenuSearchScope.screens,
        rolePreset: AccountingWorkspaceRolePreset.controller,
        workQueueFocus: AccountingWorkspaceWorkQueueFocus.blocked,
        workQueueSort: AccountingWorkspaceWorkQueueSort.urgent,
        workQueueOwnerFilter: 'Controller',
        selectedWorkQueueId: 'controller-close-blockers',
        selectedWorkQueueDetailSection:
            AccountingWorkspaceWorkQueueDetailSection.request,
      ),
      AccountingPath.workspaceWithSearch(
        query: 'ledger',
        scope: AccountingMenuSearchScope.screens.queryValue,
        role: AccountingWorkspaceRolePreset.controller.storageValue,
        queue: AccountingWorkspaceWorkQueueFocus.blocked.queryValue,
        sort: AccountingWorkspaceWorkQueueSort.urgent.queryValue,
        owner: 'Controller',
        work: 'controller-close-blockers',
        detail: 'request',
      ),
    );
    expect(
      service.buildPath(rolePreset: AccountingWorkspaceRolePreset.auditor),
      AccountingPath.workspaceAuditor,
    );
  });
}
