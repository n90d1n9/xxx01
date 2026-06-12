import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';

void main() {
  test('returns role-specific accounting work queue saved views', () {
    final controllerViews = accountingWorkspaceWorkQueueSavedViewsForRole(
      AccountingWorkspaceRolePreset.controller,
    );
    final taxViews = accountingWorkspaceWorkQueueSavedViewsForRole(
      AccountingWorkspaceRolePreset.tax,
    );

    expect(controllerViews.map((view) => view.id), [
      'controller-close-blockers',
      'controller-report-approver',
      'controller-posting-review',
    ]);
    expect(
      taxViews.map((view) => view.id),
      isNot(contains('controller-report-approver')),
    );
    expect(taxViews.map((view) => view.id), contains('tax-statutory-blockers'));
  });

  test('matches selected work queue saved view with normalized owner', () {
    const view = AccountingWorkspaceWorkQueueSavedView(
      id: 'controller-report-approver',
      label: 'Report approver',
      description: 'Release approval queue for report sign-off.',
      icon: 'verified_user',
      rolePreset: AccountingWorkspaceRolePreset.controller,
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Report approver',
      selectedQueueId: 'controller-release-approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    );

    expect(
      view.isSelected(
        query: '',
        scope: AccountingMenuSearchScope.all,
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        ownerFilter: ' report approver ',
        resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
        selectedQueueId: 'controller-release-approvals',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
      isTrue,
    );
    expect(
      view.isSelected(
        query: '',
        scope: AccountingMenuSearchScope.all,
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        ownerFilter: 'Report approver',
        resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
        selectedQueueId: 'controller-release-approvals',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.activity,
      ),
      isFalse,
    );
  });

  test('allows broad saved views without a selected queue target', () {
    const view = AccountingWorkspaceWorkQueueSavedView(
      id: 'controller-posting-review',
      label: 'Posting review',
      description: 'Largest posting gates before period lock.',
      icon: 'playlist_add_check',
      rolePreset: AccountingWorkspaceRolePreset.controller,
      sort: AccountingWorkspaceWorkQueueSort.largest,
    );

    expect(
      view.isSelected(
        query: '',
        scope: AccountingMenuSearchScope.all,
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.all,
        sort: AccountingWorkspaceWorkQueueSort.largest,
        ownerFilter: null,
        resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
        selectedQueueId: 'any-selected-queue',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.activity,
      ),
      isTrue,
    );
  });

  test('creates and restores custom accounting work queue saved views', () {
    final view = AccountingWorkspaceWorkQueueSavedView.custom(
      query: 'spt',
      scope: AccountingMenuSearchScope.shortcuts,
      rolePreset: AccountingWorkspaceRolePreset.tax,
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Tax reviewer',
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
      selectedQueueId: 'tax-statutory-filing-gaps',
      selectedQueueTitle: 'SPT filing gaps',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    );

    final restored = accountingWorkspaceWorkQueueSavedViewFromJson(
      view.toJson(),
    );

    expect(view.isCustom, isTrue);
    expect(
      view.id,
      'custom-tax-shortcuts-spt-blocked-urgent-tax-reviewer-ready-'
      'tax-statutory-filing-gaps-controls',
    );
    expect(view.label, 'SPT filing gaps / Ready');
    expect(restored?.id, view.id);
    expect(restored?.query, 'spt');
    expect(restored?.scope, AccountingMenuSearchScope.shortcuts);
    expect(restored?.rolePreset, AccountingWorkspaceRolePreset.tax);
    expect(restored?.selectedQueueId, 'tax-statutory-filing-gaps');
    expect(
      restored?.detailSection,
      AccountingWorkspaceWorkQueueDetailSection.controls,
    );
  });

  test('renames custom saved views without changing queue state', () {
    final view = AccountingWorkspaceWorkQueueSavedView.custom(
      query: '',
      scope: AccountingMenuSearchScope.all,
      rolePreset: AccountingWorkspaceRolePreset.controller,
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      sort: AccountingWorkspaceWorkQueueSort.workflow,
      ownerFilter: null,
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
      selectedQueueId: null,
      selectedQueueTitle: null,
      detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
    );

    final renamedView = view.copyWith(label: 'Month-end blockers');

    expect(renamedView.id, view.id);
    expect(renamedView.label, 'Month-end blockers');
    expect(renamedView.focus, view.focus);
    expect(renamedView.sort, view.sort);
    expect(renamedView.isCustom, isTrue);
  });
}
