import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_action.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_actions.dart';

void main() {
  test('billingInvoiceActions exposes collectable invoice actions', () {
    final actions = billingInvoiceActions(BillingInvoiceStatus.pending);

    expect(actions.map((action) => action.type), [
      BillingInvoiceActionType.collectPayment,
      BillingInvoiceActionType.sendReminder,
      BillingInvoiceActionType.download,
    ]);
    expect(actions.first.label, 'Collect Payment');
    expect(actions.first.enabled, isTrue);
  });

  test('billingInvoiceActions disables collection for closed invoices', () {
    final actions = billingInvoiceActions(BillingInvoiceStatus.paid);

    expect(actions.map((action) => action.type), [
      BillingInvoiceActionType.collectPayment,
      BillingInvoiceActionType.download,
    ]);
    expect(actions.first.label, 'Payment Closed');
    expect(actions.first.enabled, isFalse);
    expect(actions.first.disabledReason, isNotEmpty);
  });
}
