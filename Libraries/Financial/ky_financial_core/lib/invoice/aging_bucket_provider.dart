// Aging buckets provider
final agingBucketsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final invoicesAsync = ref.watch(invoicesProvider);

  return invoicesAsync.whenData((invoices) {
    final Map<String, double> agingBuckets = {
      'current': 0,
      '1-30': 0,
      '31-60': 0,
      '61-90': 0,
      '90+': 0,
    };

    for (final invoice in invoices) {
      if (invoice.remainingAmount <= 0) continue;

      if (!invoice.isOverdue) {
        agingBuckets['current'] =
            agingBuckets['current']! + invoice.remainingAmount;
      } else if (invoice.daysOverdue <= 30) {
        agingBuckets['1-30'] = agingBuckets['1-30']! + invoice.remainingAmount;
      } else if (invoice.daysOverdue <= 60) {
        agingBuckets['31-60'] =
            agingBuckets['31-60']! + invoice.remainingAmount;
      } else if (invoice.daysOverdue <= 90) {
        agingBuckets['61-90'] =
            agingBuckets['61-90']! + invoice.remainingAmount;
      } else {
        agingBuckets['90+'] = agingBuckets['90+']! + invoice.remainingAmount;
      }
    }

    return agingBuckets;
  });
});
