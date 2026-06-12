class PayableAgingBucket {
  final String id;
  final String label;
  final double amount;
  final int billCount;

  const PayableAgingBucket({
    required this.id,
    required this.label,
    this.amount = 0,
    this.billCount = 0,
  });

  PayableAgingBucket copyWith({double? amount, int? billCount}) {
    return PayableAgingBucket(
      id: id,
      label: label,
      amount: amount ?? this.amount,
      billCount: billCount ?? this.billCount,
    );
  }
}

class PayableAgingSummary {
  final List<PayableAgingBucket> buckets;

  const PayableAgingSummary({required this.buckets});

  double get totalOutstanding =>
      buckets.fold(0, (total, bucket) => total + bucket.amount);

  double get overdueAmount => buckets
      .where((bucket) => bucket.id != PayableAgingBucketIds.current)
      .fold(0, (total, bucket) => total + bucket.amount);

  int get openBillCount =>
      buckets.fold(0, (total, bucket) => total + bucket.billCount);
}

class PayableAgingBucketIds {
  static const current = 'current';
  static const overdue1To30 = '1-30';
  static const overdue31To60 = '31-60';
  static const overdue61To90 = '61-90';
  static const overdue90Plus = '90+';

  const PayableAgingBucketIds._();

  static String labelFor(String bucketId) {
    switch (bucketId) {
      case current:
        return 'Current';
      case overdue1To30:
        return '1-30';
      case overdue31To60:
        return '31-60';
      case overdue61To90:
        return '61-90';
      case overdue90Plus:
        return '90+';
      default:
        return bucketId;
    }
  }
}
