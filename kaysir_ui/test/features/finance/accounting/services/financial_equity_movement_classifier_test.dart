import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/services/financial_equity_movement_classifier.dart';

void main() {
  group('FinancialEquityMovementClassifier', () {
    const classifier = FinancialEquityMovementClassifier();

    test('separates capital, distributions, OCI, and retained earnings', () {
      final summary = classifier.summarize([
        _entry(
          name: 'Owner Capital',
          category: '3000 - Owner Capital',
          amount: 1000,
          sourceCategory: 'Modal disetor',
        ),
        _entry(
          name: 'Owner Drawings',
          category: '3001 - Owner Drawings',
          amount: -150,
          sourceCategory: 'Prive',
        ),
        _entry(
          name: 'Revaluation Reserve OCI',
          category: '3300 - Revaluation Reserve',
          amount: 75,
        ),
        _entry(
          name: 'Retained Earnings',
          category: '3000 - Retained Earnings',
          amount: 500,
          sourceCategory: 'Period Close',
        ),
        _entry(
          name: 'Foreign Currency Translation Reserve',
          category: '3400 - Translation Reserve',
          amount: -25,
        ),
      ]);

      expect(summary.ownerContributions, 1000);
      expect(summary.ownerDistributions, 150);
      expect(summary.otherComprehensiveIncome, 75);
      expect(summary.retainedEarningsTransfers, 500);
      expect(summary.otherReserveMovements, -25);
      expect(summary.netMovement, 1400);
    });

    test('does not treat OCI reserves as owner contributions', () {
      final ociEntry = _entry(
        name: 'OCI Revaluation Reserve',
        category: '3000 - OCI Reserve',
        amount: 80,
      );

      expect(
        classifier.classify(ociEntry),
        FinancialEquityMovementType.otherComprehensiveIncome,
      );
    });
  });
}

FinancialEntry _entry({
  required String name,
  required String category,
  required double amount,
  String? sourceCategory,
}) {
  return FinancialEntry(
    name: name,
    amount: amount,
    date: DateTime(2026, 1, 1),
    category: category,
    type: 'equity',
    sourceCategory: sourceCategory,
  );
}
