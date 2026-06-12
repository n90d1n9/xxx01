import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/invoice_payment_policy.dart';

void main() {
  group('InvoicePaymentPolicy', () {
    const policy = InvoicePaymentPolicy();

    test('marks a fully paid invoice as paid', () {
      final invoice = Invoice(id: 'INV-001', amount: 1000);

      final status = policy.statusFor(
        invoice: invoice,
        payments: [Payment(id: 'PAY-001', invoiceId: invoice.id, amount: 1000)],
      );

      expect(status, InvoiceStatus.paid);
    });

    test('marks a partly paid invoice as partially paid', () {
      final invoice = Invoice(id: 'INV-002', amount: 1000);

      final status = policy.statusFor(
        invoice: invoice,
        payments: [Payment(id: 'PAY-002', invoiceId: invoice.id, amount: 350)],
      );

      expect(status, InvoiceStatus.partiallyPaid);
    });

    test('keeps unpaid overdue invoices in overdue status', () {
      final invoice = Invoice(
        id: 'INV-003',
        amount: 1000,
        dueDate: DateTime(2026, 1, 1),
      );

      final status = policy.statusFor(
        invoice: invoice,
        payments: const [],
        asOf: DateTime(2026, 1, 10),
      );

      expect(status, InvoiceStatus.overdue);
    });
  });
}
