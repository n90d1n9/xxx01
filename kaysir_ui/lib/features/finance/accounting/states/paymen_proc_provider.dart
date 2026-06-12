import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/invoic_dummy.dart';

import '../models/payment.dart';
import '../models/payment_processor.dart';

final paymentProcessorsProvider = StateProvider<List<PaymentProcessor>>((ref) {
  return [
    PaymentProcessor(
      id: '1',
      name: 'Bank Transfer',
      processingFee: 0.00,
      processingTime: 2,
    ),
    PaymentProcessor(
      id: '2',
      name: 'Credit Card',
      processingFee: 2.75,
      processingTime: 0,
    ),
    PaymentProcessor(
      id: '3',
      name: 'PayPal',
      processingFee: 1.50,
      processingTime: 1,
    ),
    PaymentProcessor(
      id: '4',
      name: 'Check',
      processingFee: 0.00,
      processingTime: 5,
    ),
  ];
});

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>(
  (ref) {
    return PaymentsNotifier();
  },
);

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  PaymentsNotifier() : super(paymentDummy);

  void addPayment(Payment payment) {
    state = [...state, payment];
  }

  void removePayment(String id) {
    state = state.where((payment) => payment.id != id).toList();
  }

  List<Payment> getPaymentsForInvoice(String invoiceId) {
    return state.where((payment) => payment.invoiceId == invoiceId).toList();
  }

  double getTotalPaidForInvoice(String invoiceId) {
    return state
        .where((payment) => payment.invoiceId == invoiceId)
        .fold(0, (sum, payment) => sum + payment.amount);
  }

  void updatePayment(Payment updatedPayment) {
    state =
        state.map((payment) {
          if (payment.id == updatedPayment.id) {
            return updatedPayment;
          }
          return payment;
        }).toList();
  }
}
