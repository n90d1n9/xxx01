import 'order_active_filter_summary.dart';
import 'order_filter.dart';
import 'order_saved_workspace_active_resolution.dart';
import 'order_saved_workspace_model.dart';
import 'order_saved_workspace_shortcuts.dart';
import 'order_saved_workspace_state.dart';
import 'order_sort.dart';
import 'order_workspace_view.dart';

class OrderSavedWorkspaceFilterState {
  final List<OrderSavedWorkspace> visibleWorkspaces;
  final OrderSavedWorkspace? matchingWorkspace;
  final OrderSavedWorkspace? trackedWorkspace;
  final OrderSavedWorkspace? activeWorkspace;
  final bool isActiveWorkspaceModified;
  final String? activeWorkspaceChangeSummary;
  final bool canSaveCurrentWorkspace;

  const OrderSavedWorkspaceFilterState({
    required this.visibleWorkspaces,
    required this.matchingWorkspace,
    required this.trackedWorkspace,
    required this.activeWorkspace,
    required this.isActiveWorkspaceModified,
    required this.activeWorkspaceChangeSummary,
    required this.canSaveCurrentWorkspace,
  });

  bool get shouldShowSavedWorkspacePanel {
    return visibleWorkspaces.isNotEmpty || canSaveCurrentWorkspace;
  }
}

OrderSavedWorkspaceFilterState ecommerceOrderSavedWorkspaceFilterState({
  required List<OrderSavedWorkspace> savedWorkspaces,
  required String? activeSavedWorkspaceId,
  required OrderFilter filter,
  required OrderSortMode sortMode,
  required OrderWorkspaceContext workspaceContext,
  required List<OrderActiveFilterSummaryItem> activeFilterSummary,
  required bool canSaveWorkspace,
}) {
  final visibleWorkspaces = ecommerceOrderSavedWorkspacesForDisplay(
    savedWorkspaces,
  );
  final activeResolution = ecommerceOrderSavedWorkspaceActiveResolution(
    workspaces: visibleWorkspaces,
    trackedWorkspaceId: activeSavedWorkspaceId,
    filter: filter,
    sortMode: sortMode,
  );
  final matchingWorkspace = activeResolution.matchingWorkspace;
  final trackedWorkspace = activeResolution.trackedWorkspace;
  final trackedWorkspaceMatches = activeResolution.matchesTrackedWorkspace(
    filter: filter,
    sortMode: sortMode,
  );
  final isActiveWorkspaceModified =
      !trackedWorkspaceMatches &&
      matchingWorkspace == null &&
      trackedWorkspace != null &&
      !trackedWorkspace.matches(filter, sortMode);
  final activeWorkspaceChangeSummary =
      isActiveWorkspaceModified
          ? ecommerceOrderSavedWorkspaceChangeSummary(
            workspace: trackedWorkspace,
            filter: filter,
            sortMode: sortMode,
          )
          : null;
  final canSaveCurrentWorkspace =
      canSaveWorkspace &&
      !workspaceContext.isPreset &&
      activeFilterSummary.isNotEmpty &&
      matchingWorkspace == null;

  return OrderSavedWorkspaceFilterState(
    visibleWorkspaces: visibleWorkspaces,
    matchingWorkspace: matchingWorkspace,
    trackedWorkspace: trackedWorkspace,
    activeWorkspace: activeResolution.activeWorkspace,
    isActiveWorkspaceModified: isActiveWorkspaceModified,
    activeWorkspaceChangeSummary: activeWorkspaceChangeSummary,
    canSaveCurrentWorkspace: canSaveCurrentWorkspace,
  );
}
