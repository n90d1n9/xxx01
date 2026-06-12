import '../../order/models/order.dart';
import '../../order/utils/order_display.dart';
import '../../payment/utils/payment_tendering.dart';

class POSCheckoutBehavior {
  final bool autoCompleteOnFinalPayment;
  final bool showReceiptAfterCompletion;
  final bool startNewOrderAfterCompletion;
  final String paymentButtonLabel;
  final String completeButtonLabel;
  final String finalPaymentButtonLabel;
  final String partialPaymentButtonLabel;
  final String emptyStatusLabel;
  final String needsPaymentStatusLabel;
  final String readyStatusLabel;
  final String autoCompletedMessage;

  const POSCheckoutBehavior({
    this.autoCompleteOnFinalPayment = false,
    this.showReceiptAfterCompletion = true,
    this.startNewOrderAfterCompletion = true,
    this.paymentButtonLabel = 'Payment',
    this.completeButtonLabel = 'Complete order',
    this.finalPaymentButtonLabel = 'Record final payment',
    this.partialPaymentButtonLabel = 'Record partial payment',
    this.emptyStatusLabel = 'Build order',
    this.needsPaymentStatusLabel = 'Payment due',
    this.readyStatusLabel = 'Ready to close',
    this.autoCompletedMessage = 'Payment recorded and order completed.',
  });

  static const standard = POSCheckoutBehavior();

  static const quickCheckout = POSCheckoutBehavior(
    autoCompleteOnFinalPayment: true,
    showReceiptAfterCompletion: false,
    paymentButtonLabel: 'Pay now',
    completeButtonLabel: 'Close sale',
    finalPaymentButtonLabel: 'Pay and complete',
    partialPaymentButtonLabel: 'Record payment',
    emptyStatusLabel: 'Ready for items',
    needsPaymentStatusLabel: 'Awaiting payment',
    readyStatusLabel: 'Paid',
    autoCompletedMessage: 'Quick checkout completed.',
  );

  static const assistedService = POSCheckoutBehavior(
    paymentButtonLabel: 'Take payment',
    completeButtonLabel: 'Close service order',
    finalPaymentButtonLabel: 'Record service payment',
    partialPaymentButtonLabel: 'Record deposit',
    emptyStatusLabel: 'Build service order',
    needsPaymentStatusLabel: 'Service payment due',
    readyStatusLabel: 'Ready for handoff',
  );

  String readinessLabel(Order order) {
    switch (resolvePOSOrderReadiness(order)) {
      case POSOrderReadiness.empty:
        return emptyStatusLabel;
      case POSOrderReadiness.needsPayment:
        return needsPaymentStatusLabel;
      case POSOrderReadiness.readyToComplete:
        return readyStatusLabel;
    }
  }

  String paymentActionLabel(PaymentTenderEvaluation evaluation) {
    return evaluation.completesOrder
        ? finalPaymentButtonLabel
        : partialPaymentButtonLabel;
  }

  bool shouldAutoComplete(PaymentTenderEvaluation evaluation) {
    return autoCompleteOnFinalPayment && evaluation.completesOrder;
  }
}
