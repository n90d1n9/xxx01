import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_mapping.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_cash_roll_forward_service.dart';

void main() {
  group('FinancialReportCashRollForwardService', () {
    const service = FinancialReportCashRollForwardService();
    const mapper = FinancialReportLineMapper();

    test('ties opening cash and period movements to closing cash', () {
      final allEntries = [
        _entry(
          name: 'Bank BCA',
          amount: 1000,
          date: DateTime(2025, 12, 31),
          category: '1001 - Bank BCA',
        ),
        _entry(
          name: 'Bank BCA',
          amount: 500,
          date: DateTime(2026, 1, 15),
          category: '1001 - Bank BCA',
        ),
        _entry(
          name: 'Bank BCA',
          amount: -200,
          date: DateTime(2026, 1, 20),
          category: '1001 - Bank BCA',
        ),
      ];
      final periodEntries = allEntries.where(
        (entry) => !entry.date.isBefore(DateTime(2026, 1, 1)),
      );

      final summary = service.summarize(
        allEntries: allEntries,
        periodEntries: periodEntries,
        positionEntries: allEntries,
        lineMapper: mapper,
        periodStart: DateTime(2026, 1, 1),
      );

      expect(summary.openingCash, 1000);
      expect(summary.cashInflows, 500);
      expect(summary.cashOutflows, 200);
      expect(summary.netCashMovement, 300);
      expect(summary.calculatedClosingCash, 1300);
      expect(summary.reportedClosingCash, 1300);
      expect(summary.rollForwardVariance, 0);
      expect(summary.periodLineCount, 2);
      expect(summary.cashAccountCount, 1);
      expect(summary.hasCashEvidence, isTrue);
    });

    test('detects a closing cash roll-forward variance', () {
      final allEntries = [
        _entry(
          name: 'Bank BCA',
          amount: 1000,
          date: DateTime(2025, 12, 31),
          category: '1001 - Bank BCA',
        ),
        _entry(
          name: 'Bank BCA',
          amount: 500,
          date: DateTime(2026, 1, 15),
          category: '1001 - Bank BCA',
        ),
      ];

      final summary = service.summarize(
        allEntries: allEntries,
        periodEntries: allEntries.where(
          (entry) => !entry.date.isBefore(DateTime(2026, 1, 1)),
        ),
        positionEntries: allEntries.take(1),
        lineMapper: mapper,
        periodStart: DateTime(2026, 1, 1),
      );

      expect(summary.calculatedClosingCash, 1500);
      expect(summary.reportedClosingCash, 1000);
      expect(summary.rollForwardVariance, -500);
    });

    test('ignores non-cash assets', () {
      final summary = service.summarize(
        allEntries: [
          _entry(
            name: 'Accounts Receivable',
            amount: 300,
            date: DateTime(2026, 1, 31),
            category: '1100 - Accounts Receivable',
          ),
        ],
        periodEntries: const [],
        positionEntries: const [],
        lineMapper: mapper,
        periodStart: DateTime(2026, 1, 1),
      );

      expect(summary.hasCashEvidence, isFalse);
      expect(summary.reportedClosingCash, 0);
    });
  });
}

FinancialEntry _entry({
  required String name,
  required double amount,
  required DateTime date,
  required String category,
}) {
  return FinancialEntry(
    name: name,
    amount: amount,
    date: date,
    category: category,
    type: 'asset',
  );
}
