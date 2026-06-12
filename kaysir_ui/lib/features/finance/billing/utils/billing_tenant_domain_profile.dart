import '../models/billing_business_domain_profile.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_business_domain_profiles.dart';

const defaultBillingBusinessDomain = 'commerce';

String billingTenantBusinessDomain(
  BillingTenantPreferences preferences, {
  String fallbackDomain = defaultBillingBusinessDomain,
}) {
  final domain = preferences.businessDomain.trim();
  return billingBusinessDomainKey(domain.isEmpty ? fallbackDomain : domain);
}

BillingBusinessDomainProfile billingTenantBusinessDomainProfile(
  BillingTenantPreferences preferences, {
  BillingBusinessDomainProfileRegistry? registry,
  String fallbackDomain = defaultBillingBusinessDomain,
}) {
  final resolvedRegistry = registry ?? standardBillingDomainProfileRegistry();
  final profile = resolvedRegistry.find(
    billingTenantBusinessDomain(preferences, fallbackDomain: fallbackDomain),
  );
  if (profile != null) return profile;

  final fallbackProfile = resolvedRegistry.find(fallbackDomain);
  if (fallbackProfile != null) return fallbackProfile;

  throw StateError(
    'No billing domain profile is registered for '
    '${preferences.businessDomain} or fallback $fallbackDomain.',
  );
}
