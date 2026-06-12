import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_filter.dart';
import '../models/order_fulfillment_promise_policy.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_sort.dart';
import '../models/order_workspace_entry_context.dart';
import '../models/order_workspace_launch_context.dart';
import '../models/order_workspace_launch_resolution.dart';
import '../models/order_workspace_route_resolution.dart';
import '../models/order_workspace_snapshot.dart';
import '../models/order_workspace_view.dart';
import 'order_filter_bar.dart';
import 'order_fulfillment_promise_panel.dart';
import 'order_fulfillment_promise_policy_notice.dart';
import 'order_stats.dart';
import 'order_workspace_briefing_panel.dart';
import 'order_workspace_callbacks.dart';
import 'order_workspace_launch_context_banner.dart';
import 'order_workspace_navigation_header.dart';
import 'order_workspace_recommendation_panel.dart';
import 'order_workspace_sla_panel.dart';
import 'order_workspace_summary_strip.dart';

class OrderWorkspaceControlPane extends StatelessWidget {
  final OrderWorkspaceSnapshot snapshot;
  final List<POSCommerceChannel> salesChannels;
  final OrderWorkspaceEntryContext? entryContext;
  final OrderWorkspaceLaunchContext? launchContext;
  final OrderWorkspaceLaunchResolution? launchResolution;
  final OrderWorkspaceRouteResolution? routeResolution;
  final ValueChanged<String>? onOpenLocation;
  final ValueChanged<String>? onOpenCanonicalRoute;
  final OrderFilter filter;
  final OrderSortMode sortMode;
  final List<OrderSavedWorkspace> savedWorkspaces;
  final String? activeSavedWorkspaceId;
  final OrderFulfillmentPromisePolicy fulfillmentPromisePolicy;
  final List<OrderFulfillmentPromisePolicyIssue> fulfillmentPromisePolicyIssues;
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

  const OrderWorkspaceControlPane({
    super.key,
    required this.snapshot,
    required this.salesChannels,
    required this.entryContext,
    required this.launchContext,
    required this.launchResolution,
    required this.routeResolution,
    required this.onOpenLocation,
    required this.onOpenCanonicalRoute,
    required this.filter,
    required this.sortMode,
    required this.savedWorkspaces,
    required this.activeSavedWorkspaceId,
    required this.fulfillmentPromisePolicy,
    required this.fulfillmentPromisePolicyIssues,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onWorkspaceViewSelected,
    required this.onSaveWorkspace,
    required this.onSavedWorkspaceUpdated,
    required this.onSavedWorkspaceSelected,
    required this.onSavedWorkspaceDeleted,
    required this.onSavedWorkspaceDuplicated,
    required this.onSavedWorkspacePinnedChanged,
    required this.onSavedWorkspaceRenamed,
    required this.onSavedWorkspaceDescriptionChanged,
    required this.onSavedWorkspaceDescriptionReset,
    required this.onSavedWorkspaceMoved,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLaunchContext =
        entryContext?.effectiveLaunchContext ??
        launchResolution?.launchContext ??
        launchContext;
    final breadcrumbs =
        entryContext?.breadcrumbsFor(
          activeWorkspace: snapshot.workspaceContext,
        ) ??
        const [];
    final currentWorkspaceLocation =
        entryContext?.locationForWorkspaceContext(snapshot.workspaceContext) ??
        '';

    return Column(
      key: const ValueKey('order_workspace_control_pane'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (breadcrumbs.isNotEmpty || currentWorkspaceLocation.isNotEmpty) ...[
          OrderWorkspaceNavigationHeader(
            breadcrumbs: breadcrumbs,
            currentLocation: currentWorkspaceLocation,
            onOpenLocation: onOpenLocation,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
        ],
        if (effectiveLaunchContext != null) ...[
          OrderWorkspaceLaunchContextBanner(
            launchContext: effectiveLaunchContext,
            entryContext: entryContext,
            launchResolution: launchResolution,
            routeResolution: routeResolution,
            onOpenCanonicalRoute: onOpenCanonicalRoute,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
        ],
        OrdersStats(orders: snapshot.filteredOrders),
        const SizedBox(height: POSUiTokens.gapLarge),
        OrderFilterBar(
          filter: filter,
          sortMode: sortMode,
          workspaceViews: snapshot.workspaceViews,
          workspaceViewCounts: snapshot.workspaceViewCounts,
          channels: salesChannels,
          fulfillmentModes: snapshot.fulfillmentModes,
          statuses: snapshot.statuses,
          savedWorkspaces: savedWorkspaces,
          activeSavedWorkspaceId: activeSavedWorkspaceId,
          resultCount: snapshot.filteredOrderCount,
          onChanged: onFilterChanged,
          onSortChanged: onSortChanged,
          onWorkspaceViewSelected: onWorkspaceViewSelected,
          onSaveWorkspace: onSaveWorkspace,
          onSavedWorkspaceUpdated: onSavedWorkspaceUpdated,
          onSavedWorkspaceSelected: onSavedWorkspaceSelected,
          onSavedWorkspaceDeleted: onSavedWorkspaceDeleted,
          onSavedWorkspaceDuplicated: onSavedWorkspaceDuplicated,
          onSavedWorkspacePinnedChanged: onSavedWorkspacePinnedChanged,
          onSavedWorkspaceRenamed: onSavedWorkspaceRenamed,
          onSavedWorkspaceDescriptionChanged:
              onSavedWorkspaceDescriptionChanged,
          onSavedWorkspaceDescriptionReset: onSavedWorkspaceDescriptionReset,
          onSavedWorkspaceMoved: onSavedWorkspaceMoved,
        ),
        if (fulfillmentPromisePolicyIssues.isNotEmpty) ...[
          const SizedBox(height: POSUiTokens.gapLarge),
          OrderFulfillmentPromisePolicyNotice(
            issues: fulfillmentPromisePolicyIssues,
          ),
        ],
        if (snapshot.hasOrders) ...[
          const SizedBox(height: POSUiTokens.gapLarge),
          if (snapshot.workspaceRecommendations.isNotEmpty) ...[
            OrderWorkspaceRecommendationPanel(
              activeWorkspace: snapshot.workspaceContext,
              workspaceViews: snapshot.workspaceViews,
              workspaceViewCounts: snapshot.workspaceViewCounts,
              recommendations: snapshot.workspaceRecommendations,
              onWorkspaceViewSelected: onWorkspaceViewSelected,
            ),
            const SizedBox(height: POSUiTokens.gapLarge),
          ],
          OrderWorkspaceBriefingPanel(
            workspace: snapshot.workspaceContext,
            orders: snapshot.filteredOrders,
            totalOrderCount: snapshot.totalOrderCount,
          ),
        ],
        if (snapshot.hasFilteredOrders) ...[
          const SizedBox(height: POSUiTokens.gapLarge),
          OrderWorkspaceSlaPanel(
            orders: snapshot.filteredOrders,
            now: snapshot.referenceTime,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          OrderFulfillmentPromisePanel(
            orders: snapshot.filteredOrders,
            now: snapshot.referenceTime,
            policy: fulfillmentPromisePolicy,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          OrderWorkspaceSummaryStrip(
            workspace: snapshot.workspaceContext,
            orders: snapshot.filteredOrders,
          ),
        ],
      ],
    );
  }
}
