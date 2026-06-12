class PayableCashForecastBucket {
  final String id;
  final String label;
  final double amount;
  final int billCount;

  const PayableCashForecastBucket({
    required this.id,
    required this.label,
    this.amount = 0,
    this.billCount = 0,
  });

  PayableCashForecastBucket copyWith({double? amount, int? billCount}) {
    return PayableCashForecastBucket(
      id: id,
      label: label,
      amount: amount ?? this.amount,
      billCount: billCount ?? this.billCount,
    );
  }
}

class PayableCashForecast {
  final List<PayableCashForecastBucket> buckets;
  final DateTime? nextDueDate;

  const PayableCashForecast({required this.buckets, this.nextDueDate});

  double get totalOpen =>
      buckets.fold(0, (total, bucket) => total + bucket.amount);

  double get dueNow => _amountFor(PayableCashForecastBucketIds.dueNow);

  double get next30Days => buckets
      .where((bucket) => bucket.id != PayableCashForecastBucketIds.after30Days)
      .fold(0, (total, bucket) => total + bucket.amount);

  int get openBillCount =>
      buckets.fold(0, (total, bucket) => total + bucket.billCount);

  double _amountFor(String bucketId) {
    for (final bucket in buckets) {
      if (bucket.id == bucketId) {
        return bucket.amount;
      }
    }
    return 0;
  }
}

class PayableCashForecastBucketIds {
  static const dueNow = 'due_now';
  static const next7Days = 'next_7_days';
  static const days8To14 = 'days_8_14';
  static const days15To30 = 'days_15_30';
  static const after30Days = 'after_30_days';

  const PayableCashForecastBucketIds._();
}
