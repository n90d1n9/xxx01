import '../accounting_path.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_sort.dart';

class AccountingWorkspaceRouteService {
  const AccountingWorkspaceRouteService();

  String buildPath({
    String query = '',
    AccountingMenuSearchScope scope = AccountingMenuSearchScope.all,
    AccountingWorkspaceRolePreset rolePreset =
        AccountingWorkspaceRolePreset.accountant,
    AccountingWorkspaceWorkQueueFocus workQueueFocus =
        AccountingWorkspaceWorkQueueFocus.all,
    AccountingWorkspaceWorkQueueSort workQueueSort =
        AccountingWorkspaceWorkQueueSort.workflow,
    String? workQueueOwnerFilter,
    String? selectedWorkQueueId,
    AccountingWorkspaceWorkQueueDetailSection selectedWorkQueueDetailSection =
        AccountingWorkspaceWorkQueueDetailSection.overview,
  }) {
    final hasSelectedWorkQueue =
        selectedWorkQueueId != null && selectedWorkQueueId.trim().isNotEmpty;

    return AccountingPath.workspaceWithSearch(
      query: query,
      scope: scope == AccountingMenuSearchScope.all ? null : scope.queryValue,
      role: rolePreset.storageValue,
      queue:
          workQueueFocus == AccountingWorkspaceWorkQueueFocus.all
              ? null
              : workQueueFocus.queryValue,
      sort:
          workQueueSort == AccountingWorkspaceWorkQueueSort.workflow
              ? null
              : workQueueSort.queryValue,
      owner: workQueueOwnerFilter,
      work: selectedWorkQueueId,
      detail:
          hasSelectedWorkQueue &&
                  selectedWorkQueueDetailSection !=
                      AccountingWorkspaceWorkQueueDetailSection.overview
              ? selectedWorkQueueDetailSection.queryValue
              : null,
    );
  }
}
