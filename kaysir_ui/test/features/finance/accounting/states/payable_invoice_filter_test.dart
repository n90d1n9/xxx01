import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payable_aging.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_filter_provider.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_provider.dart';

void main() {
  group('matchesPayableInvoiceFilter', () {
    final asOf = DateTime(2026, 5, 30);

    test('matches bills by selected AP aging bucket', () {
      final currentBill = _bill(
        id: 'current',
        dueDate: DateTime(2026, 6, 5),
        amount: 100,
      );
      final overdueBill = _bill(
        id: 'overdue',
        dueDate: DateTime(2026, 5, 20),
        amount: 200,
      );

      final filter = InvoiceFilter(
        agingBucketId: PayableAgingBucketIds.overdue1To30,
      );

      expect(
        matchesPayableInvoiceFilter(overdueBill, filter, asOf: asOf),
        isTrue,
      );
      expect(
        matchesPayableInvoiceFilter(currentBill, filter, asOf: asOf),
        isFalse,
      );
    });

    test('excludes fully settled bills from AP aging bucket filters', () {
      final paidBill = _bill(
        id: 'paid',
        dueDate: DateTime(2026, 5, 10),
        amount: 300,
        payments: [Payment(id: 'payment-1', invoiceId: 'paid', amount: 300)],
      );

      final filter = InvoiceFilter(
        agingBucketId: PayableAgingBucketIds.overdue1To30,
      );

      expect(
        matchesPayableInvoiceFilter(paidBill, filter, asOf: asOf),
        isFalse,
      );
    });

    test('combines aging bucket with vendor and status filters', () {
      final bill = _bill(
        id: 'bill-1',
        vendorId: 'vendor-1',
        dueDate: DateTime(2026, 5, 1),
        amount: 700,
      );

      expect(
        matchesPayableInvoiceFilter(
          bill,
          InvoiceFilter(
            vendorId: 'vendor-1',
            status: InvoiceStatus.pending,
            agingBucketId: PayableAgingBucketIds.overdue1To30,
          ),
          asOf: asOf,
        ),
        isTrue,
      );
      expect(
        matchesPayableInvoiceFilter(
          bill,
          InvoiceFilter(
            vendorId: 'vendor-2',
            status: InvoiceStatus.pending,
            agingBucketId: PayableAgingBucketIds.overdue1To30,
          ),
          asOf: asOf,
        ),
        isFalse,
      );
    });
  });
}

Invoice _bill({
  required String id,
  required DateTime dueDate,
  required double amount,
  String vendorId = 'vendor-1',
  InvoiceStatus status = InvoiceStatus.pending,
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    vendorId: vendorId,
    invoiceNumber: 'BILL-$id',
    invoiceDate: DateTime(2026, 1, 1),
    dueDate: dueDate,
    amount: amount,
    status: status,
    payments: payments,
  );
}
