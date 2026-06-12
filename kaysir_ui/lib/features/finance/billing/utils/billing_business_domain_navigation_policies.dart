import '../models/billing_business_domain_navigation_policy.dart';
import '../widgets/billing_navigation_destination.dart';

BillingBusinessDomainNavigationPolicy commerceBillingDomainNavigationPolicy() {
  return BillingBusinessDomainNavigationPolicy(
    destinationIds: const [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.workCenter,
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.cartCheckout,
      BillingNavigationDestinationId.tenants,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
      BillingNavigationDestinationId.policyCenter,
      BillingNavigationDestinationId.diagnostics,
    ],
    quickActionIds: const [
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.cartCheckout,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
      BillingNavigationDestinationId.tenants,
    ],
    defaultDestinationId: BillingNavigationDestinationId.productWorkspace,
  );
}

BillingBusinessDomainNavigationPolicy
constructionBillingDomainNavigationPolicy() {
  return BillingBusinessDomainNavigationPolicy(
    destinationIds: const [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.workCenter,
      BillingNavigationDestinationId.tenants,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
      BillingNavigationDestinationId.policyCenter,
      BillingNavigationDestinationId.diagnostics,
    ],
    quickActionIds: const [
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
      BillingNavigationDestinationId.tenants,
    ],
    defaultDestinationId: BillingNavigationDestinationId.dashboard,
  );
}

BillingBusinessDomainNavigationPolicy
digitalSubscriptionBillingDomainNavigationPolicy() {
  return BillingBusinessDomainNavigationPolicy(
    destinationIds: const [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.workCenter,
      BillingNavigationDestinationId.tenants,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
      BillingNavigationDestinationId.policyCenter,
      BillingNavigationDestinationId.diagnostics,
    ],
    quickActionIds: const [
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.invoices,
      BillingNavigationDestinationId.reports,
      BillingNavigationDestinationId.issueOutbox,
      BillingNavigationDestinationId.tenants,
    ],
    defaultDestinationId: BillingNavigationDestinationId.dashboard,
  );
}
