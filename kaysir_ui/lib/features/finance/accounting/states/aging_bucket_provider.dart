// Aging buckets provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/invoice.dart';
import 'invoice_provider.dart';

final agingBucketsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final invoices = ref
      .watch(invoicesProvider)
      .invoices
      .where(_isReceivableInvoice);

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
      agingBuckets['31-60'] = agingBuckets['31-60']! + invoice.remainingAmount;
    } else if (invoice.daysOverdue <= 90) {
      agingBuckets['61-90'] = agingBuckets['61-90']! + invoice.remainingAmount;
    } else {
      agingBuckets['90+'] = agingBuckets['90+']! + invoice.remainingAmount;
    }
  }

  return AsyncValue.data(agingBuckets);
});

bool _isReceivableInvoice(Invoice invoice) {
  return invoice.customerId != null && invoice.dueDate != null;
}
