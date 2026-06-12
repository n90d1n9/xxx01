import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_aging.dart';

void main() {
  test('parseBillingInvoiceStatus accepts labels and safe fallbacks', () {
    expect(parseBillingInvoiceStatus('paid'), BillingInvoiceStatus.paid);
    expect(parseBillingInvoiceStatus('Overdue'), BillingInvoiceStatus.overdue);
    expect(parseBillingInvoiceStatus('unknown'), BillingInvoiceStatus.pending);
  });

  test('billing invoice aging marks due soon and overdue invoices', () {
    final now = DateTime(2026, 5, 31, 15);

    final dueSoon = BillingInvoiceAging(
      status: BillingInvoiceStatus.pending,
      dueDate: DateTime(2026, 6, 3),
      now: now,
    );
    final overdue = BillingInvoiceAging(
      status: BillingInvoiceStatus.pending,
      dueDate: DateTime(2026, 5, 28),
      now: now,
    );

    expect(dueSoon.health, BillingInvoiceHealth.dueSoon);
    expect(dueSoon.operatorMessage, 'Payment is due in 3 days.');
    expect(overdue.health, BillingInvoiceHealth.overdue);
    expect(overdue.operatorMessage, 'Payment is 3 days overdue.');
  });

  test('billing invoice aging keeps closed invoices stable', () {
    final paid = BillingInvoiceAging(
      status: BillingInvoiceStatus.paid,
      dueDate: DateTime(2026, 5, 1),
      now: DateTime(2026, 5, 31),
    );

    expect(paid.health, BillingInvoiceHealth.paid);
    expect(paid.operatorMessage, 'Invoice is settled.');
  });
}
