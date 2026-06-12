import 'order_filter.dart';
import 'order_saved_workspace.dart';
import 'order_sort.dart';
import 'order_workspace_entry_context.dart';
import 'order_workspace_launch_context.dart';
import 'order_workspace_profile.dart';
import 'order_workspace_query_state.dart';
import 'order_workspace_route_resolution.dart';
import 'order_workspace_view.dart';

class OrderWorkspaceScreenState {
  final OrderFilter filter;
  final OrderSortMode sortMode;
  final OrderWorkspaceEntryContext entryContext;
  final String? activeSavedWorkspaceId;

  const OrderWorkspaceScreenState({
    required this.filter,
    required this.sortMode,
    required this.entryContext,
    this.activeSavedWorkspaceId,
  });

  factory OrderWorkspaceScreenState.resolve({
    required OrderWorkspaceProfile profile,
    OrderWorkspaceLaunchContext? launchContext,
    OrderWorkspaceQueryState? workspaceQueryState,
    OrderWorkspaceRouteResolution? routeResolution,
  }) {
    final entryContext = OrderWorkspaceEntryContext.resolve(
      profile: profile,
      launchContext: launchContext,
      routeResolution: routeResolution,
    );

    final queryState = workspaceQueryState;
    if (queryState != null) {
      return OrderWorkspaceScreenState(
        filter: queryState.filter,
        sortMode: queryState.sortMode,
        entryContext: entryContext,
      );
    }

    final workspaceView = entryContext.appliedWorkspaceView;
    if (workspaceView != null) {
      return OrderWorkspaceScreenState(
        filter: workspaceView.filter,
        sortMode: workspaceView.sortMode,
        entryContext: entryContext,
      );
    }

    return OrderWorkspaceScreenState(
      filter: entryContext.profile.initialFilter,
      sortMode: entryContext.profile.initialSortMode,
      entryContext: entryContext,
    );
  }

  bool changesWorkspaceView(OrderWorkspaceView view) {
    return !view.matches(filter, sortMode);
  }

  bool changesSavedWorkspace(OrderSavedWorkspace workspace) {
    return !workspace.matches(filter, sortMode);
  }

  String? resolvedActiveSavedWorkspaceId({
    required List<OrderSavedWorkspace> savedWorkspaces,
    String? fallbackSavedWorkspaceId,
  }) {
    return ecommerceOrderSavedWorkspaceActiveResolution(
      workspaces: savedWorkspaces,
      trackedWorkspaceId: fallbackSavedWorkspaceId ?? activeSavedWorkspaceId,
      filter: filter,
      sortMode: sortMode,
    ).activeWorkspaceId;
  }

  OrderWorkspaceScreenState withWorkspaceView(OrderWorkspaceView view) {
    return OrderWorkspaceScreenState(
      filter: view.filter,
      sortMode: view.sortMode,
      entryContext: entryContext,
    );
  }

  OrderWorkspaceScreenState withSavedWorkspace(OrderSavedWorkspace workspace) {
    return OrderWorkspaceScreenState(
      filter: workspace.filter,
      sortMode: workspace.sortMode,
      entryContext: entryContext,
      activeSavedWorkspaceId: workspace.id,
    );
  }

  OrderWorkspaceScreenState withSavedWorkspaceActivated(
    OrderSavedWorkspace workspace,
  ) {
    return OrderWorkspaceScreenState(
      filter: filter,
      sortMode: sortMode,
      entryContext: entryContext,
      activeSavedWorkspaceId: workspace.id,
    );
  }

  OrderWorkspaceScreenState withDeletedSavedWorkspace(
    OrderSavedWorkspace workspace,
  ) {
    return OrderWorkspaceScreenState(
      filter: filter,
      sortMode: sortMode,
      entryContext: entryContext,
      activeSavedWorkspaceId:
          activeSavedWorkspaceId == workspace.id
              ? null
              : activeSavedWorkspaceId,
    );
  }

