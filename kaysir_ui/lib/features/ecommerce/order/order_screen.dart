import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../omni_channel/activity/widgets/omni_channel_activity_insight_status_banner.dart';
import 'models/order_active_filter_summary.dart';
import 'models/order_fulfillment_promise_policy.dart';
import 'models/order_workspace_launch_context.dart';
import 'models/order_workspace_query_state.dart';
import 'models/order_workspace_route_resolution.dart';
import 'models/order_saved_workspace.dart';
import 'models/order_workspace_profile.dart';
import 'models/order_workspace_view.dart';
import 'models/order_workspace_screen_state.dart';
import 'states/order_fulfillment_promise_policy_provider.dart';
import 'states/order_provider.dart';
import 'states/order_saved_workspace_provider.dart';
import 'widgets/order_workspace_content.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderWorkspaceProfile profile;
  final OrderWorkspaceLaunchContext? launchContext;
  final OrderWorkspaceQueryState? workspaceQueryState;
  final OrderWorkspaceRouteResolution? routeResolution;
  final ValueChanged<String>? onOpenLocation;
  final ValueChanged<String>? onOpenCanonicalRoute;

  const OrdersScreen({
    super.key,
    this.profile = ecommerceAllCommerceOrderWorkspaceProfile,
    this.launchContext,
    this.workspaceQueryState,
    this.routeResolution,
    this.onOpenLocation,
    this.onOpenCanonicalRoute,
  });

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late OrderWorkspaceScreenState _screenState;

  @override
  void initState() {
    super.initState();
    _screenState = _resolveScreenState();
  }

  @override
  void didUpdateWidget(OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (ecommerceOrderWorkspaceScreenInputsChanged(
      previousProfile: oldWidget.profile,
      nextProfile: widget.profile,
      previousLaunchContext: oldWidget.launchContext,
      nextLaunchContext: widget.launchContext,
      previousQueryState: oldWidget.workspaceQueryState,
      nextQueryState: widget.workspaceQueryState,
      previousRouteResolution: oldWidget.routeResolution,
      nextRouteResolution: widget.routeResolution,
    )) {
      setState(() => _screenState = _resolveScreenState());
    }
  }

  void _applyWorkspaceView(OrderWorkspaceView view) {
    final changed = _screenState.changesWorkspaceView(view);
    setState(() => _screenState = _screenState.withWorkspaceView(view));
    if (changed) _openWorkspaceViewLocation(view);
  }

  Future<void> _saveWorkspace(OrderSavedWorkspace workspace) async {
    await ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .saveWorkspace(workspace);
    if (!mounted) return;

    setState(() {
      _screenState = _screenState.withSavedWorkspaceActivated(workspace);
    });
  }

  Future<void> _updateSavedWorkspace(OrderSavedWorkspace workspace) async {
    await ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .updateWorkspace(workspace);
    if (!mounted) return;

    setState(() => _screenState = _screenState.withSavedWorkspace(workspace));
  }

  void _applySavedWorkspace(OrderSavedWorkspace workspace) {
    final changed = _screenState.changesSavedWorkspace(workspace);
    setState(() => _screenState = _screenState.withSavedWorkspace(workspace));
    if (changed) _openSavedWorkspaceLocation(workspace);
  }

  Future<void> _deleteSavedWorkspace(OrderSavedWorkspace workspace) async {
    await ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .deleteWorkspace(workspace.id);
    if (!mounted) return;

    setState(() {
      _screenState = _screenState.withDeletedSavedWorkspace(workspace);
    });
  }

  Future<void> _duplicateSavedWorkspace(OrderSavedWorkspace workspace) async {
    final workspaces = ref.read(
      ecommerceOrderSavedWorkspacesProvider(widget.profile.id),
    );
    final duplicate = ecommerceOrderSavedWorkspaceDuplicate(
      workspaces: workspaces,
      workspaceId: workspace.id,
    );
    if (duplicate == null) return;

    await ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .duplicateWorkspace(workspace.id);
    if (!mounted) return;

    setState(() => _screenState = _screenState.withSavedWorkspace(duplicate));
  }

  Future<void> _pinSavedWorkspace(
    OrderSavedWorkspace workspace,
    bool isPinned,
  ) {
    return ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .pinWorkspace(workspace.id, isPinned);
  }

  Future<void> _renameSavedWorkspace(
    OrderSavedWorkspace workspace,
    String label,
  ) {
    return ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .renameWorkspace(workspace.id, label);
  }

  Future<void> _updateSavedWorkspaceDescription(
    OrderSavedWorkspace workspace,
    String description,
  ) {
    return ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .updateWorkspaceDescription(workspace.id, description);
  }

  Future<void> _resetSavedWorkspaceDescription(
    OrderSavedWorkspace workspace,
    List<OrderActiveFilterSummaryItem> summaryItems,
  ) {
    return ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .resetWorkspaceDescription(workspace.id, summaryItems);
  }

  Future<void> _moveSavedWorkspace(
    OrderSavedWorkspace workspace,
    OrderSavedWorkspaceMoveDirection direction,
  ) {
    return ref
        .read(ecommerceOrderSavedWorkspacesProvider(widget.profile.id).notifier)
        .moveWorkspace(workspace.id, direction);
  }

  OrderWorkspaceScreenState _resolveScreenState() {
    return OrderWorkspaceScreenState.resolve(
      profile: widget.profile,
      launchContext: widget.launchContext,
      workspaceQueryState: widget.workspaceQueryState,
      routeResolution: widget.routeResolution,
    );
  }

  void _openWorkspaceViewLocation(OrderWorkspaceView view) {
    final handler = widget.onOpenLocation ?? widget.onOpenCanonicalRoute;
    if (handler == null) return;

    final location = _screenState.locationForWorkspaceView(view);
    if (location.trim().isEmpty) return;

    handler(location);
  }

  void _openSavedWorkspaceLocation(OrderSavedWorkspace workspace) {
    final handler = widget.onOpenLocation ?? widget.onOpenCanonicalRoute;
    if (handler == null) return;

    final location = _screenState.locationForSavedWorkspace(workspace);
    if (location.trim().isEmpty) return;

    handler(location);
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ecommerceOrdersProvider);
    final savedWorkspaces = ref.watch(
      ecommerceOrderSavedWorkspacesProvider(widget.profile.id),
    );
    final activeSavedWorkspaceId = _screenState.resolvedActiveSavedWorkspaceId(
      savedWorkspaces: savedWorkspaces,
      fallbackSavedWorkspaceId: _screenState.activeSavedWorkspaceId,
    );
    final profilePolicy = widget.profile.fulfillmentPromisePolicy;
    final OrderFulfillmentPromisePolicy fulfillmentPromisePolicy;
    final List<OrderFulfillmentPromisePolicyIssue>
    fulfillmentPromisePolicyIssues;
    if (profilePolicy != null) {
      fulfillmentPromisePolicy = profilePolicy;
      fulfillmentPromisePolicyIssues = profilePolicy.validate();
    } else {
      fulfillmentPromisePolicy = ref.watch(
        ecommerceOrderFulfillmentPromisePolicyProvider,
      );
      fulfillmentPromisePolicyIssues = ref.watch(
        ecommerceOrderFulfillmentPromisePolicyIssuesProvider,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.profile.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              OmniChannelActivityInsightStatusBanner(
                padding: const EdgeInsets.only(bottom: 8),
                showNextStep: false,
                onOpenActivityCenter:
                    widget.onOpenLocation ?? widget.onOpenCanonicalRoute,
              ),
              Expanded(
                child: OrderWorkspaceContent(
                  orders: orders,
                  filter: _screenState.filter,
                  sortMode: _screenState.sortMode,
                  fulfillmentPromisePolicy: fulfillmentPromisePolicy,
                  fulfillmentPromisePolicyIssues:
                      fulfillmentPromisePolicyIssues,
                  workspaceViews: widget.profile.workspaceViews,
                  savedWorkspaces: savedWorkspaces,
                  activeSavedWorkspaceId: activeSavedWorkspaceId,
                  salesChannels: widget.profile.salesChannels,
                  entryContext: _screenState.entryContext,
                  onOpenLocation:
                      widget.onOpenLocation ?? widget.onOpenCanonicalRoute,
                  onOpenCanonicalRoute:
                      widget.onOpenCanonicalRoute ?? widget.onOpenLocation,
                  recommendationLimit: widget.profile.recommendationLimit,
                  compactLeadingMaxHeightFactor: 0.5,
                  onFilterChanged:
                      (filter) => setState(
                        () =>
                            _screenState = _screenState
                                .withFilterFromWorkspaceControls(
                                  filter: filter,
                                  savedWorkspaces: savedWorkspaces,
                                  fallbackSavedWorkspaceId:
                                      activeSavedWorkspaceId,
                                ),
                      ),
                  onSortChanged:
                      (sortMode) => setState(
                        () =>
                            _screenState = _screenState
                                .withSortModeFromWorkspaceControls(
                                  sortMode: sortMode,
                                  savedWorkspaces: savedWorkspaces,
                                  fallbackSavedWorkspaceId:
                                      activeSavedWorkspaceId,
                                ),
                      ),
                  onWorkspaceViewSelected: _applyWorkspaceView,
                  onSaveWorkspace: _saveWorkspace,
                  onSavedWorkspaceUpdated: _updateSavedWorkspace,
                  onSavedWorkspaceSelected: _applySavedWorkspace,
                  onSavedWorkspaceDeleted: _deleteSavedWorkspace,
                  onSavedWorkspaceDuplicated: _duplicateSavedWorkspace,
                  onSavedWorkspacePinnedChanged: _pinSavedWorkspace,
                  onSavedWorkspaceRenamed: _renameSavedWorkspace,
                  onSavedWorkspaceDescriptionChanged:
                      _updateSavedWorkspaceDescription,
                  onSavedWorkspaceDescriptionReset:
                      _resetSavedWorkspaceDescription,
                  onSavedWorkspaceMoved: _moveSavedWorkspace,
                  onOrderStatusChanged: (order, status) {
                    ref
                        .read(ecommerceOrdersProvider.notifier)
                        .updateOrderStatus(order.id, status);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
