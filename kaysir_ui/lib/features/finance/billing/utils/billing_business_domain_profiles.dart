import '../models/billing_business_domain_profile.dart';
import '../models/billing_invoice_tax_mode.dart';

BillingBusinessDomainProfile commerceBillingDomainProfile({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
}) {
  return BillingBusinessDomainProfile(
    domain: 'commerce',
    label: 'Commerce',
    defaultSourceType: 'cart_item',
    taxRate: taxRate,
    taxMode: taxMode,
    attributes: const {'paymentScheduleStrategy': 'single_due_date'},
    capabilities: const {
      BillingBusinessDomainCapability.productCatalog,
      BillingBusinessDomainCapability.inventory,
      BillingBusinessDomainCapability.cartCheckout,
      BillingBusinessDomainCapability.omniChannel,
    },
  );
}

BillingBusinessDomainProfile constructionBillingDomainProfile({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
}) {
  return BillingBusinessDomainProfile(
    domain: 'construction',
    label: 'Construction',
    defaultSourceType: 'milestone',
    taxRate: taxRate,
    taxMode: taxMode,
    attributes: const {
      'paymentScheduleStrategy': 'split_equal',
      'paymentScheduleInstallments': '3',
    },
    capabilities: const {
      BillingBusinessDomainCapability.projectMilestones,
      BillingBusinessDomainCapability.progressBilling,
      BillingBusinessDomainCapability.servicePeriods,
      BillingBusinessDomainCapability.retainers,
    },
  );
}

BillingBusinessDomainProfile digitalSubscriptionBillingDomainProfile({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
}) {
  return BillingBusinessDomainProfile(
    domain: 'digital',
    label: 'Digital subscriptions',
    defaultSourceType: 'subscription',
    taxRate: taxRate,
    taxMode: taxMode,
    attributes: const {'paymentScheduleStrategy': 'single_due_date'},
    capabilities: const {
      BillingBusinessDomainCapability.recurringSubscriptions,
      BillingBusinessDomainCapability.meteredUsage,
      BillingBusinessDomainCapability.servicePeriods,
      BillingBusinessDomainCapability.omniChannel,
    },
  );
}

BillingBusinessDomainProfileRegistry standardBillingDomainProfileRegistry({
  Iterable<BillingBusinessDomainProfile> additionalProfiles = const [],
}) {
  return BillingBusinessDomainProfileRegistry(
    profiles: [
      commerceBillingDomainProfile(),
      constructionBillingDomainProfile(),
      digitalSubscriptionBillingDomainProfile(),
      ...additionalProfiles,
    ],
  );
}
