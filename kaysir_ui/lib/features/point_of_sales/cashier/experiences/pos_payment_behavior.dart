import '../../payment/utils/payment_tendering.dart';

class POSPaymentBehavior {
  final List<String> paymentMethods;
  final String defaultMethod;
  final bool allowPartialPayments;
  final bool includeCashRoundSuggestions;
  final List<double> cashDenominations;
  final String partialPaymentMessage;
  final String unavailableMethodMessage;

  const POSPaymentBehavior({
    this.paymentMethods = const ['Cash', 'Debit Card', 'Mobile Payment'],
    this.defaultMethod = 'Cash',
    this.allowPartialPayments = true,
    this.includeCashRoundSuggestions = true,
    this.cashDenominations = kPOSTenderDenominations,
    this.partialPaymentMessage =
        'This checkout mode requires one final payment.',
    this.unavailableMethodMessage =
        'This payment method is not available for this checkout mode.',
  });

  static const standard = POSPaymentBehavior();

  static const quickCheckout = POSPaymentBehavior(
    paymentMethods: ['Cash', 'Mobile Payment'],
    defaultMethod: 'Cash',
    allowPartialPayments: false,
    partialPaymentMessage: 'Quick Checkout requires a complete payment.',
  );

  static const assistedService = POSPaymentBehavior(
    paymentMethods: ['Cash', 'Debit Card', 'Mobile Payment', 'Bank Transfer'],
    defaultMethod: 'Debit Card',
  );

  String normalizeMethod(String? method) {
    if (paymentMethods.isEmpty) return defaultMethod;

    if (method != null && paymentMethods.contains(method)) {
      return method;
    }

    if (paymentMethods.contains(defaultMethod)) {
      return defaultMethod;
    }

    return paymentMethods.first;
  }

  bool allowsMethod(String method) {
    return paymentMethods.contains(method);
  }

  bool canOverpay(String method) {
    return isCashPaymentMethod(method);
  }

  List<TenderSuggestion> resolveTenderSuggestions({
    required double remainingAmount,
    required String method,
  }) {
    return resolveTenderSuggestionsForMethod(
      remainingAmount,
      method: method,
      includeCashRounds:
          includeCashRoundSuggestions && isCashPaymentMethod(method),
      denominations: cashDenominations,
    );
  }

  PaymentTenderEvaluation evaluateTender({
    required double amount,
    required double remainingAmount,
    required String method,
  }) {
    if (!allowsMethod(method)) {
      return PaymentTenderEvaluation(
        amount: amount,
        remainingAmount: remainingAmount,
        method: method,
        isValid: false,
        message: unavailableMethodMessage,
      );
    }

    final evaluation = evaluatePaymentTender(
      amount: amount,
      remainingAmount: remainingAmount,
      method: method,
    );
    if (!evaluation.isValid) return evaluation;

    if (!allowPartialPayments && evaluation.shortfall > 0) {
      return PaymentTenderEvaluation(
        amount: evaluation.amount,
        remainingAmount: evaluation.remainingAmount,
        method: evaluation.method,
        isValid: false,
        message: partialPaymentMessage,
      );
    }

    return evaluation;
  }
}
