import 'accounting_workspace_role_preset.dart';
import 'work_queue_saved_view.dart';

/// Role-scoped group of saved views shown together in the manager dialog.
class WorkQueueSavedViewManagerRoleGroup {
  WorkQueueSavedViewManagerRoleGroup({
    required this.rolePreset,
    required Iterable<AccountingWorkspaceWorkQueueSavedView> views,
  }) : views = List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(views);

  final AccountingWorkspaceRolePreset rolePreset;
  final List<AccountingWorkspaceWorkQueueSavedView> views;

  int get viewCount => views.length;
}

/// Groups saved-view manager rows by role while preserving first-seen role order.
List<WorkQueueSavedViewManagerRoleGroup> groupWorkQueueSavedViewManagerViews({
  required Iterable<AccountingWorkspaceWorkQueueSavedView> views,
}) {
  final roleOrder = <AccountingWorkspaceRolePreset>[];
  final viewsByRole =
      <
        AccountingWorkspaceRolePreset,
        List<AccountingWorkspaceWorkQueueSavedView>
      >{};

  for (final view in views) {
    viewsByRole
        .putIfAbsent(view.rolePreset, () {
          roleOrder.add(view.rolePreset);
          return <AccountingWorkspaceWorkQueueSavedView>[];
        })
        .add(view);
  }

  return List<WorkQueueSavedViewManagerRoleGroup>.unmodifiable([
    for (final rolePreset in roleOrder)
      WorkQueueSavedViewManagerRoleGroup(
        rolePreset: rolePreset,
        views: viewsByRole[rolePreset] ?? const [],
      ),
  ]);
}
