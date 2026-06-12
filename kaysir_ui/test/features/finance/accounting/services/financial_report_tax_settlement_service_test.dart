import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_mapping.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_tax_settlement_service.dart';

void main() {
  group('FinancialReportTaxSettlementService', () {
    const service = FinancialReportTaxSettlementService();
    const mapper = FinancialReportLineMapper();

    test('ties current tax expense to credits and payable', () {
      final summary = service.summarize(
        periodEntries: [
          FinancialEntry(
            name: 'Income Tax Expense',
            amount: 814,
            date: DateTime(2026, 1, 31),
            category: '5900 - Income Tax Expense',
            type: 'expense',
          ),
        ],
        positionEntries: [
          FinancialEntry(
            name: 'PPh 23 Withholding Credit',
            amount: 200,
            date: DateTime(2026, 1, 31),
            category: '1350 - Kredit Pajak',
            type: 'asset',
          ),
          FinancialEntry(
            name: 'Income Tax Payable',
            amount: 614,
            date: DateTime(2026, 1, 31),
            category: '2400 - Income Tax Payable',
            type: 'liability',
          ),
        ],
        lineMapper: mapper,
      );

      expect(summary.currentTaxExpense, 814);
      expect(summary.taxCreditsAndPrepayments, 200);
      expect(summary.recordedTaxPayable, 614);
      expect(summary.expectedTaxPayable, 614);
      expect(summary.settlementVariance, 0);
      expect(summary.hasSettlementEvidence, isTrue);
    });

    test('excludes VAT-only balances from income tax settlement', () {
      final summary = service.summarize(
        periodEntries: const [],
        positionEntries: [
          FinancialEntry(
            name: 'PPN Masukan',
            amount: 100,
            date: DateTime(2026, 1, 31),
            category: '1300 - VAT Input',
            type: 'asset',
          ),
          FinancialEntry(
            name: 'PPN Keluaran Payable',
            amount: 100,
            date: DateTime(2026, 1, 31),
            category: '2400 - VAT Payable',
            type: 'liability',
          ),
        ],
        lineMapper: mapper,
      );

      expect(summary.taxCreditsAndPrepayments, 0);
      expect(summary.recordedTaxPayable, 0);
      expect(summary.hasSettlementEvidence, isFalse);
    });
  });
}
