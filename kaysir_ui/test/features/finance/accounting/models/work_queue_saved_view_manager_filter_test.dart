import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_filter.dart';

void main() {
  test('returns every view for a blank query', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );

    final filteredViews = filterWorkQueueSavedViewManagerViews(
      views: [blockersView, approverView],
      query: '   ',
    );

    expect(filteredViews.map((view) => view.id), [
      blockersView.id,
      approverView.id,
    ]);
  });

  test('matches saved views by label, role, and focus terms', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );

    final filteredViews = filterWorkQueueSavedViewManagerViews(
      views: [blockersView, approverView],
      query: 'controller blocked',
    );

    expect(filteredViews.map((view) => view.id), [blockersView.id]);
  });

  test('matches saved views by owner, queue id, and detail section', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
      ownerFilter: 'Report approver',
      selectedQueueId: 'controller-release-approvals',
      selectedQueueTitle: 'Release approvals',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
    );

    final filteredViews = filterWorkQueueSavedViewManagerViews(
      views: [blockersView, approverView],
      query: 'approver controls release',
    );

    expect(filteredViews.map((view) => view.id), [approverView.id]);
  });

  test('returns no rows when every search term is missing', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );

    final filteredViews = filterWorkQueueSavedViewManagerViews(
      views: [blockersView],
      query: 'tax cleared',
    );

    expect(filteredViews, isEmpty);
  });
}

AccountingWorkspaceWorkQueueSavedView _savedView({
  required AccountingWorkspaceWorkQueueFocus focus,
  required String label,
  String? ownerFilter,
  String? selectedQueueId,
  String? selectedQueueTitle,
  AccountingWorkspaceWorkQueueDetailSection detailSection =
      AccountingWorkspaceWorkQueueDetailSection.overview,
}) {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: focus,
    sort: AccountingWorkspaceWorkQueueSort.workflow,
    ownerFilter: ownerFilter,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: selectedQueueId,
    selectedQueueTitle: selectedQueueTitle,
    detailSection: detailSection,
  ).copyWith(label: label);
}
