import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_payment_behavior.dart';

void main() {
  test('standard payment behavior preserves current tender methods', () {
    const behavior = POSPaymentBehavior.standard;

    expect(behavior.paymentMethods, ['Cash', 'Debit Card', 'Mobile Payment']);
    expect(behavior.defaultMethod, 'Cash');
    expect(behavior.allowPartialPayments, isTrue);
    expect(behavior.normalizeMethod('Debit Card'), 'Debit Card');
  });

  test('quick checkout limits tender methods and requires final payment', () {
    const behavior = POSPaymentBehavior.quickCheckout;

    expect(behavior.paymentMethods, ['Cash', 'Mobile Payment']);
    expect(behavior.normalizeMethod('Debit Card'), 'Cash');

    final evaluation = behavior.evaluateTender(
      amount: 25000,
      remainingAmount: 50000,
      method: 'Cash',
    );

    expect(evaluation.isValid, isFalse);
    expect(evaluation.message, 'Quick Checkout requires a complete payment.');
  });

  test('payment behavior rejects methods outside the current mode', () {
    const behavior = POSPaymentBehavior.quickCheckout;

    final evaluation = behavior.evaluateTender(
      amount: 50000,
      remainingAmount: 50000,
      method: 'Debit Card',
    );

    expect(evaluation.isValid, isFalse);
    expect(evaluation.method, 'Debit Card');
    expect(evaluation.message, contains('not available'));
  });

  test('payment suggestions follow the active method policy', () {
    const behavior = POSPaymentBehavior.standard;

    final cashSuggestions = behavior.resolveTenderSuggestions(
      remainingAmount: 42500,
      method: 'Cash',
    );
    final mobileSuggestions = behavior.resolveTenderSuggestions(
      remainingAmount: 42500,
      method: 'Mobile Payment',
    );

    expect(cashSuggestions.map((suggestion) => suggestion.amount), [
      42500,
      50000,
      100000,
      200000,
      500000,
    ]);
    expect(mobileSuggestions, hasLength(1));
    expect(mobileSuggestions.single.label, 'Exact');
  });

  test('assisted service adds transfer as a supported tender method', () {
    const behavior = POSPaymentBehavior.assistedService;

    expect(behavior.defaultMethod, 'Debit Card');
    expect(behavior.paymentMethods, contains('Bank Transfer'));
    expect(
      behavior
          .evaluateTender(
            amount: 100000,
            remainingAmount: 100000,
            method: 'Bank Transfer',
          )
          .isValid,
      isTrue,
    );
  });
}
