import 'work_queue_saved_view.dart';

/// Draft rename for a custom saved view that has not been committed yet.
class WorkQueueSavedViewManagerPendingRename {
  const WorkQueueSavedViewManagerPendingRename({
    required this.view,
    required this.nextLabel,
  });

  final AccountingWorkspaceWorkQueueSavedView view;
  final String nextLabel;
}

/// Returns draft saved-view renames whose labels differ from committed state.
List<WorkQueueSavedViewManagerPendingRename>
workQueueSavedViewManagerPendingRenames({
  required Iterable<AccountingWorkspaceWorkQueueSavedView> views,
  required Map<String, String> draftLabels,
}) {
  return List<WorkQueueSavedViewManagerPendingRename>.unmodifiable([
    for (final view in views)
      if (_pendingRenameFor(view: view, draftLabels: draftLabels)
          case final pendingRename?)
        pendingRename,
  ]);
}

WorkQueueSavedViewManagerPendingRename? _pendingRenameFor({
  required AccountingWorkspaceWorkQueueSavedView view,
  required Map<String, String> draftLabels,
}) {
  final draftLabel = draftLabels[view.id];
  if (draftLabel == null) return null;

  final nextLabel = draftLabel.trim();
  if (nextLabel == view.label) return null;

  return WorkQueueSavedViewManagerPendingRename(
    view: view,
    nextLabel: nextLabel,
  );
}
