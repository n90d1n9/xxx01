import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

final arSummaryProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final invoicesAsync = ref.watch(invoicesProvider);

  return invoicesAsync.whenData((invoices) {
    double totalReceivable = 0;
    double totalOverdue = 0;
    double totalPaid = 0;

    for (final invoice in invoices) {
      totalPaid += invoice.paidAmount;
      totalReceivable += invoice.remainingAmount;

      if (invoice.isOverdue) {
        totalOverdue += invoice.remainingAmount;
      }
    }

    return {
      'totalReceivable': totalReceivable,
      'totalOverdue': totalOverdue,
      'totalPaid': totalPaid,
    };
  });
});
