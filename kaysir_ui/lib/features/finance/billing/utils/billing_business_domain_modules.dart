import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_navigation_policy.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_business_domain_screen_registry.dart';
import '../models/billing_invoice_tax_mode.dart';
import 'billing_business_domain_navigation_policies.dart';
import 'billing_business_domain_profiles.dart';
import 'billing_business_domain_screen_registries.dart';
import 'billing_cart_invoice_line_items.dart';
import 'billing_invoice_issue_policies.dart';

BillingBusinessDomainModule commerceBillingDomainModule({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
  BillingBusinessDomainScreenRegistry? screenRegistry,
}) {
  final profile = commerceBillingDomainProfile(
    taxRate: taxRate,
    taxMode: taxMode,
  );
  final resolvedScreenRegistry =
      screenRegistry ?? commerceBillingDomainScreenRegistry();
  final navigationPolicy = commerceBillingDomainNavigationPolicy()
      .constrainedTo(resolvedScreenRegistry.destinationIds);

  return BillingBusinessDomainModule(
    profile: profile,
    lineItemAdapters: [billingCartLineItemAdapter(profile: profile)],
    issuePolicy: billingInvoiceIssuePolicyForProfile(profile),
    navigationPolicy: navigationPolicy,
    screenRegistry: resolvedScreenRegistry,
  );
}

BillingBusinessDomainModule constructionBillingDomainModule({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
  BillingBusinessDomainScreenRegistry? screenRegistry,
}) {
  final profile = constructionBillingDomainProfile(
    taxRate: taxRate,
    taxMode: taxMode,
  );
  final resolvedScreenRegistry =
      screenRegistry ?? constructionBillingDomainScreenRegistry();
  final navigationPolicy = constructionBillingDomainNavigationPolicy()
      .constrainedTo(resolvedScreenRegistry.destinationIds);

  return BillingBusinessDomainModule(
    profile: profile,
    issuePolicy: billingInvoiceIssuePolicyForProfile(profile),
    navigationPolicy: navigationPolicy,
    screenRegistry: resolvedScreenRegistry,
  );
}

BillingBusinessDomainModule digitalSubscriptionBillingDomainModule({
  double taxRate = 0,
  BillingInvoiceTaxMode taxMode = BillingInvoiceTaxMode.exclusive,
  BillingBusinessDomainScreenRegistry? screenRegistry,
}) {
  final profile = digitalSubscriptionBillingDomainProfile(
    taxRate: taxRate,
    taxMode: taxMode,
  );
  final resolvedScreenRegistry =
      screenRegistry ?? digitalSubscriptionBillingDomainScreenRegistry();
  final navigationPolicy = digitalSubscriptionBillingDomainNavigationPolicy()
      .constrainedTo(resolvedScreenRegistry.destinationIds);

  return BillingBusinessDomainModule(
    profile: profile,
    issuePolicy: billingInvoiceIssuePolicyForProfile(profile),
    navigationPolicy: navigationPolicy,
    screenRegistry: resolvedScreenRegistry,
  );
}

BillingBusinessDomainModule profileOnlyBillingDomainModule(
  BillingBusinessDomainProfile profile, {
  BillingBusinessDomainNavigationPolicy? navigationPolicy,
  BillingBusinessDomainScreenRegistry? screenRegistry,
}) {
  return BillingBusinessDomainModule(
    profile: profile,
    issuePolicy: billingInvoiceIssuePolicyForProfile(profile),
    navigationPolicy: navigationPolicy,
    screenRegistry: screenRegistry,
  );
}

BillingBusinessDomainModuleRegistry standardBillingDomainModuleRegistry({
  Iterable<BillingBusinessDomainModule> additionalModules = const [],
}) {
  return BillingBusinessDomainModuleRegistry(
    modules: [
      commerceBillingDomainModule(),
      constructionBillingDomainModule(),
      digitalSubscriptionBillingDomainModule(),
      ...additionalModules,
    ],
  );
}
