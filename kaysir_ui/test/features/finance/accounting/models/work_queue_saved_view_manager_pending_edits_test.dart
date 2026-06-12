import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_pending_edits.dart';

void main() {
  test('returns only draft labels that differ from committed view labels', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );
    final approverView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.review,
      label: 'Approver pulse',
    );

    final pendingRenames = workQueueSavedViewManagerPendingRenames(
      views: [blockersView, approverView],
      draftLabels: {
        blockersView.id: '  Month-end blockers  ',
        approverView.id: 'Reviewer pulse',
        'deleted-view': 'Ignored label',
      },
    );

    expect(pendingRenames.map((rename) => rename.view.id), [approverView.id]);
    expect(pendingRenames.single.nextLabel, 'Reviewer pulse');
  });

  test('keeps blank draft labels pending so validation can surface inline', () {
    final blockersView = _savedView(
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      label: 'Month-end blockers',
    );

    final pendingRenames = workQueueSavedViewManagerPendingRenames(
      views: [blockersView],
      draftLabels: {blockersView.id: '   '},
    );

    expect(pendingRenames.single.view.id, blockersView.id);
    expect(pendingRenames.single.nextLabel, isEmpty);
  });
}

AccountingWorkspaceWorkQueueSavedView _savedView({
  required AccountingWorkspaceWorkQueueFocus focus,
  required String label,
}) {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: focus,
    sort: AccountingWorkspaceWorkQueueSort.workflow,
    ownerFilter: null,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: null,
    selectedQueueTitle: null,
    detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
  ).copyWith(label: label);
}
