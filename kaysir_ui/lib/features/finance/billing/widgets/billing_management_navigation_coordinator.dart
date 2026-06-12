import 'package:flutter/widgets.dart';

import '../utils/billing_route_context.dart';
import 'billing_management_initial_local_navigation_controller.dart';
import 'billing_management_navigation_action_controller.dart';
import 'billing_management_navigation_session.dart';
import 'billing_management_route_fallback_controller.dart';
import 'billing_management_route_open_controller.dart';
import 'billing_management_surface_route_fallback_controller.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_local_target.dart';
import 'billing_navigation_route_target.dart';

class BillingManagementNavigationCoordinator {
  final BuildContext context;
  final BillingNavigationSurface currentSurface;
  final BillingNavigationDispatchSnapshot dispatchSnapshot;
  final BillingRouteContext routeContext;
  final String? tenantId;
  final String? businessDomain;
  final BillingManagementLocalNavigationHandler? onLocalNavigation;
  final BillingManagementRouteOpeningHandler? onDashboardRouteOpening;
  final BillingManagementRouteOpeningHandler? onProductWorkspaceRouteOpening;
  final BillingManagementRouteOpeningHandler? onTenantSelectionRouteOpening;
  final BillingManagementDestinationRouteHandler? onDashboardRouteDestination;
  final BillingManagementDestinationRouteHandler?
  onProductWorkspaceRouteDestination;
  final BillingManagementRouteFallbackHandler? onTenantSelectionRoute;
  final BillingManagementNavigationMessagePresenter? onUnavailableMessage;
  final bool showUnavailableMessages;
  final String dashboardFallbackScreenKey;
  final String productWorkspaceFallbackScreenKey;

  const BillingManagementNavigationCoordinator({
    required this.context,
    required this.currentSurface,
    required this.dispatchSnapshot,
    this.routeContext = BillingRouteContext.empty,
    this.tenantId,
    this.businessDomain,
    this.onLocalNavigation,
    this.onDashboardRouteOpening,
    this.onProductWorkspaceRouteOpening,
    this.onTenantSelectionRouteOpening,
    this.onDashboardRouteDestination,
    this.onProductWorkspaceRouteDestination,
    this.onTenantSelectionRoute,
    this.onUnavailableMessage,
    this.showUnavailableMessages = true,
    this.dashboardFallbackScreenKey = 'route.dashboard',
    this.productWorkspaceFallbackScreenKey = 'route.product_workspace',
  });

  factory BillingManagementNavigationCoordinator.fromSession({
    required BuildContext context,
    required BillingManagementNavigationSession session,
    BillingManagementLocalNavigationHandler? onLocalNavigation,
    BillingManagementRouteOpeningHandler? onDashboardRouteOpening,
    BillingManagementRouteOpeningHandler? onProductWorkspaceRouteOpening,
    BillingManagementRouteOpeningHandler? onTenantSelectionRouteOpening,
    BillingManagementDestinationRouteHandler? onDashboardRouteDestination,
    BillingManagementDestinationRouteHandler?
    onProductWorkspaceRouteDestination,
    BillingManagementRouteFallbackHandler? onTenantSelectionRoute,
    BillingManagementNavigationMessagePresenter? onUnavailableMessage,
    bool showUnavailableMessages = true,
    String dashboardFallbackScreenKey = 'route.dashboard',
    String productWorkspaceFallbackScreenKey = 'route.product_workspace',
  }) {
    return BillingManagementNavigationCoordinator(
      context: context,
      currentSurface: session.currentSurface,
      dispatchSnapshot: session.dispatchSnapshot,
      routeContext: session.routeContext,
      tenantId: session.tenantId,
      businessDomain: session.businessDomain,
      onLocalNavigation: onLocalNavigation,
      onDashboardRouteOpening: onDashboardRouteOpening,
      onProductWorkspaceRouteOpening: onProductWorkspaceRouteOpening,
      onTenantSelectionRouteOpening: onTenantSelectionRouteOpening,
      onDashboardRouteDestination: onDashboardRouteDestination,
      onProductWorkspaceRouteDestination: onProductWorkspaceRouteDestination,
      onTenantSelectionRoute: onTenantSelectionRoute,
      onUnavailableMessage: onUnavailableMessage,
      showUnavailableMessages: showUnavailableMessages,
      dashboardFallbackScreenKey: dashboardFallbackScreenKey,
      productWorkspaceFallbackScreenKey: productWorkspaceFallbackScreenKey,
    );
  }

  BillingManagementNavigationActionResult handleDestination(
    BillingNavigationDestinationId destinationId,
  ) {
    return BillingManagementNavigationActionController(
      context: context,
      dispatchSnapshot: dispatchSnapshot,
      onLocalNavigation: onLocalNavigation,
      onRouteNavigation: _openRoute,
      onRouteFallback: _handleRouteFallback,
      onUnavailableMessage: onUnavailableMessage,
      routeContext: routeContext,
      tenantId: tenantId,
      businessDomain: businessDomain,
      showUnavailableMessages: showUnavailableMessages,
    ).handle(destinationId);
  }

  BillingInitialLocalNavigationResult scheduleInitialDestination({
    required BillingNavigationDestinationId destinationId,
    required bool hasHandledInitialDestination,
    required VoidCallback markInitialDestinationHandled,
    required BillingInitialLocalTargetResolver resolveLocalTarget,
    required BillingInitialLocalNavigationGuard canHandleLocalNavigation,
    BillingPostFrameScheduler? schedulePostFrame,
  }) {
    final localNavigation = onLocalNavigation;
    if (localNavigation == null) {
      return BillingInitialLocalNavigationResult(
        destinationId: destinationId,
        localTarget: const BillingNavigationLocalTarget.none(),
        markedHandled: false,
        scheduled: false,
      );
    }

    return BillingManagementInitialLocalNavigationController(
      hasHandledInitialDestination: hasHandledInitialDestination,
      markInitialDestinationHandled: markInitialDestinationHandled,
      resolveLocalTarget: resolveLocalTarget,
      canHandleLocalNavigation: canHandleLocalNavigation,
      onLocalNavigation: localNavigation,
      schedulePostFrame: schedulePostFrame,
    ).schedule(destinationId);
  }

  bool _openRoute(BillingNavigationRouteTarget routeTarget) {
    return BillingManagementRouteOpenController(
      context: context,
      routeContext: routeContext,
      tenantId: tenantId,
      businessDomain: businessDomain,
      onDashboardRouteOpening: onDashboardRouteOpening,
      onProductWorkspaceRouteOpening: onProductWorkspaceRouteOpening,
      onTenantSelectionRouteOpening: onTenantSelectionRouteOpening,
    ).open(routeTarget);
  }

  bool _handleRouteFallback(BillingNavigationRouteTarget routeTarget) {
    return BillingManagementSurfaceRouteFallbackController(
      currentSurface: currentSurface,
      dashboardFallbackScreenKey: dashboardFallbackScreenKey,
      productWorkspaceFallbackScreenKey: productWorkspaceFallbackScreenKey,
      onDashboardLocalNavigation: onLocalNavigation,
      onProductWorkspaceLocalNavigation: onLocalNavigation,
      onDashboardRouteDestination: onDashboardRouteDestination,
      onProductWorkspaceRouteDestination: onProductWorkspaceRouteDestination,
      onTenantSelectionRoute: onTenantSelectionRoute,
    ).handle(routeTarget).handled;
  }
}
