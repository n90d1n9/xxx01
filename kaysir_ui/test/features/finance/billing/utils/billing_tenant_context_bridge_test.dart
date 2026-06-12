import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_tenant_context_bridge.dart';

void main() {
  test('billingTenantFromAccount preserves checkout tenant context', () {
    const preferences = BillingTenantPreferences(
      currencySymbol: 'Rp',
      paymentTermsDays: 14,
      taxMode: BillingTaxMode.inclusive,
    );
    const account = BillingTenantAccount(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: 'acme.png',
      planName: 'Growth',
      currentBalance: 2400,
      preferences: preferences,
    );

    final tenant = billingTenantFromAccount(account);

    expect(tenant.id, account.id);
    expect(tenant.name, account.name);
    expect(tenant.logoUrl, account.logoUrl);
    expect(tenant.preferences, preferences);
  });

  test('billingTenantAccountFromTenant creates dashboard account context', () {
    const preferences = BillingTenantPreferences(
      currencySymbol: r'S$',
      paymentTermsDays: 45,
    );
    const tenant = Tenant(
      id: 'tenant-b',
      name: 'Bright Studio',
      logoUrl: 'bright.png',
      preferences: preferences,
    );

    final account = billingTenantAccountFromTenant(
      tenant,
      planName: 'Retail',
      currentBalance: 125,
    );

    expect(account.id, tenant.id);
    expect(account.name, tenant.name);
    expect(account.logoUrl, tenant.logoUrl);
    expect(account.preferences, preferences);
    expect(account.planName, 'Retail');
    expect(account.currentBalance, 125);
  });
}
