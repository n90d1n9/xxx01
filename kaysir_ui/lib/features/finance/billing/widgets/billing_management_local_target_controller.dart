import 'billing_navigation_local_target.dart';

typedef BillingManagementLocalTargetHandler =
    bool Function(BillingNavigationLocalTarget localTarget);

class BillingManagementLocalTargetResult {
  final BillingNavigationLocalTargetKind kind;
  final BillingNavigationLocalTarget localTarget;
  final bool handled;

  const BillingManagementLocalTargetResult({
    required this.kind,
    required this.localTarget,
    required this.handled,
  });

  bool get wasUnhandled =>
      !handled && kind != BillingNavigationLocalTargetKind.none;
}

class BillingManagementLocalTargetController {
  final BillingManagementLocalTargetHandler? onDashboardOverview;
  final BillingManagementLocalTargetHandler? onDashboardWorkCenter;
  final BillingManagementLocalTargetHandler? onDashboardInvoices;
  final BillingManagementLocalTargetHandler? onDashboardCreateInvoice;
  final BillingManagementLocalTargetHandler? onDashboardReports;
  final BillingManagementLocalTargetHandler? onDashboardIssueOutbox;
  final BillingManagementLocalTargetHandler? onDashboardPolicyCenter;
  final BillingManagementLocalTargetHandler? onDashboardDiagnostics;
  final BillingManagementLocalTargetHandler? onProductCatalog;
  final BillingManagementLocalTargetHandler? onCartCheckout;

  const BillingManagementLocalTargetController({
    this.onDashboardOverview,
    this.onDashboardWorkCenter,
    this.onDashboardInvoices,
    this.onDashboardCreateInvoice,
    this.onDashboardReports,
    this.onDashboardIssueOutbox,
    this.onDashboardPolicyCenter,
    this.onDashboardDiagnostics,
    this.onProductCatalog,
    this.onCartCheckout,
  });

  BillingManagementLocalTargetResult handle(
    BillingNavigationLocalTarget localTarget,
  ) {
    final handler = switch (localTarget.kind) {
      BillingNavigationLocalTargetKind.dashboardOverview => onDashboardOverview,
      BillingNavigationLocalTargetKind.dashboardWorkCenter =>
        onDashboardWorkCenter,
      BillingNavigationLocalTargetKind.dashboardInvoices => onDashboardInvoices,
      BillingNavigationLocalTargetKind.dashboardCreateInvoice =>
        onDashboardCreateInvoice,
      BillingNavigationLocalTargetKind.dashboardReports => onDashboardReports,
      BillingNavigationLocalTargetKind.dashboardIssueOutbox =>
        onDashboardIssueOutbox,
      BillingNavigationLocalTargetKind.dashboardPolicyCenter =>
        onDashboardPolicyCenter,
      BillingNavigationLocalTargetKind.dashboardDiagnostics =>
        onDashboardDiagnostics,
      BillingNavigationLocalTargetKind.productCatalog => onProductCatalog,
      BillingNavigationLocalTargetKind.cartCheckout => onCartCheckout,
      BillingNavigationLocalTargetKind.none => null,
    };

    return BillingManagementLocalTargetResult(
      kind: localTarget.kind,
      localTarget: localTarget,
      handled: handler?.call(localTarget) ?? false,
    );
  }
}
