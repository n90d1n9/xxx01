import 'models/billing_navigation_destination_id.dart';

/// Describes the shell surface used to render a billing management route.
enum BillingManagementRouteSurface {
  dashboard,
  productWorkspace,
  tenantSelection,
}

/// Defines a sidebar-visible billing route and its local navigation behavior.
class BillingManagementRouteDefinition {
  final String name;
  final String routeName;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String path;
  final BillingNavigationDestinationId destinationId;
  final String? routeIdentityKey;
  final BillingManagementRouteSurface surface;

  const BillingManagementRouteDefinition({
    required this.name,
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.path,
    required this.destinationId,
    this.routeIdentityKey,
    required this.surface,
  });

  /// Stable identity used by route diagnostics and extension registries.
  String get resolvedRouteIdentityKey {
    final normalizedKey = routeIdentityKey?.trim();
    if (normalizedKey != null && normalizedKey.isNotEmpty) {
      return normalizedKey;
    }

    return destinationId.name;
  }
}

/// Central route registry for the domain-agnostic billing management module.
class BillingRoutes {
  const BillingRoutes._();

  static const managementRouteName = 'billingManagement';
  static const workCenterRouteName = 'billingWorkCenter';
  static const workspacesRouteName = 'billingWorkspaces';
  static const invoicesRouteName = 'billingInvoices';
  static const createInvoiceRouteName = 'billingCreateInvoice';
  static const insightsRouteName = 'billingInsights';
  static const issueOutboxRouteName = 'billingIssueOutbox';
  static const policyRouteName = 'billingPolicyCenter';
  static const productsRouteName = 'billingProductsCheckout';
  static const checkoutRouteName = 'billingCartCheckout';
  static const diagnosticsRouteName = 'billingDiagnostics';

  static const managementPath = '/finance/billing';
  static const workCenterPath = '$managementPath/work-center';
  static const workspacesPath = '$managementPath/workspaces';
  static const invoicesPath = '$managementPath/invoices';
  static const createInvoicePath = '$managementPath/create-invoice';
  static const insightsPath = '$managementPath/insights';
  static const issueOutboxPath = '$managementPath/issue-outbox';
  static const policyPath = '$managementPath/policies';
  static const productsPath = '$managementPath/products';
  static const checkoutPath = '$managementPath/checkout';
  static const diagnosticsPath = '$managementPath/diagnostics';
  static const tenantQueryKey = 'tenant';
  static const businessDomainQueryKey = 'domain';

  static const managementTitle = 'Billing Management';
  static const managementSubtitle = 'Revenue operations';
  static const managementDescription =
      'Domain-agnostic billing system for invoices, tenants, product billing, checkout, collections, diagnostics, and release readiness across commerce, construction, digital subscription, service, and custom business models.';

  static const sidebarRoutes = <BillingManagementRouteDefinition>[
    BillingManagementRouteDefinition(
      name: 'Billing Dashboard',
      routeName: managementRouteName,
      title: 'Dashboard',
      subtitle: 'Revenue overview',
      description:
          'Open the billing dashboard for balances, insights, invoice activity, and tenant-aware operations.',
      icon: 'billing-dashboard',
      path: managementPath,
      destinationId: BillingNavigationDestinationId.dashboard,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Workspaces',
      routeName: workspacesRouteName,
      title: 'Billing Workspaces',
      subtitle: 'Tenant selection',
      description:
          'Choose the tenant or business workspace before opening tenant-scoped billing workflows.',
      icon: 'billing-workspaces',
      path: workspacesPath,
      destinationId: BillingNavigationDestinationId.tenants,
      surface: BillingManagementRouteSurface.tenantSelection,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Work Center',
      routeName: workCenterRouteName,
      title: 'Work Center',
      subtitle: 'Follow-up queue',
      description:
          'Open the unified billing work center for collection, exception, subscription, milestone, and external follow-up queues.',
      icon: 'billing-work-center',
      path: workCenterPath,
      destinationId: BillingNavigationDestinationId.workCenter,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Invoices',
      routeName: invoicesRouteName,
      title: 'Billing Invoices',
      subtitle: 'Receivables browser',
      description:
          'Browse, filter, inspect, and act on invoices for the selected billing workspace.',
      icon: 'billing-invoices',
      path: invoicesPath,
      destinationId: BillingNavigationDestinationId.invoices,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Create Billing Invoice',
      routeName: createInvoiceRouteName,
      title: 'Create Invoice',
      subtitle: 'Issue draft',
      description:
          'Open the reusable invoice creation workflow with tenant-aware tax, term, and schedule policies.',
      icon: 'billing-create-invoice',
      path: createInvoicePath,
      destinationId: BillingNavigationDestinationId.createInvoice,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Insights',
      routeName: insightsRouteName,
      title: 'Billing Insights',
      subtitle: 'Cash and collections',
      description:
          'Review billing reports, cash forecasts, collection tasks, aging buckets, and attention signals.',
      icon: 'billing-insights',
      path: insightsPath,
      destinationId: BillingNavigationDestinationId.reports,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Issue Outbox',
      routeName: issueOutboxRouteName,
      title: 'Issue Outbox',
      subtitle: 'Retry and audit',
      description:
          'Monitor invoice issue commands, retry readiness, saved views, sync health, and audit details.',
      icon: 'billing-outbox',
      path: issueOutboxPath,
      destinationId: BillingNavigationDestinationId.issueOutbox,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Policy Center',
      routeName: policyRouteName,
      title: 'Policy Center',
      subtitle: 'Capabilities and exceptions',
      description:
          'Configure split billing, force majeure relief, exception handling, dunning controls, and approval gates.',
      icon: 'billing-policy',
      path: policyPath,
      destinationId: BillingNavigationDestinationId.policyCenter,
      surface: BillingManagementRouteSurface.dashboard,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Products Checkout',
      routeName: productsRouteName,
      title: 'Products & Checkout',
      subtitle: 'Catalog billing',
      description:
          'Open product billing, catalog selection, cart, and checkout workflows for tenant billing products.',
      icon: 'billing-products',
      path: productsPath,
      destinationId: BillingNavigationDestinationId.productWorkspace,
      surface: BillingManagementRouteSurface.productWorkspace,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Cart Checkout',
      routeName: checkoutRouteName,
      title: 'Cart Checkout',
      subtitle: 'Collect payment',
      description:
          'Open the checkout workflow directly for cart review, tendering, and payment receipt generation.',
      icon: 'billing-checkout',
      path: checkoutPath,
      destinationId: BillingNavigationDestinationId.cartCheckout,
      surface: BillingManagementRouteSurface.productWorkspace,
    ),
    BillingManagementRouteDefinition(
      name: 'Billing Diagnostics',
      routeName: diagnosticsRouteName,
      title: 'Billing Diagnostics',
      subtitle: 'System readiness',
      description:
          'Audit domain modules, domain packs, route coverage, release readiness, remediation, and launch health.',
      icon: 'billing-diagnostics',
      path: diagnosticsPath,
      destinationId: BillingNavigationDestinationId.diagnostics,
      surface: BillingManagementRouteSurface.dashboard,
    ),
  ];
}
