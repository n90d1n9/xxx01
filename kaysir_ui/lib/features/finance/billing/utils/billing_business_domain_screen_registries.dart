import '../models/billing_business_domain_screen_registry.dart';
import '../models/billing_navigation_destination_id.dart';

BillingBusinessDomainScreenRegistry commerceBillingDomainScreenRegistry({
  Iterable<BillingNavigationDestinationId> hiddenDestinationIds = const [],
  Iterable<BillingBusinessDomainScreenDescriptor> extensions = const [],
}) {
  return standardBillingDomainScreenRegistry()
      .extend(extensions: _commerceProductWorkspaceScreens)
      .extend(
        hiddenDestinationIds: hiddenDestinationIds,
        extensions: extensions,
      );
}

BillingBusinessDomainScreenRegistry constructionBillingDomainScreenRegistry({
  Iterable<BillingNavigationDestinationId> hiddenDestinationIds = const [],
  Iterable<BillingBusinessDomainScreenDescriptor> extensions = const [],
}) {
  return standardBillingDomainScreenRegistry(
    hiddenDestinationIds: hiddenDestinationIds,
    extensions: extensions,
  );
}

BillingBusinessDomainScreenRegistry
digitalSubscriptionBillingDomainScreenRegistry({
  Iterable<BillingNavigationDestinationId> hiddenDestinationIds = const [],
  Iterable<BillingBusinessDomainScreenDescriptor> extensions = const [],
}) {
  return standardBillingDomainScreenRegistry(
    hiddenDestinationIds: hiddenDestinationIds,
    extensions: extensions,
  );
}

BillingBusinessDomainScreenRegistry standardBillingDomainScreenRegistry({
  Iterable<BillingNavigationDestinationId> hiddenDestinationIds = const [],
  Iterable<BillingBusinessDomainScreenDescriptor> extensions = const [],
}) {
  return BillingBusinessDomainScreenRegistry(
    screens: const [
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.dashboard,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.dashboard',
        requiresTenant: false,
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.tenants,
        surface: BillingNavigationSurface.tenantSelection,
        key: 'core.tenant_selection',
        requiresTenant: false,
        presentation: BillingBusinessDomainScreenPresentation.route,
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.workCenter,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.work_center',
        presentation: BillingBusinessDomainScreenPresentation.route,
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.invoices,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.invoices',
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.createInvoice,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.create_invoice',
        presentation: BillingBusinessDomainScreenPresentation.sheet,
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.reports,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.reports',
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.issueOutbox,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.issue_outbox',
        presentation: BillingBusinessDomainScreenPresentation.sheet,
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.diagnostics,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.diagnostics',
        requiresTenant: false,
      ),
      BillingBusinessDomainScreenDescriptor(
        destinationId: BillingNavigationDestinationId.policyCenter,
        surface: BillingNavigationSurface.dashboard,
        key: 'core.policy_center',
        requiresTenant: false,
        presentation: BillingBusinessDomainScreenPresentation.route,
      ),
    ],
  ).extend(hiddenDestinationIds: hiddenDestinationIds, extensions: extensions);
}

const _commerceProductWorkspaceScreens = [
  BillingBusinessDomainScreenDescriptor(
    destinationId: BillingNavigationDestinationId.productWorkspace,
    surface: BillingNavigationSurface.productWorkspace,
    key: 'commerce.product_workspace',
    presentation: BillingBusinessDomainScreenPresentation.route,
  ),
  BillingBusinessDomainScreenDescriptor(
    destinationId: BillingNavigationDestinationId.cartCheckout,
    surface: BillingNavigationSurface.productWorkspace,
    key: 'commerce.cart_checkout',
    presentation: BillingBusinessDomainScreenPresentation.workflow,
  ),
];
