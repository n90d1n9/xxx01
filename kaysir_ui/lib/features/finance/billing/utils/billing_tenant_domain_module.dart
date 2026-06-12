import '../models/billing_business_domain_module.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_business_domain_modules.dart';
import 'billing_tenant_domain_profile.dart';

BillingBusinessDomainModule billingTenantBusinessDomainModule(
  BillingTenantPreferences preferences, {
  BillingBusinessDomainModuleRegistry? registry,
  String fallbackDomain = defaultBillingBusinessDomain,
}) {
  final resolvedRegistry = registry ?? standardBillingDomainModuleRegistry();
  final module = resolvedRegistry.find(
    billingTenantBusinessDomain(preferences, fallbackDomain: fallbackDomain),
  );
  if (module != null) return module;

  final fallbackModule = resolvedRegistry.find(fallbackDomain);
  if (fallbackModule != null) return fallbackModule;

  throw StateError(
    'No billing domain module is registered for '
    '${preferences.businessDomain} or fallback $fallbackDomain.',
  );
}
