import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_saved_view_manager_group.dart';

void main() {
  test('returns no groups for an empty manager list', () {
    expect(groupWorkQueueSavedViewManagerViews(views: const []), isEmpty);
  });

  test(
    'groups views by first-seen role and preserves order inside each role',
    () {
      final controllerBlockers = _savedView(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        label: 'Month-end blockers',
      );
      final taxReview = _savedView(
        rolePreset: AccountingWorkspaceRolePreset.tax,
        focus: AccountingWorkspaceWorkQueueFocus.review,
        label: 'SPT review',
      );
      final controllerApprover = _savedView(
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.monitor,
        label: 'Approver pulse',
      );

      final groups = groupWorkQueueSavedViewManagerViews(
        views: [controllerBlockers, taxReview, controllerApprover],
      );

      expect(groups.map((group) => group.rolePreset), [
        AccountingWorkspaceRolePreset.controller,
        AccountingWorkspaceRolePreset.tax,
      ]);
      expect(groups.first.views.map((view) => view.id), [
        controllerBlockers.id,
        controllerApprover.id,
      ]);
      expect(groups.last.views.single.id, taxReview.id);
    },
  );
}

AccountingWorkspaceWorkQueueSavedView _savedView({
  required AccountingWorkspaceRolePreset rolePreset,
  required AccountingWorkspaceWorkQueueFocus focus,
  required String label,
}) {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: rolePreset,
    focus: focus,
    sort: AccountingWorkspaceWorkQueueSort.workflow,
    ownerFilter: null,
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: null,
    selectedQueueTitle: null,
    detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
  ).copyWith(label: label);
}
