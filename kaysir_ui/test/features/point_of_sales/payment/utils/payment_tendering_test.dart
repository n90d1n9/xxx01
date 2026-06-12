import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/payment/utils/payment_tendering.dart';

void main() {
  group('resolveTenderSuggestions', () {
    test('includes exact amount before cash rounds', () {
      final suggestions = resolveTenderSuggestions(27500);

      expect(suggestions.first.label, 'Exact');
      expect(suggestions.first.amount, 27500);
      expect(suggestions.first.isExact, isTrue);
      expect(suggestions.map((suggestion) => suggestion.amount), [
        27500,
        50000,
        100000,
        200000,
        500000,
      ]);
    });

    test('deduplicates exact amount when it matches a denomination', () {
      final suggestions = resolveTenderSuggestions(50000);

      expect(suggestions.map((suggestion) => suggestion.amount), [
        50000,
        100000,
        200000,
        500000,
      ]);
    });

    test('can return exact-only suggestions for non-cash methods', () {
      final suggestions = resolveTenderSuggestions(
        42500,
        includeCashRounds: false,
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.label, 'Exact');
      expect(suggestions.single.amount, 42500);
    });

    test('method-aware suggestions only round cash tenders', () {
      final suggestions = resolveTenderSuggestionsForMethod(
        42500,
        method: 'Mobile Payment',
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.amount, 42500);
    });
  });

  group('evaluatePaymentTender', () {
    test('allows cash overpay and reports change due', () {
      final evaluation = evaluatePaymentTender(
        amount: 50000,
        remainingAmount: 42000,
        method: 'Cash',
      );

      expect(evaluation.isValid, isTrue);
      expect(evaluation.changeDue, 8000);
      expect(evaluation.shortfall, 0);
      expect(evaluation.completesOrder, isTrue);
    });

    test('rejects non-cash overpay', () {
      final evaluation = evaluatePaymentTender(
        amount: 50000,
        remainingAmount: 42000,
        method: 'Debit Card',
      );

      expect(evaluation.isValid, isFalse);
      expect(evaluation.message, contains('Non-cash'));
    });

    test('allows partial payments and reports shortfall', () {
      final evaluation = evaluatePaymentTender(
        amount: 25000,
        remainingAmount: 42000,
        method: 'Mobile Payment',
      );

      expect(evaluation.isValid, isTrue);
      expect(evaluation.shortfall, 17000);
      expect(evaluation.changeDue, 0);
      expect(evaluation.completesOrder, isFalse);
    });

    test('rejects empty or already-paid tenders', () {
      expect(
        evaluatePaymentTender(
          amount: 0,
          remainingAmount: 42000,
          method: 'Cash',
        ).isValid,
        isFalse,
      );

      expect(
        evaluatePaymentTender(
          amount: 10000,
          remainingAmount: 0,
          method: 'Cash',
        ).isValid,
        isFalse,
      );
    });
  });

  test('formatPaymentAmountInput keeps integer money tidy', () {
    expect(formatPaymentAmountInput(50000), '50000');
    expect(formatPaymentAmountInput(12500.5), '12500.50');
  });
}
