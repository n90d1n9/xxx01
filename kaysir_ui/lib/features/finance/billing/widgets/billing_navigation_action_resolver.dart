import 'billing_navigation_destination.dart';
import 'billing_navigation_launch_state.dart';

enum BillingNavigationActionKind {
  unavailable,
  dashboard,
  productWorkspace,
  tenantSelection,
  ignored,
}

enum BillingDashboardNavigationAction {
  overview,
  workCenter,
  invoices,
  createInvoice,
  reports,
  issueOutbox,
  policyCenter,
  diagnostics,
}

enum BillingProductWorkspaceNavigationAction { catalog, cartCheckout }

class BillingNavigationAction {
  final BillingNavigationActionKind kind;
  final BillingNavigationDestinationId destinationId;
  final String? disabledReason;
  final BillingDashboardNavigationAction? dashboardAction;
  final BillingProductWorkspaceNavigationAction? productWorkspaceAction;

  const BillingNavigationAction._({
    required this.kind,
    required this.destinationId,
    this.disabledReason,
    this.dashboardAction,
    this.productWorkspaceAction,
  });

  const BillingNavigationAction.unavailable({
    required BillingNavigationDestinationId destinationId,
    required String disabledReason,
  }) : this._(
         kind: BillingNavigationActionKind.unavailable,
         destinationId: destinationId,
         disabledReason: disabledReason,
       );

  const BillingNavigationAction.dashboard({
    required BillingNavigationDestinationId destinationId,
    required BillingDashboardNavigationAction action,
  }) : this._(
         kind: BillingNavigationActionKind.dashboard,
         destinationId: destinationId,
         dashboardAction: action,
       );

  const BillingNavigationAction.productWorkspace({
    required BillingNavigationDestinationId destinationId,
    required BillingProductWorkspaceNavigationAction action,
  }) : this._(
         kind: BillingNavigationActionKind.productWorkspace,
         destinationId: destinationId,
         productWorkspaceAction: action,
       );

  const BillingNavigationAction.tenantSelection({
    required BillingNavigationDestinationId destinationId,
  }) : this._(
         kind: BillingNavigationActionKind.tenantSelection,
         destinationId: destinationId,
       );

  const BillingNavigationAction.ignored({
    required BillingNavigationDestinationId destinationId,
  }) : this._(
         kind: BillingNavigationActionKind.ignored,
         destinationId: destinationId,
       );

  bool get isUnavailable => kind == BillingNavigationActionKind.unavailable;
}

BillingNavigationAction resolveBillingNavigationAction(
  BillingNavigationLaunchState launchState,
) {
  final disabledReason = launchState.disabledReason;
  if (disabledReason != null) {
    return BillingNavigationAction.unavailable(
      destinationId: launchState.destinationId,
      disabledReason: disabledReason,
    );
  }

  switch (launchState.surface) {
    case BillingNavigationSurface.dashboard:
      final action = billingDashboardNavigationActionFor(
        launchState.destinationId,
      );
      if (action == null) {
        return BillingNavigationAction.ignored(
          destinationId: launchState.destinationId,
        );
      }

      return BillingNavigationAction.dashboard(
        destinationId: launchState.destinationId,
        action: action,
      );
    case BillingNavigationSurface.productWorkspace:
      final action = billingProductWorkspaceNavigationActionFor(
        launchState.destinationId,
      );
      if (action == null) {
        return BillingNavigationAction.ignored(
          destinationId: launchState.destinationId,
        );
      }

      return BillingNavigationAction.productWorkspace(
        destinationId: launchState.destinationId,
        action: action,
      );
    case BillingNavigationSurface.tenantSelection:
      return BillingNavigationAction.tenantSelection(
        destinationId: launchState.destinationId,
      );
  }
}

BillingDashboardNavigationAction? billingDashboardNavigationActionFor(
  BillingNavigationDestinationId destinationId,
) {
  switch (destinationId) {
    case BillingNavigationDestinationId.dashboard:
      return BillingDashboardNavigationAction.overview;
    case BillingNavigationDestinationId.workCenter:
      return BillingDashboardNavigationAction.workCenter;
    case BillingNavigationDestinationId.invoices:
      return BillingDashboardNavigationAction.invoices;
    case BillingNavigationDestinationId.createInvoice:
      return BillingDashboardNavigationAction.createInvoice;
    case BillingNavigationDestinationId.reports:
      return BillingDashboardNavigationAction.reports;
    case BillingNavigationDestinationId.issueOutbox:
      return BillingDashboardNavigationAction.issueOutbox;
    case BillingNavigationDestinationId.policyCenter:
      return BillingDashboardNavigationAction.policyCenter;
    case BillingNavigationDestinationId.diagnostics:
      return BillingDashboardNavigationAction.diagnostics;
    case BillingNavigationDestinationId.productWorkspace:
    case BillingNavigationDestinationId.cartCheckout:
    case BillingNavigationDestinationId.tenants:
      return null;
  }
}

BillingProductWorkspaceNavigationAction?
billingProductWorkspaceNavigationActionFor(
  BillingNavigationDestinationId destinationId,
) {
  switch (destinationId) {
    case BillingNavigationDestinationId.productWorkspace:
      return BillingProductWorkspaceNavigationAction.catalog;
    case BillingNavigationDestinationId.cartCheckout:
      return BillingProductWorkspaceNavigationAction.cartCheckout;
    case BillingNavigationDestinationId.dashboard:
    case BillingNavigationDestinationId.workCenter:
    case BillingNavigationDestinationId.tenants:
    case BillingNavigationDestinationId.invoices:
    case BillingNavigationDestinationId.createInvoice:
    case BillingNavigationDestinationId.reports:
    case BillingNavigationDestinationId.issueOutbox:
    case BillingNavigationDestinationId.policyCenter:
    case BillingNavigationDestinationId.diagnostics:
      return null;
  }
}

BillingNavigationDestinationId billingDestinationForDashboardNavigationAction(
  BillingDashboardNavigationAction action,
) {
  switch (action) {
    case BillingDashboardNavigationAction.overview:
      return BillingNavigationDestinationId.dashboard;
    case BillingDashboardNavigationAction.workCenter:
      return BillingNavigationDestinationId.workCenter;
    case BillingDashboardNavigationAction.invoices:
      return BillingNavigationDestinationId.invoices;
    case BillingDashboardNavigationAction.createInvoice:
      return BillingNavigationDestinationId.createInvoice;
    case BillingDashboardNavigationAction.reports:
      return BillingNavigationDestinationId.reports;
    case BillingDashboardNavigationAction.issueOutbox:
      return BillingNavigationDestinationId.issueOutbox;
    case BillingDashboardNavigationAction.policyCenter:
      return BillingNavigationDestinationId.policyCenter;
    case BillingDashboardNavigationAction.diagnostics:
      return BillingNavigationDestinationId.diagnostics;
  }
}