  OrderWorkspaceScreenState withFilterFromWorkspaceControls({
    required OrderFilter filter,
    required List<OrderSavedWorkspace> savedWorkspaces,
    String? fallbackSavedWorkspaceId,
  }) {
    return OrderWorkspaceScreenState(
      filter: filter,
      sortMode: sortMode,
      entryContext: entryContext,
      activeSavedWorkspaceId:
          ecommerceOrderSavedWorkspaceActiveResolution(
            workspaces: savedWorkspaces,
            trackedWorkspaceId:
                fallbackSavedWorkspaceId ?? activeSavedWorkspaceId,
            filter: filter,
            sortMode: sortMode,
          ).activeWorkspaceId,
    );
  }

  OrderWorkspaceScreenState withSortModeFromWorkspaceControls({
    required OrderSortMode sortMode,
    required List<OrderSavedWorkspace> savedWorkspaces,
    String? fallbackSavedWorkspaceId,
  }) {
    return OrderWorkspaceScreenState(
      filter: filter,
      sortMode: sortMode,
      entryContext: entryContext,
      activeSavedWorkspaceId:
          ecommerceOrderSavedWorkspaceActiveResolution(
            workspaces: savedWorkspaces,
            trackedWorkspaceId:
                fallbackSavedWorkspaceId ?? activeSavedWorkspaceId,
            filter: filter,
            sortMode: sortMode,
          ).activeWorkspaceId,
    );
  }

  String locationForWorkspaceView(OrderWorkspaceView view) {
    return entryContext.locationForWorkspaceView(view);
  }

  String locationForSavedWorkspace(OrderSavedWorkspace workspace) {
    return entryContext.locationForWorkspaceContext(
      workspace.toWorkspaceContext(),
    );
  }
}

bool ecommerceOrderWorkspaceScreenInputsChanged({
  required OrderWorkspaceProfile previousProfile,
  required OrderWorkspaceProfile nextProfile,
  required OrderWorkspaceLaunchContext? previousLaunchContext,
  required OrderWorkspaceLaunchContext? nextLaunchContext,
  required OrderWorkspaceQueryState? previousQueryState,
  required OrderWorkspaceQueryState? nextQueryState,
  required OrderWorkspaceRouteResolution? previousRouteResolution,
  required OrderWorkspaceRouteResolution? nextRouteResolution,
}) {
  return previousProfile.id != nextProfile.id ||
      ecommerceOrderWorkspaceLaunchContextChanged(
        previousLaunchContext,
        nextLaunchContext,
      ) ||
      ecommerceOrderWorkspaceQueryStateChanged(
        previousQueryState,
        nextQueryState,
      ) ||
      ecommerceOrderWorkspaceRouteResolutionChanged(
        previousRouteResolution,
        nextRouteResolution,
      );
}

bool ecommerceOrderWorkspaceLaunchContextChanged(
  OrderWorkspaceLaunchContext? previous,
  OrderWorkspaceLaunchContext? next,
) {
  if (previous == null || next == null) return previous != next;

  return previous.sourceProfileId != next.sourceProfileId ||
      previous.sourceProfileLabel != next.sourceProfileLabel ||
      previous.orderWorkspaceProfileId != next.orderWorkspaceProfileId ||
      previous.workspaceViewId != next.workspaceViewId ||
      previous.workspaceViewLabel != next.workspaceViewLabel ||
      previous.reason != next.reason;
}

bool ecommerceOrderWorkspaceRouteResolutionChanged(
  OrderWorkspaceRouteResolution? previous,
  OrderWorkspaceRouteResolution? next,
) {
  if (previous == null || next == null) return previous != next;

  return previous.canonicalPath != next.canonicalPath ||
      previous.requestedProfileId != next.requestedProfileId ||
      previous.status != next.status;
}

bool ecommerceOrderWorkspaceQueryStateChanged(
  OrderWorkspaceQueryState? previous,
  OrderWorkspaceQueryState? next,
) {
  if (previous == null || next == null) return previous != next;

  return !ecommerceOrderFiltersEqual(previous.filter, next.filter) ||
      previous.sortMode != next.sortMode;
}
