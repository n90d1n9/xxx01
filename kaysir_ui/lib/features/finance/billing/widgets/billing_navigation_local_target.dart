import 'billing_navigation_action_resolver.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_route_intent.dart';
import 'billing_navigation_route_target.dart';

enum BillingNavigationLocalTargetKind {
  none,
  dashboardOverview,
  dashboardWorkCenter,
  dashboardInvoices,
  dashboardCreateInvoice,
  dashboardReports,
  dashboardIssueOutbox,
  dashboardPolicyCenter,
  dashboardDiagnostics,
  productCatalog,
  cartCheckout,
}

class BillingNavigationLocalTarget {
  final BillingNavigationLocalTargetKind kind;
  final BillingNavigationDestinationId? destinationId;
  final BillingNavigationRouteIntentKind? intentKind;
  final String? screenKey;

  const BillingNavigationLocalTarget.none()
    : kind = BillingNavigationLocalTargetKind.none,
      destinationId = null,
      intentKind = null,
      screenKey = null;

  const BillingNavigationLocalTarget.dashboard({
    required this.kind,
    required this.destinationId,
    required this.intentKind,
    required this.screenKey,
  }) : assert(
         kind == BillingNavigationLocalTargetKind.dashboardOverview ||
             kind == BillingNavigationLocalTargetKind.dashboardWorkCenter ||
             kind == BillingNavigationLocalTargetKind.dashboardInvoices ||
             kind == BillingNavigationLocalTargetKind.dashboardCreateInvoice ||
             kind == BillingNavigationLocalTargetKind.dashboardReports ||
             kind == BillingNavigationLocalTargetKind.dashboardIssueOutbox ||
             kind == BillingNavigationLocalTargetKind.dashboardPolicyCenter ||
             kind == BillingNavigationLocalTargetKind.dashboardDiagnostics,
       );

  const BillingNavigationLocalTarget.productWorkspace({
    required this.kind,
    required this.destinationId,
    required this.intentKind,
    required this.screenKey,
  }) : assert(
         kind == BillingNavigationLocalTargetKind.productCatalog ||
             kind == BillingNavigationLocalTargetKind.cartCheckout,
       );

  bool get isNone => kind == BillingNavigationLocalTargetKind.none;

  bool get opensSheet {
    return kind == BillingNavigationLocalTargetKind.dashboardCreateInvoice ||
        kind == BillingNavigationLocalTargetKind.dashboardIssueOutbox;
  }

  bool get opensWorkflow {
    return kind == BillingNavigationLocalTargetKind.cartCheckout;
  }
}

BillingNavigationLocalTarget resolveBillingNavigationLocalTarget(
  BillingNavigationRouteIntent routeIntent,
) {
  switch (routeIntent.kind) {
    case BillingNavigationRouteIntentKind.embedded:
    case BillingNavigationRouteIntentKind.sheet:
    case BillingNavigationRouteIntentKind.workflow:
      return _resolveLocalActionTarget(routeIntent);
    case BillingNavigationRouteIntentKind.unavailable:
    case BillingNavigationRouteIntentKind.route:
    case BillingNavigationRouteIntentKind.ignored:
      return const BillingNavigationLocalTarget.none();
  }
}

BillingNavigationLocalTarget _resolveLocalActionTarget(
  BillingNavigationRouteIntent routeIntent,
) {
  switch (routeIntent.action.kind) {
    case BillingNavigationActionKind.dashboard:
      final action = routeIntent.dashboardAction;
      if (action == null) return const BillingNavigationLocalTarget.none();

      return billingDashboardLocalTargetFor(
        action,
        intentKind: routeIntent.kind,
        screenKey: routeIntent.screenKey,
      );
    case BillingNavigationActionKind.productWorkspace:
      final action = routeIntent.productWorkspaceAction;
      if (action == null) return const BillingNavigationLocalTarget.none();

      return billingProductWorkspaceLocalTargetFor(
        action,
        intentKind: routeIntent.kind,
        screenKey: routeIntent.screenKey,
      );
    case BillingNavigationActionKind.unavailable:
    case BillingNavigationActionKind.tenantSelection:
    case BillingNavigationActionKind.ignored:
      return const BillingNavigationLocalTarget.none();
  }
}

