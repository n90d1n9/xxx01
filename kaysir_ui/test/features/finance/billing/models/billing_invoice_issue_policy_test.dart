import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_policy.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';

void main() {
  test(
    'BillingInvoiceIssuePolicy validates and preserves immutable attributes',
    () {
      final policy = BillingInvoiceIssuePolicy(
        domain: 'construction',
        label: 'Construction',
        taxMode: BillingInvoiceTaxMode.exclusive,
        paymentScheduleOptions: BillingPaymentScheduleOptions.splitEqual(
          installments: 3,
        ),
        attributes: const {'workflow': 'progress'},
      );

      expect(policy.validationErrors, isEmpty);
      expect(policy.hasPaymentSchedulePolicy, isTrue);
      expect(
        () => policy.attributes['workflow'] = 'retainer',
        throwsUnsupportedError,
      );
    },
  );

  test('BillingInvoiceIssuePolicy copyWith can clear schedule policy', () {
    final policy = BillingInvoiceIssuePolicy(
      domain: 'digital',
      label: 'Digital',
      taxMode: BillingInvoiceTaxMode.inclusive,
      paymentScheduleOptions: BillingPaymentScheduleOptions.singleDueDate(),
    );

    final cleared = policy.copyWith(paymentScheduleOptions: null);

    expect(cleared.paymentScheduleOptions, isNull);
    expect(cleared.taxMode, BillingInvoiceTaxMode.inclusive);
  });

  test('BillingInvoiceIssuePolicy reports missing identity', () {
    final policy = BillingInvoiceIssuePolicy(
      domain: '',
      label: '',
      taxMode: BillingInvoiceTaxMode.exempt,
    );

    expect(policy.validationErrors, [
      'Invoice issue policy domain is required.',
      'Invoice issue policy label is required.',
    ]);
  });
}
