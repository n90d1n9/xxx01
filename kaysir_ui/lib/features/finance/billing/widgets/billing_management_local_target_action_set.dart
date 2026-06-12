import 'billing_management_local_target_controller.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_local_target.dart';

class BillingManagementLocalTargetActionSet {
  final BillingNavigationSurface surface;
  final BillingManagementLocalTargetController _controller;
  final Set<BillingNavigationLocalTargetKind> supportedTargetKinds;

  BillingManagementLocalTargetActionSet._({
    required this.surface,
    required BillingManagementLocalTargetController controller,
    required Iterable<BillingNavigationLocalTargetKind> supportedTargetKinds,
  }) : _controller = controller,
       supportedTargetKinds = Set.unmodifiable(supportedTargetKinds);

  factory BillingManagementLocalTargetActionSet.dashboard({
    BillingManagementLocalTargetHandler? onDashboardOverview,
    BillingManagementLocalTargetHandler? onDashboardWorkCenter,
    BillingManagementLocalTargetHandler? onDashboardInvoices,
    BillingManagementLocalTargetHandler? onDashboardCreateInvoice,
    BillingManagementLocalTargetHandler? onDashboardReports,
    BillingManagementLocalTargetHandler? onDashboardIssueOutbox,
    BillingManagementLocalTargetHandler? onDashboardPolicyCenter,
    BillingManagementLocalTargetHandler? onDashboardDiagnostics,
  }) {
    return BillingManagementLocalTargetActionSet._(
      surface: BillingNavigationSurface.dashboard,
      controller: BillingManagementLocalTargetController(
        onDashboardOverview: onDashboardOverview,
        onDashboardWorkCenter: onDashboardWorkCenter,
        onDashboardInvoices: onDashboardInvoices,
        onDashboardCreateInvoice: onDashboardCreateInvoice,
        onDashboardReports: onDashboardReports,
        onDashboardIssueOutbox: onDashboardIssueOutbox,
        onDashboardPolicyCenter: onDashboardPolicyCenter,
        onDashboardDiagnostics: onDashboardDiagnostics,
      ),
      supportedTargetKinds: _registeredTargetKinds({
        BillingNavigationLocalTargetKind.dashboardOverview: onDashboardOverview,
        BillingNavigationLocalTargetKind.dashboardWorkCenter:
            onDashboardWorkCenter,
        BillingNavigationLocalTargetKind.dashboardInvoices: onDashboardInvoices,
        BillingNavigationLocalTargetKind.dashboardCreateInvoice:
            onDashboardCreateInvoice,
        BillingNavigationLocalTargetKind.dashboardReports: onDashboardReports,
        BillingNavigationLocalTargetKind.dashboardIssueOutbox:
            onDashboardIssueOutbox,
        BillingNavigationLocalTargetKind.dashboardPolicyCenter:
            onDashboardPolicyCenter,
        BillingNavigationLocalTargetKind.dashboardDiagnostics:
            onDashboardDiagnostics,
      }),
    );
  }

  factory BillingManagementLocalTargetActionSet.productWorkspace({
    BillingManagementLocalTargetHandler? onDashboardCreateInvoice,
    BillingManagementLocalTargetHandler? onDashboardIssueOutbox,
    BillingManagementLocalTargetHandler? onProductCatalog,
    BillingManagementLocalTargetHandler? onCartCheckout,
  }) {
    return BillingManagementLocalTargetActionSet._(
      surface: BillingNavigationSurface.productWorkspace,
      controller: BillingManagementLocalTargetController(
        onDashboardCreateInvoice: onDashboardCreateInvoice,
        onDashboardIssueOutbox: onDashboardIssueOutbox,
        onProductCatalog: onProductCatalog,
        onCartCheckout: onCartCheckout,
      ),
      supportedTargetKinds: _registeredTargetKinds({
        BillingNavigationLocalTargetKind.dashboardCreateInvoice:
            onDashboardCreateInvoice,
        BillingNavigationLocalTargetKind.dashboardIssueOutbox:
            onDashboardIssueOutbox,
        BillingNavigationLocalTargetKind.productCatalog: onProductCatalog,
        BillingNavigationLocalTargetKind.cartCheckout: onCartCheckout,
      }),
    );
  }

  bool get hasHandlers => supportedTargetKinds.isNotEmpty;

  bool supports(BillingNavigationLocalTarget localTarget) {
    return supportsKind(localTarget.kind);
  }

  bool supportsKind(BillingNavigationLocalTargetKind kind) {
    return supportedTargetKinds.contains(kind);
  }

  BillingManagementLocalTargetResult handle(
    BillingNavigationLocalTarget localTarget,
  ) {
    return _controller.handle(localTarget);
  }

  bool handleTarget(BillingNavigationLocalTarget localTarget) {
    return handle(localTarget).handled;
  }
}

Iterable<BillingNavigationLocalTargetKind> _registeredTargetKinds(
  Map<BillingNavigationLocalTargetKind, BillingManagementLocalTargetHandler?>
  handlers,
) {
  return handlers.entries
      .where((entry) => entry.value != null)
      .map((entry) => entry.key);
}
