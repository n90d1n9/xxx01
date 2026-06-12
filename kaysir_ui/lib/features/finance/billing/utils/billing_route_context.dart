import '../models/billing_business_domain_profile.dart';
import '../models/billing_tenant.dart';
import '../models/billing_tenant_account.dart';
import '../models/billing_tenant_preferences.dart';

class BillingRouteContext {
  static const empty = BillingRouteContext._();

  final String? tenantId;
  final String? businessDomain;

  const BillingRouteContext._({this.tenantId, this.businessDomain});

  factory BillingRouteContext({String? tenantId, String? businessDomain}) {
    return BillingRouteContext._(
      tenantId: normalizeBillingRouteTenantId(tenantId),
      businessDomain: normalizeBillingRouteBusinessDomain(businessDomain),
    );
  }

  factory BillingRouteContext.fromTenant(Tenant tenant) {
    return BillingRouteContext(
      tenantId: tenant.id,
      businessDomain: tenant.preferences.businessDomain,
    );
  }

  factory BillingRouteContext.fromTenantAccount(BillingTenantAccount tenant) {
    return BillingRouteContext(
      tenantId: tenant.id,
      businessDomain: tenant.preferences.businessDomain,
    );
  }

  factory BillingRouteContext.fromQueryParameters(
    Map<String, String> queryParameters, {
    required String tenantQueryKey,
    required String businessDomainQueryKey,
  }) {
    return BillingRouteContext(
      tenantId: queryParameters[tenantQueryKey],
      businessDomain: queryParameters[businessDomainQueryKey],
    );
  }

  bool get isEmpty => tenantId == null && businessDomain == null;

  bool get isNotEmpty => !isEmpty;

  Map<String, String> toQueryParameters({
    required String tenantQueryKey,
    required String businessDomainQueryKey,
  }) {
    return Map.unmodifiable({
      if (tenantId != null) tenantQueryKey: tenantId!,
      if (businessDomain != null) businessDomainQueryKey: businessDomain!,
    });
  }

  BillingRouteContext merge({
    String? tenantId,
    String? businessDomain,
    BillingRouteContext? routeContext,
  }) {
    final normalizedTenantId = normalizeBillingRouteTenantId(tenantId);
    final normalizedBusinessDomain = normalizeBillingRouteBusinessDomain(
      businessDomain,
    );
    return BillingRouteContext._(
      tenantId: normalizedTenantId ?? routeContext?.tenantId ?? this.tenantId,
      businessDomain:
          normalizedBusinessDomain ??
          routeContext?.businessDomain ??
          this.businessDomain,
    );
  }

  BillingTenantPreferences applyToPreferences(
    BillingTenantPreferences preferences,
  ) {
    return billingPreferencesWithRouteDomain(
      preferences,
      businessDomain: businessDomain,
    );
  }

  Tenant applyToTenant(Tenant tenant) {
    return billingTenantWithRouteContext(
      tenant,
      businessDomain: businessDomain,
    );
  }

  BillingTenantAccount applyToTenantAccount(BillingTenantAccount tenant) {
    return billingTenantAccountWithRouteContext(
      tenant,
      businessDomain: businessDomain,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingRouteContext &&
            other.tenantId == tenantId &&
            other.businessDomain == businessDomain;
  }

  @override
  int get hashCode => Object.hash(tenantId, businessDomain);
}

String? normalizeBillingRouteTenantId(String? tenantId) {
  final normalized = tenantId?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? normalizeBillingRouteBusinessDomain(String? businessDomain) {
  final normalized = businessDomain?.trim();
  return normalized == null || normalized.isEmpty
      ? null
      : billingBusinessDomainKey(normalized);
}

BillingTenantPreferences billingPreferencesWithRouteDomain(
  BillingTenantPreferences preferences, {
  String? businessDomain,
}) {
  final normalizedDomain = normalizeBillingRouteBusinessDomain(businessDomain);
  if (normalizedDomain == null ||
      preferences.businessDomain == normalizedDomain) {
    return preferences;
  }

  return preferences.copyWith(businessDomain: normalizedDomain);
}

Tenant billingTenantWithRouteContext(Tenant tenant, {String? businessDomain}) {
  final preferences = billingPreferencesWithRouteDomain(
    tenant.preferences,
    businessDomain: businessDomain,
  );
  if (identical(preferences, tenant.preferences)) return tenant;

  return Tenant(
    id: tenant.id,
    name: tenant.name,
    logoUrl: tenant.logoUrl,
    preferences: preferences,
  );
}

BillingTenantAccount billingTenantAccountWithRouteContext(
  BillingTenantAccount tenant, {
  String? businessDomain,
}) {
  final preferences = billingPreferencesWithRouteDomain(
    tenant.preferences,
    businessDomain: businessDomain,
  );
  if (identical(preferences, tenant.preferences)) return tenant;

  return BillingTenantAccount(
    id: tenant.id,
    name: tenant.name,
    logoUrl: tenant.logoUrl,
    planName: tenant.planName,
    currentBalance: tenant.currentBalance,
    preferences: preferences,
  );
}