BillingNavigationLocalTarget billingDashboardLocalTargetFor(
  BillingDashboardNavigationAction action, {
  required BillingNavigationRouteIntentKind intentKind,
  required String screenKey,
}) {
  switch (action) {
    case BillingDashboardNavigationAction.overview:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardOverview,
        destinationId: BillingNavigationDestinationId.dashboard,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.workCenter:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardWorkCenter,
        destinationId: BillingNavigationDestinationId.workCenter,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.invoices:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardInvoices,
        destinationId: BillingNavigationDestinationId.invoices,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.createInvoice:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardCreateInvoice,
        destinationId: BillingNavigationDestinationId.createInvoice,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.reports:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardReports,
        destinationId: BillingNavigationDestinationId.reports,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.issueOutbox:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardIssueOutbox,
        destinationId: BillingNavigationDestinationId.issueOutbox,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.policyCenter:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardPolicyCenter,
        destinationId: BillingNavigationDestinationId.policyCenter,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingDashboardNavigationAction.diagnostics:
      return BillingNavigationLocalTarget.dashboard(
        kind: BillingNavigationLocalTargetKind.dashboardDiagnostics,
        destinationId: BillingNavigationDestinationId.diagnostics,
        intentKind: intentKind,
        screenKey: screenKey,
      );
  }
}

BillingNavigationLocalTarget billingProductWorkspaceLocalTargetFor(
  BillingProductWorkspaceNavigationAction action, {
  required BillingNavigationRouteIntentKind intentKind,
  required String screenKey,
}) {
  switch (action) {
    case BillingProductWorkspaceNavigationAction.catalog:
      return BillingNavigationLocalTarget.productWorkspace(
        kind: BillingNavigationLocalTargetKind.productCatalog,
        destinationId: BillingNavigationDestinationId.productWorkspace,
        intentKind: intentKind,
        screenKey: screenKey,
      );
    case BillingProductWorkspaceNavigationAction.cartCheckout:
      return BillingNavigationLocalTarget.productWorkspace(
        kind: BillingNavigationLocalTargetKind.cartCheckout,
        destinationId: BillingNavigationDestinationId.cartCheckout,
        intentKind: intentKind,
        screenKey: screenKey,
      );
  }
}

BillingNavigationLocalTarget billingLocalTargetForRouteTarget(
  BillingNavigationRouteTarget routeTarget, {
  String? fallbackScreenKey,
}) {
  final initialDestinationId = routeTarget.initialDestinationId;
  if (initialDestinationId == null) {
    return const BillingNavigationLocalTarget.none();
  }

  final routeScreenKey = routeTarget.screenKey;
  final screenKey =
      routeScreenKey?.trim().isNotEmpty == true
          ? routeScreenKey!
          : fallbackScreenKey;
  if (screenKey == null || screenKey.trim().isEmpty) {
    return const BillingNavigationLocalTarget.none();
  }

  switch (routeTarget.kind) {
    case BillingNavigationRouteTargetKind.dashboard:
      final action = billingDashboardNavigationActionFor(initialDestinationId);
      if (action == null) return const BillingNavigationLocalTarget.none();

      return billingDashboardLocalTargetFor(
        action,
        intentKind: BillingNavigationRouteIntentKind.route,
        screenKey: screenKey,
      );
    case BillingNavigationRouteTargetKind.productWorkspace:
      final action = billingProductWorkspaceNavigationActionFor(
        initialDestinationId,
      );
      if (action == null) return const BillingNavigationLocalTarget.none();

      return billingProductWorkspaceLocalTargetFor(
        action,
        intentKind: BillingNavigationRouteIntentKind.route,
        screenKey: screenKey,
      );
    case BillingNavigationRouteTargetKind.none:
    case BillingNavigationRouteTargetKind.tenantSelection:
      return const BillingNavigationLocalTarget.none();
  }
}
