import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_context.dart';

void main() {
  test('normalizes route tenant and business domain values', () {
    expect(normalizeBillingRouteTenantId(' tenant-a '), 'tenant-a');
    expect(normalizeBillingRouteTenantId('   '), isNull);
    expect(
      normalizeBillingRouteBusinessDomain(' Construction '),
      'construction',
    );
    expect(normalizeBillingRouteBusinessDomain('   '), isNull);
  });

  test('builds normalized route context from query parameters', () {
    final routeContext = BillingRouteContext.fromQueryParameters(
      const {'tenant': ' tenant-a ', 'domain': ' Construction '},
      tenantQueryKey: BillingRoutes.tenantQueryKey,
      businessDomainQueryKey: BillingRoutes.businessDomainQueryKey,
    );

    expect(routeContext.tenantId, 'tenant-a');
    expect(routeContext.businessDomain, 'construction');
    expect(routeContext.isNotEmpty, isTrue);
  });

  test('builds route context from tenant models', () {
    const productTenant = Tenant(
      id: ' tenant-a ',
      name: 'Acme Corp',
      logoUrl: '',
      preferences: BillingTenantPreferences(businessDomain: ' Digital '),
    );
    const dashboardTenant = BillingTenantAccount(
      id: ' tenant-b ',
      name: 'Globex',
      logoUrl: '',
      planName: 'Professional',
      currentBalance: 2400,
      preferences: BillingTenantPreferences(businessDomain: ' Construction '),
    );

    expect(BillingRouteContext.fromTenant(productTenant).tenantId, 'tenant-a');
    expect(
      BillingRouteContext.fromTenant(productTenant).businessDomain,
      'digital',
    );
    expect(
      BillingRouteContext.fromTenantAccount(dashboardTenant).tenantId,
      'tenant-b',
    );
    expect(
      BillingRouteContext.fromTenantAccount(dashboardTenant).businessDomain,
      'construction',
    );
  });

  test('merges explicit route context overrides', () {
    final routeContext = BillingRouteContext(
      tenantId: 'tenant-a',
      businessDomain: 'commerce',
    ).merge(
      tenantId: ' tenant-b ',
      routeContext: BillingRouteContext(businessDomain: 'digital'),
    );

    expect(routeContext.tenantId, 'tenant-b');
    expect(routeContext.businessDomain, 'digital');
  });

  test('serializes route context to stable query parameters', () {
    final routeContext = BillingRouteContext(
      tenantId: ' tenant-a ',
      businessDomain: ' Construction ',
    );

    expect(
      routeContext.toQueryParameters(
        tenantQueryKey: BillingRoutes.tenantQueryKey,
        businessDomainQueryKey: BillingRoutes.businessDomainQueryKey,
      ),
      {
        BillingRoutes.tenantQueryKey: 'tenant-a',
        BillingRoutes.businessDomainQueryKey: 'construction',
      },
    );
    expect(
      BillingRouteContext.empty.toQueryParameters(
        tenantQueryKey: BillingRoutes.tenantQueryKey,
        businessDomainQueryKey: BillingRoutes.businessDomainQueryKey,
      ),
      isEmpty,
    );
  });

  test('applies route business domain to product tenant preferences', () {
    const tenant = Tenant(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
      preferences: BillingTenantPreferences(
        currencySymbol: 'Rp ',
        businessDomain: 'commerce',
      ),
    );

    final contextualTenant = billingTenantWithRouteContext(
      tenant,
      businessDomain: ' digital ',
    );

    expect(contextualTenant.id, tenant.id);
    expect(contextualTenant.preferences.currencySymbol, 'Rp ');
    expect(contextualTenant.preferences.businessDomain, 'digital');
  });

  test('applies route business domain to dashboard tenant account', () {
    const tenant = BillingTenantAccount(
      id: 'tenant-b',
      name: 'Globex',
      logoUrl: '',
      planName: 'Professional',
      currentBalance: 2400,
      preferences: BillingTenantPreferences(businessDomain: 'commerce'),
    );

    final contextualTenant = billingTenantAccountWithRouteContext(
      tenant,
      businessDomain: 'construction',
    );

    expect(contextualTenant.planName, tenant.planName);
    expect(contextualTenant.currentBalance, tenant.currentBalance);
    expect(contextualTenant.preferences.businessDomain, 'construction');
  });
}
