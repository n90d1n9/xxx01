import 'order_filter.dart';
import 'order_saved_workspace_model.dart';
import 'order_saved_workspace_shortcuts.dart';
import 'order_sort.dart';

class OrderSavedWorkspaceActiveResolution {
  final OrderSavedWorkspace? matchingWorkspace;
  final OrderSavedWorkspace? trackedWorkspace;
  final OrderSavedWorkspace? activeWorkspace;

  const OrderSavedWorkspaceActiveResolution({
    required this.matchingWorkspace,
    required this.trackedWorkspace,
    required this.activeWorkspace,
  });

  String? get activeWorkspaceId => activeWorkspace?.id;

  bool matchesTrackedWorkspace({
    required OrderFilter filter,
    required OrderSortMode sortMode,
  }) {
    return trackedWorkspace?.matches(filter, sortMode) ?? false;
  }
}

OrderSavedWorkspaceActiveResolution
ecommerceOrderSavedWorkspaceActiveResolution({
  required List<OrderSavedWorkspace> workspaces,
  required String? trackedWorkspaceId,
  required OrderFilter filter,
  required OrderSortMode sortMode,
}) {
  final trackedWorkspace =
      trackedWorkspaceId == null
          ? null
          : ecommerceOrderSavedWorkspaceById(
            workspaces: workspaces,
            workspaceId: trackedWorkspaceId,
          );
  final trackedWorkspaceMatches =
      trackedWorkspace?.matches(filter, sortMode) ?? false;
  final matchingWorkspace = ecommerceOrderSavedWorkspaceForState(
    workspaces: workspaces,
    filter: filter,
    sortMode: sortMode,
  );

  return OrderSavedWorkspaceActiveResolution(
    matchingWorkspace: matchingWorkspace,
    trackedWorkspace: trackedWorkspace,
    activeWorkspace:
        trackedWorkspaceMatches
            ? trackedWorkspace
            : matchingWorkspace ?? trackedWorkspace,
  );
}
