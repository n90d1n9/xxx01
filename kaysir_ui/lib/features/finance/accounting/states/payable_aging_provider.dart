import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/payable_aging.dart';
import '../services/payable_aging_service.dart';
import 'invoice_provider.dart';

final payableAgingServiceProvider = Provider<PayableAgingService>((ref) {
  return const PayableAgingService();
});

final payableAgingSummaryProvider = Provider<PayableAgingSummary>((ref) {
  final bills = ref.watch(allPayableInvoicesProvider);
  final service = ref.watch(payableAgingServiceProvider);

  return service.summarize(bills: bills, asOf: DateTime.now());
});
