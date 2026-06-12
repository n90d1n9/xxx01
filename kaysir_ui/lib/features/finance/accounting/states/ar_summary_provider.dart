import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/invoice.dart';
import 'invoice_provider.dart';

final arSummaryProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final invoices = ref
      .watch(invoicesProvider)
      .invoices
      .where(_isReceivableInvoice);

  double totalReceivable = 0;
  double totalOverdue = 0;
  double totalPaid = 0;
  double totalInvoiced = 0;
  double openInvoices = 0;

  for (final invoice in invoices) {
    totalPaid += invoice.paidAmount;
    totalReceivable += invoice.remainingAmount;
    totalInvoiced += invoice.amount;

    if (invoice.remainingAmount > 0) {
      openInvoices += 1;
    }

    if (invoice.isOverdue) {
      totalOverdue += invoice.remainingAmount;
    }
  }

  return AsyncValue.data({
    'totalReceivable': totalReceivable,
    'totalOverdue': totalOverdue,
    'totalPaid': totalPaid,
    'totalInvoiced': totalInvoiced,
    'openInvoices': openInvoices,
    'collectionRate': totalInvoiced == 0 ? 0 : totalPaid / totalInvoiced,
  });
});

bool _isReceivableInvoice(Invoice invoice) {
  return invoice.customerId != null && invoice.dueDate != null;
}
