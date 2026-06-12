import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_materiality_service.dart';

void main() {
  group('FinancialReportMaterialityService', () {
    const service = FinancialReportMaterialityService();

    test('selects the conservative positive reporting benchmark', () {
      final assessment = service.assess(
        position: _statement([
          const FinancialReportLine(label: 'Total assets', amount: 4400),
        ]),
        profitOrLoss: _statement([
          const FinancialReportLine(label: 'Total revenue', amount: 5000),
          const FinancialReportLine(
            label: 'Profit (loss) before tax',
            amount: 3700,
          ),
        ]),
      );

      expect(assessment.basis, '1% of total assets');
      expect(assessment.threshold, 44);
      expect(assessment.isMaterialAmount(45), isTrue);
      expect(assessment.isMaterialAmount(40), isFalse);
    });

    test('falls back to the minimum threshold when benchmarks are empty', () {
      const service = FinancialReportMaterialityService(minimumThreshold: 25);

      final assessment = service.assess(
        position: _statement(const []),
        profitOrLoss: _statement(const []),
      );

      expect(assessment.basis, 'Minimum review threshold');
      expect(assessment.threshold, 25);
      expect(assessment.isMaterialVariance(variance: 26), isTrue);
      expect(assessment.isMaterialVariance(comparativeVariance: -20), isFalse);
    });
  });
}

FinancialReportStatement _statement(List<FinancialReportLine> lines) {
  return FinancialReportStatement(
    kind: FinancialReportStatementKind.financialPosition,
    title: 'Statement',
    subtitle: 'For test',
    lines: lines,
  );
}
