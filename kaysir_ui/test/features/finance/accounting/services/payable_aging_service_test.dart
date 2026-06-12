import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payable_aging.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/payable_aging_service.dart';

void main() {
  group('PayableAgingService', () {
    const service = PayableAgingService();
    final asOf = DateTime(2026, 5, 30, 18);

    test('summarizes open bills into standard AP aging buckets', () {
      final summary = service.summarize(
        asOf: asOf,
        bills: [
          _bill(id: 'current', dueDate: DateTime(2026, 5, 30), amount: 100),
          _bill(id: 'future', dueDate: DateTime(2026, 6, 10), amount: 50),
          _bill(
            id: 'partial',
            dueDate: DateTime(2026, 5, 20),
            amount: 200,
            payments: [Payment(id: 'p1', invoiceId: 'partial', amount: 25)],
          ),
          _bill(id: '31-60', dueDate: DateTime(2026, 4, 15), amount: 300),
          _bill(id: '61-90', dueDate: DateTime(2026, 3, 10), amount: 400),
          _bill(id: '90+', dueDate: DateTime(2026, 1, 15), amount: 500),
        ],
      );

      expect(_amount(summary, PayableAgingBucketIds.current), 150);
      expect(_count(summary, PayableAgingBucketIds.current), 2);
      expect(_amount(summary, PayableAgingBucketIds.overdue1To30), 175);
      expect(_amount(summary, PayableAgingBucketIds.overdue31To60), 300);
      expect(_amount(summary, PayableAgingBucketIds.overdue61To90), 400);
      expect(_amount(summary, PayableAgingBucketIds.overdue90Plus), 500);
      expect(summary.totalOutstanding, 1525);
      expect(summary.overdueAmount, 1375);
      expect(summary.openBillCount, 6);
    });

    test('skips settled bills and bills without due dates', () {
      final summary = service.summarize(
        asOf: asOf,
        bills: [
          _bill(
            id: 'paid',
            dueDate: DateTime(2026, 4, 1),
            amount: 900,
            status: InvoiceStatus.paid,
          ),
          Invoice(id: 'no-due-date', vendorId: 'vendor-1', amount: 250),
        ],
      );

      expect(summary.totalOutstanding, 0);
      expect(summary.overdueAmount, 0);
      expect(summary.openBillCount, 0);
    });
  });
}

Invoice _bill({
  required String id,
  required DateTime dueDate,
  required double amount,
  InvoiceStatus status = InvoiceStatus.pending,
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    vendorId: 'vendor-1',
    invoiceNumber: 'BILL-$id',
    invoiceDate: DateTime(2026, 1, 1),
    dueDate: dueDate,
    amount: amount,
    status: status,
    payments: payments,
  );
}

double _amount(PayableAgingSummary summary, String bucketId) {
  return _bucket(summary, bucketId).amount;
}

int _count(PayableAgingSummary summary, String bucketId) {
  return _bucket(summary, bucketId).billCount;
}

PayableAgingBucket _bucket(PayableAgingSummary summary, String bucketId) {
  return summary.buckets.singleWhere((bucket) => bucket.id == bucketId);
}
