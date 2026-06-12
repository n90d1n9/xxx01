import 'package:flutter/material.dart';

import '../utils/billing_route_context.dart';
import 'billing_app_route_navigator.dart';
import 'billing_management_route_fallback_controller.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_plan.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_local_target.dart';
import 'billing_navigation_route_target.dart';

typedef BillingManagementLocalNavigationHandler =
    bool Function(BillingNavigationLocalTarget localTarget);

typedef BillingManagementRouteNavigationHandler =
    bool Function(BillingNavigationRouteTarget routeTarget);

typedef BillingManagementNavigationMessagePresenter =
    void Function(String message);

enum BillingManagementNavigationActionResultKind {
  missingPlan,
  unavailable,
  local,
  routeOpened,
  routeFallback,
  ignored,
}

class BillingManagementNavigationActionResult {
  final BillingManagementNavigationActionResultKind kind;
  final BillingNavigationDestinationId destinationId;
  final BillingNavigationDispatchPlan? dispatchPlan;
  final BillingNavigationLocalTarget? localTarget;
  final BillingNavigationRouteTarget? routeTarget;
  final String? message;
  final bool localHandled;
  final bool routeFallbackHandled;

  const BillingManagementNavigationActionResult._({
    required this.kind,
    required this.destinationId,
    this.dispatchPlan,
    this.localTarget,
    this.routeTarget,
    this.message,
    this.localHandled = false,
    this.routeFallbackHandled = false,
  });

  const BillingManagementNavigationActionResult.missingPlan({
    required BillingNavigationDestinationId destinationId,
  }) : this._(
         kind: BillingManagementNavigationActionResultKind.missingPlan,
         destinationId: destinationId,
       );

  BillingManagementNavigationActionResult.unavailable({
    required BillingNavigationDispatchPlan dispatchPlan,
    required String message,
  }) : this._(
         kind: BillingManagementNavigationActionResultKind.unavailable,
         destinationId: dispatchPlan.destinationId,
         dispatchPlan: dispatchPlan,
         message: message,
       );

  BillingManagementNavigationActionResult.local({
    required BillingNavigationDispatchPlan dispatchPlan,
    required BillingNavigationLocalTarget localTarget,
    required bool localHandled,
  }) : this._(
         kind: BillingManagementNavigationActionResultKind.local,
         destinationId: dispatchPlan.destinationId,
         dispatchPlan: dispatchPlan,
         localTarget: localTarget,
         localHandled: localHandled,
       );

  BillingManagementNavigationActionResult.routeOpened({
    required BillingNavigationDispatchPlan dispatchPlan,
    required BillingNavigationRouteTarget routeTarget,
  }) : this._(
         kind: BillingManagementNavigationActionResultKind.routeOpened,
         destinationId: dispatchPlan.destinationId,
         dispatchPlan: dispatchPlan,
         routeTarget: routeTarget,
       );

  BillingManagementNavigationActionResult.routeFallback({
    required BillingNavigationDispatchPlan dispatchPlan,
    required BillingNavigationRouteTarget routeTarget,
    required bool routeFallbackHandled,
  }) : this._(
         kind: BillingManagementNavigationActionResultKind.routeFallback,
         destinationId: dispatchPlan.destinationId,
         dispatchPlan: dispatchPlan,
         routeTarget: routeTarget,
         routeFallbackHandled: routeFallbackHandled,
       );

  BillingManagementNavigationActionResult.ignored({
    required BillingNavigationDispatchPlan dispatchPlan,
  }) : this._(
         kind: BillingManagementNavigationActionResultKind.ignored,
         destinationId: dispatchPlan.destinationId,
         dispatchPlan: dispatchPlan,
       );

  bool get handled {
    return switch (kind) {
      BillingManagementNavigationActionResultKind.unavailable => true,
      BillingManagementNavigationActionResultKind.local => localHandled,
      BillingManagementNavigationActionResultKind.routeOpened => true,
      BillingManagementNavigationActionResultKind.routeFallback =>
        routeFallbackHandled,
      BillingManagementNavigationActionResultKind.missingPlan ||
      BillingManagementNavigationActionResultKind.ignored => false,
    };
  }

  bool get requiresRouteFallback {
    return kind == BillingManagementNavigationActionResultKind.routeFallback &&
        !routeFallbackHandled &&
        routeTarget != null;
  }
}

class BillingManagementNavigationActionController {
  final BuildContext context;
  final BillingNavigationDispatchSnapshot dispatchSnapshot;
  final BillingManagementLocalNavigationHandler? onLocalNavigation;
  final BillingManagementRouteNavigationHandler? onRouteNavigation;
  final BillingManagementRouteFallbackHandler? onRouteFallback;
  final BillingManagementNavigationMessagePresenter? onUnavailableMessage;
  final BillingRouteContext routeContext;
  final String? tenantId;
  final String? businessDomain;
  final bool showUnavailableMessages;

  const BillingManagementNavigationActionController({
    required this.context,
    required this.dispatchSnapshot,
    this.onLocalNavigation,
    this.onRouteNavigation,
    this.onRouteFallback,
    this.onUnavailableMessage,
    this.routeContext = BillingRouteContext.empty,
    this.tenantId,
    this.businessDomain,
    this.showUnavailableMessages = true,
  });

  BillingManagementNavigationActionResult handle(
    BillingNavigationDestinationId destinationId,
  ) {
    final dispatchPlan = dispatchSnapshot.planFor(destinationId);
    if (dispatchPlan == null) {
      return BillingManagementNavigationActionResult.missingPlan(
        destinationId: destinationId,
      );
    }

    if (dispatchPlan.isUnavailable) {
      final message = dispatchPlan.disabledReason ?? dispatchPlan.description;
      if (showUnavailableMessages) {
        _showUnavailableMessage(message);
      }
      return BillingManagementNavigationActionResult.unavailable(
        dispatchPlan: dispatchPlan,
        message: message,
      );
    }

    switch (dispatchPlan.kind) {
      case BillingNavigationDispatchKind.local:
        final localTarget = dispatchPlan.localTarget;
        return BillingManagementNavigationActionResult.local(
          dispatchPlan: dispatchPlan,
          localTarget: localTarget,
          localHandled: onLocalNavigation?.call(localTarget) ?? false,
        );
      case BillingNavigationDispatchKind.route:
        final routeTarget = dispatchPlan.routeTarget;
        final didOpenRoute =
            onRouteNavigation?.call(routeTarget) ??
            _openRouteTarget(routeTarget);
        if (didOpenRoute) {
          return BillingManagementNavigationActionResult.routeOpened(
            dispatchPlan: dispatchPlan,
            routeTarget: routeTarget,
          );
        }

        return BillingManagementNavigationActionResult.routeFallback(
          dispatchPlan: dispatchPlan,
          routeTarget: routeTarget,
          routeFallbackHandled: onRouteFallback?.call(routeTarget) ?? false,
        );
      case BillingNavigationDispatchKind.unavailable:
      case BillingNavigationDispatchKind.ignored:
        return BillingManagementNavigationActionResult.ignored(
          dispatchPlan: dispatchPlan,
        );
    }
  }

  bool _openRouteTarget(BillingNavigationRouteTarget routeTarget) {
    return openBillingAppRouteTarget(
      context,
      routeTarget,
      tenantId: tenantId,
      businessDomain: businessDomain,
      routeContext: routeContext,
    );
  }

  void _showUnavailableMessage(String message) {
    if (onUnavailableMessage != null) {
      onUnavailableMessage!(message);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
