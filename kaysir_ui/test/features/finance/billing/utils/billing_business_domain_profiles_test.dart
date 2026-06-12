import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';

void main() {
  test('standardBillingDomainProfileRegistry exposes starter verticals', () {
    final registry = standardBillingDomainProfileRegistry();

    expect(registry.requireProfile('commerce').defaultSourceType, 'cart_item');
    expect(
      registry.requireProfile('construction').defaultSourceType,
      'milestone',
    );
    expect(
      registry.requireProfile('digital').defaultSourceType,
      'subscription',
    );
  });

  test('standardBillingDomainProfileRegistry composes product extensions', () {
    final service = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service',
      defaultSourceType: 'work_order',
      capabilities: const {BillingBusinessDomainCapability.servicePeriods},
    );
    final registry = standardBillingDomainProfileRegistry(
      additionalProfiles: [service],
    );

    expect(registry.domainKeys, [
      'commerce',
      'construction',
      'digital',
      'service',
    ]);
    expect(registry.requireProfile('service'), service);
    expect(registry.requireProfile('commerce').label, 'Commerce');
  });

  test('standardBillingDomainProfileRegistry rejects duplicate extensions', () {
    expect(
      () => standardBillingDomainProfileRegistry(
        additionalProfiles: [
          commerceBillingDomainProfile().copyWith(label: 'Retail'),
        ],
      ),
      throwsStateError,
    );
  });

  test('profile builders preserve domain capability intent', () {
    final commerce = commerceBillingDomainProfile(taxRate: 0.1);
    final construction = constructionBillingDomainProfile();
    final digital = digitalSubscriptionBillingDomainProfile(
      taxMode: BillingInvoiceTaxMode.inclusive,
    );

    expect(commerce.taxRate, 0.1);
    expect(commerce.attributes['paymentScheduleStrategy'], 'single_due_date');
    expect(
      commerce.supports(BillingBusinessDomainCapability.cartCheckout),
      isTrue,
    );
    expect(construction.attributes['paymentScheduleStrategy'], 'split_equal');
    expect(construction.attributes['paymentScheduleInstallments'], '3');
    expect(
      construction.supports(BillingBusinessDomainCapability.progressBilling),
      isTrue,
    );
    expect(digital.taxMode, BillingInvoiceTaxMode.inclusive);
    expect(digital.attributes['paymentScheduleStrategy'], 'single_due_date');
    expect(
      digital.supports(BillingBusinessDomainCapability.recurringSubscriptions),
      isTrue,
    );
  });
}
