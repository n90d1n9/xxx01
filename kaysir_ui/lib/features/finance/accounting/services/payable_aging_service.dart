import '../models/invoice.dart';
import '../models/payable_aging.dart';

class PayableAgingService {
  const PayableAgingService();

  PayableAgingSummary summarize({
    required Iterable<Invoice> bills,
    required DateTime asOf,
  }) {
    final buckets = {for (final bucket in emptyBuckets()) bucket.id: bucket};
    final asOfDate = _dateOnly(asOf);

    for (final bill in bills) {
      final dueDate = bill.dueDate;
      if (dueDate == null || bill.remainingAmount <= 0) {
        continue;
      }

      final bucketId = bucketIdFor(dueDate: dueDate, asOf: asOfDate);
      final bucket = buckets[bucketId]!;
      buckets[bucketId] = bucket.copyWith(
        amount: bucket.amount + bill.remainingAmount,
        billCount: bucket.billCount + 1,
      );
    }

    return PayableAgingSummary(buckets: buckets.values.toList());
  }

  static List<PayableAgingBucket> emptyBuckets() {
    return const [
      PayableAgingBucket(id: PayableAgingBucketIds.current, label: 'Current'),
      PayableAgingBucket(id: PayableAgingBucketIds.overdue1To30, label: '1-30'),
      PayableAgingBucket(
        id: PayableAgingBucketIds.overdue31To60,
        label: '31-60',
      ),
      PayableAgingBucket(
        id: PayableAgingBucketIds.overdue61To90,
        label: '61-90',
      ),
      PayableAgingBucket(id: PayableAgingBucketIds.overdue90Plus, label: '90+'),
    ];
  }

  String bucketIdFor({required DateTime dueDate, required DateTime asOf}) {
    return _bucketIdForDays(
      _dateOnly(asOf).difference(_dateOnly(dueDate)).inDays,
    );
  }

  String _bucketIdForDays(int daysPastDue) {
    if (daysPastDue <= 0) {
      return PayableAgingBucketIds.current;
    }
    if (daysPastDue <= 30) {
      return PayableAgingBucketIds.overdue1To30;
    }
    if (daysPastDue <= 60) {
      return PayableAgingBucketIds.overdue31To60;
    }
    if (daysPastDue <= 90) {
      return PayableAgingBucketIds.overdue61To90;
    }
    return PayableAgingBucketIds.overdue90Plus;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
