import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_tenant_domain_module.dart';

void main() {
  test('billingTenantBusinessDomainModule resolves standard modules', () {
    final module = billingTenantBusinessDomainModule(
      const BillingTenantPreferences(businessDomain: ' digital '),
    );

    expect(module.key, 'digital');
    expect(module.profile.defaultSourceType, 'subscription');
    expect(module.hasIssuePolicy, isTrue);
  });

  test('billingTenantBusinessDomainModule falls back to commerce', () {
    final module = billingTenantBusinessDomainModule(
      const BillingTenantPreferences(businessDomain: 'unknown'),
    );

    expect(module.key, 'commerce');
    expect(module.hasLineItemAdapters, isTrue);
  });

  test('billingTenantBusinessDomainModule supports custom registries', () {
    final serviceModule = BillingBusinessDomainModule(
      profile: BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service',
        defaultSourceType: 'work_order',
      ),
    );
    final registry = BillingBusinessDomainModuleRegistry(
      modules: [serviceModule],
    );

    final module = billingTenantBusinessDomainModule(
      const BillingTenantPreferences(businessDomain: 'SERVICE'),
      registry: registry,
    );

    expect(module, serviceModule);
  });

  test('billingTenantBusinessDomainModule reports missing fallback', () {
    final registry = BillingBusinessDomainModuleRegistry(
      modules: [
        BillingBusinessDomainModule(
          profile: BillingBusinessDomainProfile(
            domain: 'service',
            label: 'Service',
            defaultSourceType: 'work_order',
          ),
        ),
      ],
    );

    expect(
      () => billingTenantBusinessDomainModule(
        const BillingTenantPreferences(businessDomain: 'unknown'),
        registry: registry,
      ),
      throwsStateError,
    );
  });
}
