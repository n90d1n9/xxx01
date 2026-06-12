import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_policies.dart';

void main() {
  test(
    'billingInvoiceIssuePolicyForProfile resolves standard construction policy',
    () {
      final policy = billingInvoiceIssuePolicyForProfile(
        constructionBillingDomainProfile(
          taxMode: BillingInvoiceTaxMode.inclusive,
        ),
      );

      expect(policy.domain, 'construction');
      expect(policy.taxMode, BillingInvoiceTaxMode.inclusive);
      expect(
        policy.paymentScheduleOptions?.strategy,
        BillingPaymentScheduleStrategy.splitEqual,
      );
      expect(policy.paymentScheduleOptions?.installments, 3);
    },
  );

  test('billingInvoiceIssuePolicyForProfile supports explicit overrides', () {
    final policy = billingInvoiceIssuePolicyForProfile(
      digitalSubscriptionBillingDomainProfile(),
      taxMode: BillingInvoiceTaxMode.exempt,
      paymentScheduleOptions: BillingPaymentScheduleOptions.upfrontAndBalance(
        upfrontRatio: 0.4,
      ),
    );

    expect(policy.taxMode, BillingInvoiceTaxMode.exempt);
    expect(
      policy.paymentScheduleOptions?.strategy,
      BillingPaymentScheduleStrategy.upfrontAndBalance,
    );
    expect(policy.paymentScheduleOptions?.upfrontRatio, 0.4);
  });

  test('billingPaymentScheduleOptionsForProfile parses profile attributes', () {
    final profile = BillingBusinessDomainProfile(
      domain: 'service',
      label: 'Service retainers',
      defaultSourceType: 'retainer',
      attributes: const {
        'paymentScheduleStrategy': 'deposit',
        'paymentScheduleUpfrontRatio': '0.25',
      },
    );

    final options = billingPaymentScheduleOptionsForProfile(profile);

    expect(options?.strategy, BillingPaymentScheduleStrategy.upfrontAndBalance);
    expect(options?.upfrontRatio, 0.25);
  });

  test(
    'billingPaymentScheduleOptionsForProfile derives capability defaults',
    () {
      final progressProfile = BillingBusinessDomainProfile(
        domain: 'agency',
        label: 'Agency',
        defaultSourceType: 'project',
        capabilities: const {BillingBusinessDomainCapability.progressBilling},
      );

      final retainerProfile = BillingBusinessDomainProfile(
        domain: 'legal',
        label: 'Legal',
        defaultSourceType: 'retainer',
        capabilities: const {BillingBusinessDomainCapability.retainers},
      );

      expect(
        billingPaymentScheduleOptionsForProfile(progressProfile)?.strategy,
        BillingPaymentScheduleStrategy.splitEqual,
      );
      expect(
        billingPaymentScheduleOptionsForProfile(retainerProfile)?.strategy,
        BillingPaymentScheduleStrategy.upfrontAndBalance,
      );
    },
  );

  test(
    'billingPaymentScheduleOptionsForProfile rejects invalid attributes',
    () {
      final profile = BillingBusinessDomainProfile(
        domain: 'bad',
        label: 'Bad',
        defaultSourceType: 'bad',
        attributes: const {
          'paymentScheduleStrategy': 'split_equal',
          'paymentScheduleInstallments': '0',
        },
      );

      expect(
        () => billingPaymentScheduleOptionsForProfile(profile),
        throwsStateError,
      );
    },
  );
}
