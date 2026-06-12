import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/payable_payment_run.dart';
import '../services/payable_payment_run_service.dart';

final payablePaymentRunServiceProvider = Provider<PayablePaymentRunService>((
  ref,
) {
  return const PayablePaymentRunService();
});

final payablePaymentRunRecordsProvider = StateNotifierProvider<
  PayablePaymentRunRecordsNotifier,
  List<PayablePaymentRunRecord>
>((ref) {
  return PayablePaymentRunRecordsNotifier();
});

class PayablePaymentRunRecordsNotifier
    extends StateNotifier<List<PayablePaymentRunRecord>> {
  PayablePaymentRunRecordsNotifier() : super(const []);

  void addRecord(PayablePaymentRunRecord record) {
    state = [record, ...state];
  }
}
