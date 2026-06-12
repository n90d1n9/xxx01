import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../../channel/models/sales_channel.dart';
import '../../dashboard/widgets/adaptive_two_pane.dart';
import '../models/order_filter.dart';
import '../models/order_fulfillment_promise_policy.dart';
import '../models/order_workspace_entry_context.dart';
import '../models/order_workspace_launch_context.dart';
import '../models/order_workspace_launch_resolution.dart';
import '../models/order_workspace_route_resolution.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_sort.dart';
import '../models/order_workspace_snapshot.dart';
import '../models/order_workspace_view.dart';
import 'order_transactions_pane.dart';
import 'order_workspace_callbacks.dart';
import 'order_workspace_control_pane.dart';

export 'order_workspace_callbacks.dart';

/// Responsive ecommerce order workspace composed from reusable control and list panes.
class OrderWorkspaceContent extends StatelessWidget {
  final List<pos_order.Order> orders;
  final OrderFilter filter;
  final OrderSortMode sortMode;
  final OrderFulfillmentPromisePolicy fulfillmentPromisePolicy;
  final List<OrderFulfillmentPromisePolicyIssue> fulfillmentPromisePolicyIssues;
  final List<OrderWorkspaceView> workspaceViews;
  final List<OrderSavedWorkspace> savedWorkspaces;
  final String? activeSavedWorkspaceId;
  final List<POSCommerceChannel> salesChannels;
  final OrderWorkspaceEntryContext? entryContext;
  final OrderWorkspaceLaunchContext? launchContext;
  final OrderWorkspaceLaunchResolution? launchResolution;
  final OrderWorkspaceRouteResolution? routeResolution;
  final ValueChanged<String>? onOpenLocation;
  final ValueChanged<String>? onOpenCanonicalRoute;
  final DateTime? now;
  final int recommendationLimit;
  final double compactLeadingMaxHeightFactor;
  final ValueChanged<OrderFilter> onFilterChanged;
  final ValueChanged<OrderSortMode> onSortChanged;
  final ValueChanged<OrderWorkspaceView> onWorkspaceViewSelected;
  final ValueChanged<OrderSavedWorkspace>? onSaveWorkspace;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceUpdated;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceSelected;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceDeleted;
  final ValueChanged<OrderSavedWorkspace>? onSavedWorkspaceDuplicated;
  final OrderSavedWorkspacePinChanged? onSavedWorkspacePinnedChanged;
  final OrderSavedWorkspaceRenamed? onSavedWorkspaceRenamed;
  final OrderSavedWorkspaceDescriptionChanged?
  onSavedWorkspaceDescriptionChanged;
  final OrderSavedWorkspaceDescriptionReset? onSavedWorkspaceDescriptionReset;
  final OrderSavedWorkspaceMoved? onSavedWorkspaceMoved;
  final OrderStatusChanged onOrderStatusChanged;

  const OrderWorkspaceContent({
    super.key,
    required this.orders,
    required this.filter,
    required this.sortMode,
    required this.fulfillmentPromisePolicy,
    this.fulfillmentPromisePolicyIssues = const [],
    this.workspaceViews = ecommerceDefaultOrderWorkspaceViews,
    this.savedWorkspaces = const [],
    this.activeSavedWorkspaceId,
    this.salesChannels = SalesChannels.all,
    this.entryContext,
    this.launchContext,
    this.launchResolution,
    this.routeResolution,
    this.onOpenLocation,
    this.onOpenCanonicalRoute,
    this.now,
    this.recommendationLimit = 3,
    this.compactLeadingMaxHeightFactor = 0.58,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onWorkspaceViewSelected,
    this.onSaveWorkspace,
    this.onSavedWorkspaceUpdated,
    this.onSavedWorkspaceSelected,
    this.onSavedWorkspaceDeleted,
    this.onSavedWorkspaceDuplicated,
    this.onSavedWorkspacePinnedChanged,
    this.onSavedWorkspaceRenamed,
    this.onSavedWorkspaceDescriptionChanged,
    this.onSavedWorkspaceDescriptionReset,
    this.onSavedWorkspaceMoved,
    required this.onOrderStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final snapshot = OrderWorkspaceSnapshot.fromOrders(
      orders: orders,
      filter: filter,
      sortMode: sortMode,
      workspaceViews: workspaceViews,
      now: now,
      recommendationLimit: recommendationLimit,
    );

    return AdaptiveTwoPane(
      key: const ValueKey('order_workspace_content'),
      maxContentWidth: 1320,
      wideBreakpoint: 1060,
      compactLeadingMaxHeightFactor: compactLeadingMaxHeightFactor,
      leadingPaneWidthBuilder: (width) => width >= 1220 ? 440 : 390,
      leadingPane: OrderWorkspaceControlPane(
        snapshot: snapshot,
        salesChannels: salesChannels,
        entryContext: entryContext,
        launchContext: launchContext,
        launchResolution: launchResolution,
        routeResolution: routeResolution,
        onOpenLocation: onOpenLocation ?? onOpenCanonicalRoute,
        onOpenCanonicalRoute: onOpenCanonicalRoute,
        filter: filter,
        sortMode: sortMode,
        savedWorkspaces: savedWorkspaces,
        activeSavedWorkspaceId: activeSavedWorkspaceId,
        fulfillmentPromisePolicy: fulfillmentPromisePolicy,
        fulfillmentPromisePolicyIssues: fulfillmentPromisePolicyIssues,
        onFilterChanged: onFilterChanged,
        onSortChanged: onSortChanged,
        onWorkspaceViewSelected: onWorkspaceViewSelected,
        onSaveWorkspace: onSaveWorkspace,
        onSavedWorkspaceUpdated: onSavedWorkspaceUpdated,
        onSavedWorkspaceSelected: onSavedWorkspaceSelected,
        onSavedWorkspaceDeleted: onSavedWorkspaceDeleted,
        onSavedWorkspaceDuplicated: onSavedWorkspaceDuplicated,
        onSavedWorkspacePinnedChanged: onSavedWorkspacePinnedChanged,
        onSavedWorkspaceRenamed: onSavedWorkspaceRenamed,
        onSavedWorkspaceDescriptionChanged: onSavedWorkspaceDescriptionChanged,
        onSavedWorkspaceDescriptionReset: onSavedWorkspaceDescriptionReset,
        onSavedWorkspaceMoved: onSavedWorkspaceMoved,
      ),
      mainPane: OrderTransactionsPane(
        snapshot: snapshot,
        onOrderStatusChanged: onOrderStatusChanged,
      ),
    );
  }
}
