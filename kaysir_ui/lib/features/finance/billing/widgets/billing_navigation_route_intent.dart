import '../models/billing_business_domain_screen_registry.dart';
import 'billing_navigation_action_resolver.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_launch_state.dart';

enum BillingNavigationRouteIntentKind {
  unavailable,
  embedded,
  route,
  sheet,
  workflow,
  ignored,
}

class BillingNavigationRouteIntent {
  final BillingNavigationRouteIntentKind kind;
  final BillingNavigationAction action;
  final BillingNavigationDestination destination;
  final BillingNavigationSurface currentSurface;
  final BillingNavigationSurface targetSurface;
  final BillingBusinessDomainScreenPresentation presentation;
  final String screenKey;

  const BillingNavigationRouteIntent({
    required this.kind,
    required this.action,
    required this.destination,
    required this.currentSurface,
    required this.targetSurface,
    required this.presentation,
    required this.screenKey,
  });

  BillingNavigationDestinationId get destinationId => destination.id;

  String? get disabledReason => action.disabledReason;

  BillingDashboardNavigationAction? get dashboardAction {
    return action.dashboardAction;
  }

  BillingProductWorkspaceNavigationAction? get productWorkspaceAction {
    return action.productWorkspaceAction;
  }

  bool get isUnavailable {
    return kind == BillingNavigationRouteIntentKind.unavailable;
  }

  bool get isCrossSurface => currentSurface != targetSurface;
}

BillingNavigationRouteIntent resolveBillingNavigationRouteIntent({
  required BillingNavigationLaunchState launchState,
  required BillingNavigationSurface currentSurface,
}) {
  final action = resolveBillingNavigationAction(launchState);
  final intentKind = _resolveRouteIntentKind(
    action: action,
    presentation: launchState.presentation,
    isCrossSurface: currentSurface != launchState.surface,
  );

  return BillingNavigationRouteIntent(
    kind: intentKind,
    action: action,
    destination: launchState.destination,
    currentSurface: currentSurface,
    targetSurface: launchState.surface,
    presentation: launchState.presentation,
    screenKey: launchState.screenKey,
  );
}

BillingNavigationRouteIntentKind _resolveRouteIntentKind({
  required BillingNavigationAction action,
  required BillingBusinessDomainScreenPresentation presentation,
  required bool isCrossSurface,
}) {
  switch (action.kind) {
    case BillingNavigationActionKind.unavailable:
      return BillingNavigationRouteIntentKind.unavailable;
    case BillingNavigationActionKind.ignored:
      return BillingNavigationRouteIntentKind.ignored;
    case BillingNavigationActionKind.tenantSelection:
      return BillingNavigationRouteIntentKind.route;
    case BillingNavigationActionKind.dashboard:
    case BillingNavigationActionKind.productWorkspace:
      return _intentKindForPresentation(
        presentation,
        isCrossSurface: isCrossSurface,
      );
  }
}

BillingNavigationRouteIntentKind _intentKindForPresentation(
  BillingBusinessDomainScreenPresentation presentation, {
  required bool isCrossSurface,
}) {
  switch (presentation) {
    case BillingBusinessDomainScreenPresentation.embedded:
      return isCrossSurface
          ? BillingNavigationRouteIntentKind.route
          : BillingNavigationRouteIntentKind.embedded;
    case BillingBusinessDomainScreenPresentation.route:
      return isCrossSurface
          ? BillingNavigationRouteIntentKind.route
          : BillingNavigationRouteIntentKind.embedded;
    case BillingBusinessDomainScreenPresentation.sheet:
      return BillingNavigationRouteIntentKind.sheet;
    case BillingBusinessDomainScreenPresentation.workflow:
      return isCrossSurface
          ? BillingNavigationRouteIntentKind.route
          : BillingNavigationRouteIntentKind.workflow;
  }
}
