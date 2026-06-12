import '../models/billing_tenant.dart';
import '../models/billing_tenant_account.dart';

Tenant billingTenantFromAccount(BillingTenantAccount account) {
  return Tenant(
    id: account.id,
    name: account.name,
    logoUrl: account.logoUrl,
    preferences: account.preferences,
  );
}

BillingTenantAccount billingTenantAccountFromTenant(
  Tenant tenant, {
  String planName = 'Checkout',
  double currentBalance = 0,
}) {
  return BillingTenantAccount(
    id: tenant.id,
    name: tenant.name,
    logoUrl: tenant.logoUrl,
    planName: planName,
    currentBalance: currentBalance,
    preferences: tenant.preferences,
  );
}
