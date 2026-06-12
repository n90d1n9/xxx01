import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_vat_settlement_service.dart';

void main() {
  group('FinancialReportVatSettlementService', () {
    const service = FinancialReportVatSettlementService();

    test('ties input and output VAT to a recorded net payable', () {
      final summary = service.summarize(
        positionEntries: [
          FinancialEntry(
            name: 'Input VAT',
            amount: 110,
            date: DateTime(2026, 1, 31),
            category: '1300 - PPN Masukan',
            type: 'asset',
          ),
          FinancialEntry(
            name: 'Output VAT',
            amount: 330,
            date: DateTime(2026, 1, 31),
            category: '2400 - PPN Keluaran',
            type: 'liability',
          ),
          FinancialEntry(
            name: 'VAT Payable',
            amount: 220,
            date: DateTime(2026, 1, 31),
            category: '2410 - VAT Payable',
            type: 'liability',
          ),
        ],
      );

      expect(summary.inputVat, 110);
      expect(summary.outputVat, 330);
      expect(summary.expectedNetVatPayable, 220);
      expect(summary.recordedNetVatPosition, 220);
      expect(summary.settlementVariance, 0);
      expect(summary.inputVatLineCount, 1);
      expect(summary.outputVatLineCount, 1);
      expect(summary.settlementLineCount, 1);
      expect(summary.hasVatEvidence, isTrue);
    });

    test('separates VAT from income tax balances', () {
      final summary = service.summarize(
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
      );

      expect(summary.inputVat, 0);
      expect(summary.outputVat, 0);
      expect(summary.recordedNetVatPosition, 0);
      expect(summary.settlementVariance, 0);
      expect(summary.hasVatEvidence, isFalse);
    });
  });
}
