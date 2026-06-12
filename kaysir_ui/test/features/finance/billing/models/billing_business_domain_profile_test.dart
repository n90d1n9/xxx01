import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';

void main() {
  test('BillingBusinessDomainProfile validates and preserves capabilities', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'Digital',
      label: 'Digital subscriptions',
      defaultSourceType: 'subscription',
      taxRate: 0.11,
      taxMode: BillingInvoiceTaxMode.inclusive,
      capabilities: const {
        BillingBusinessDomainCapability.recurringSubscriptions,
        BillingBusinessDomainCapability.meteredUsage,
      },
      attributes: const {'billingCadence': 'monthly'},
    );

    expect(profile.key, 'digital');
    expect(profile.isValid, isTrue);
    expect(
      profile.supports(BillingBusinessDomainCapability.recurringSubscriptions),
      isTrue,
    );
    expect(
      profile.supports(BillingBusinessDomainCapability.projectMilestones),
      isFalse,
    );
    expect(
      () => profile.attributes['billingCadence'] = 'annual',
      throwsUnsupportedError,
    );
  });

  test('BillingBusinessDomainProfileRegistry finds normalized domains', () {
    final commerce = BillingBusinessDomainProfile(
      domain: 'commerce',
      label: 'Commerce',
      defaultSourceType: 'cart_item',
    );
    final registry = BillingBusinessDomainProfileRegistry(profiles: [commerce]);

    expect(registry.find(' COMMERCE '), commerce);
    expect(registry.requireProfile('commerce'), commerce);
    expect(registry.contains('Commerce'), isTrue);
    expect(registry.domainKeys, ['commerce']);
    expect(() => registry.requireProfile('construction'), throwsStateError);
  });

  test('BillingBusinessDomainProfileRegistry registers profiles immutably', () {
    final commerce = BillingBusinessDomainProfile(
      domain: 'commerce',
      label: 'Commerce',
      defaultSourceType: 'cart_item',
    );
    final service = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
    );
    final usage = BillingBusinessDomainProfile(
      domain: 'usage',
      label: 'Usage',
      defaultSourceType: 'meter',
    );
    final registry = BillingBusinessDomainProfileRegistry(profiles: [commerce]);

    final extended = registry.registerAll([service, usage]);

    expect(registry.domainKeys, ['commerce']);
    expect(extended.domainKeys, ['commerce', 'service', 'usage']);
    expect(extended.requireProfile('SERVICE'), service);
    expect(() => extended.domainKeys.add('manual'), throwsUnsupportedError);
  });

  test('BillingBusinessDomainProfileRegistry rejects invalid duplicates', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'commerce',
      label: 'Commerce',
      defaultSourceType: 'cart_item',
    );

    expect(
      () => BillingBusinessDomainProfileRegistry(
        profiles: [profile, profile.copyWith(label: 'Retail')],
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainProfileRegistry().registerAll([
        profile,
        profile.copyWith(label: 'Retail'),
      ]),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainProfileRegistry(
        profiles: [
          BillingBusinessDomainProfile(
            domain: '',
            label: '',
            defaultSourceType: '',
            taxRate: 2,
          ),
        ],
      ),
      throwsStateError,
    );
  });
}
