import '../models/invoice.dart';
import '../models/payable_cash_forecast.dart';

class PayableCashForecastService {
  const PayableCashForecastService();

  PayableCashForecast summarize({
    required Iterable<Invoice> bills,
    required DateTime asOf,
  }) {
    final buckets = {for (final bucket in emptyBuckets()) bucket.id: bucket};
    final asOfDate = _dateOnly(asOf);
    DateTime? nextDueDate;

    for (final bill in bills) {
      final dueDate = bill.dueDate;
      if (dueDate == null || bill.remainingAmount <= 0) {
        continue;
      }

      final normalizedDueDate = _dateOnly(dueDate);
      if (nextDueDate == null || normalizedDueDate.isBefore(nextDueDate)) {
        nextDueDate = normalizedDueDate;
      }

      final bucketId = bucketIdFor(dueDate: normalizedDueDate, asOf: asOfDate);
      final bucket = buckets[bucketId]!;
      buckets[bucketId] = bucket.copyWith(
        amount: bucket.amount + bill.remainingAmount,
        billCount: bucket.billCount + 1,
      );
    }

    return PayableCashForecast(
      buckets: buckets.values.toList(),
      nextDueDate: nextDueDate,
    );
  }

  static List<PayableCashForecastBucket> emptyBuckets() {
    return const [
      PayableCashForecastBucket(
        id: PayableCashForecastBucketIds.dueNow,
        label: 'Due Now',
      ),
      PayableCashForecastBucket(
        id: PayableCashForecastBucketIds.next7Days,
        label: 'Next 7 Days',
      ),
      PayableCashForecastBucket(
        id: PayableCashForecastBucketIds.days8To14,
        label: '8-14 Days',
      ),
      PayableCashForecastBucket(
        id: PayableCashForecastBucketIds.days15To30,
        label: '15-30 Days',
      ),
      PayableCashForecastBucket(
        id: PayableCashForecastBucketIds.after30Days,
        label: 'After 30 Days',
      ),
    ];
  }

  String bucketIdFor({required DateTime dueDate, required DateTime asOf}) {
    final daysUntilDue = _dateOnly(dueDate).difference(_dateOnly(asOf)).inDays;
    if (daysUntilDue <= 0) {
      return PayableCashForecastBucketIds.dueNow;
    }
    if (daysUntilDue <= 7) {
      return PayableCashForecastBucketIds.next7Days;
    }
    if (daysUntilDue <= 14) {
      return PayableCashForecastBucketIds.days8To14;
    }
    if (daysUntilDue <= 30) {
      return PayableCashForecastBucketIds.days15To30;
    }
    return PayableCashForecastBucketIds.after30Days;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
