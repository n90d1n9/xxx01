import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_tenant_domain_profile.dart';

void main() {
  test(
    'billingTenantBusinessDomain defaults tenant preferences to commerce',
    () {
      expect(
        billingTenantBusinessDomain(const BillingTenantPreferences()),
        'commerce',
      );
    },
  );

  test('billingTenantBusinessDomain normalizes configured tenant domains', () {
    expect(
      billingTenantBusinessDomain(
        const BillingTenantPreferences(businessDomain: ' Construction '),
      ),
      'construction',
    );
  });

  test('billingTenantBusinessDomainProfile resolves standard profiles', () {
    final profile = billingTenantBusinessDomainProfile(
      const BillingTenantPreferences(businessDomain: 'digital'),
    );

    expect(profile.domain, 'digital');
    expect(
      profile.supports(BillingBusinessDomainCapability.recurringSubscriptions),
      isTrue,
    );
  });

  test('billingTenantBusinessDomainProfile falls back for unknown domains', () {
    final profile = billingTenantBusinessDomainProfile(
      const BillingTenantPreferences(businessDomain: 'unknown'),
    );

    expect(profile.domain, 'commerce');
  });

  test('billingTenantBusinessDomainProfile supports custom registries', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final registry = BillingBusinessDomainProfileRegistry(profiles: [profile]);

    expect(
      billingTenantBusinessDomainProfile(
        const BillingTenantPreferences(businessDomain: 'service'),
        registry: registry,
      ),
      profile,
    );
  });
}
