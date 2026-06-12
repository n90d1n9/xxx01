import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_reconciliation_service.dart';

void main() {
  group('FinancialReportReconciliationService', () {
    const service = FinancialReportReconciliationService();

    test('passes when primary statements cross-check', () {
      final checks = service.buildChecks(
        position: _position(totalAssets: 100, liabilitiesAndEquity: 100),
        profitOrLoss: _profitOrLoss(profit: 30, oci: 5),
        changesInEquity: _changesInEquity(endingEquity: 100),
        cashFlows: _cashFlows(
          beginningCash: 10,
          netCashFlow: 5,
          endingCash: 15,
        ),
      );

      expect(checks.map((check) => check.id), [
        'position-equation',
        'cash-reconciliation',
        'equity-roll-forward',
        'comprehensive-income-tie-out',
      ]);
      expect(checks.every((check) => check.isSatisfied()), isTrue);
    });

    test('flags equity roll-forward variances', () {
      final checks = service.buildChecks(
        position: _position(totalAssets: 100, liabilitiesAndEquity: 100),
        profitOrLoss: _profitOrLoss(profit: 30, oci: 5),
        changesInEquity: _changesInEquity(endingEquity: 101),
        cashFlows: _cashFlows(
          beginningCash: 10,
          netCashFlow: 5,
          endingCash: 15,
        ),
      );

      final equityCheck = checks.singleWhere(
        (check) => check.id == 'equity-roll-forward',
      );

      expect(equityCheck.variance, -1);
      expect(equityCheck.isSatisfied(), isFalse);
    });

    test('flags profit and OCI tie-out variances', () {
      final checks = service.buildChecks(
        position: _position(totalAssets: 100, liabilitiesAndEquity: 100),
        profitOrLoss: _profitOrLoss(profit: 30, oci: 5),
        changesInEquity: _changesInEquity(profit: 29, oci: 5, endingEquity: 99),
        cashFlows: _cashFlows(
          beginningCash: 10,
          netCashFlow: 5,
          endingCash: 15,
        ),
      );

      final tieOut = checks.singleWhere(
        (check) => check.id == 'comprehensive-income-tie-out',
      );

      expect(tieOut.variance, -1);
      expect(tieOut.isSatisfied(), isFalse);
    });
  });
}

FinancialReportStatement _position({
  required double totalAssets,
  required double liabilitiesAndEquity,
}) {
  return _statement(FinancialReportStatementKind.financialPosition, [
    _line('Total assets', totalAssets),
    _line('Total liabilities and equity', liabilitiesAndEquity),
  ]);
}

FinancialReportStatement _profitOrLoss({
  required double profit,
  required double oci,
}) {
  return _statement(FinancialReportStatementKind.profitOrLossAndOci, [
    _line('Profit (loss) for the period', profit),
    _line('Other comprehensive income', oci),
  ]);
}

FinancialReportStatement _changesInEquity({
  double profit = 30,
  double oci = 5,
  required double endingEquity,
}) {
  return _statement(FinancialReportStatementKind.changesInEquity, [
    _line('Opening equity', 50),
    _line('Owner contributions', 20),
    _line('Owner distributions', -10),
    _line('Profit (loss) for the period', profit),
    _line('Other comprehensive income', oci),
    _line('Retained earnings closing transfers', 0),
    _line('Other equity reserve movements', 0),
    _line('Other equity movements / closing entries', 5),
    _line('Ending equity', endingEquity),
  ]);
}

FinancialReportStatement _cashFlows({
  required double beginningCash,
  required double netCashFlow,
  required double endingCash,
}) {
  return _statement(FinancialReportStatementKind.cashFlows, [
    _line('Cash and cash equivalents at beginning of period', beginningCash),
    _line('Net increase (decrease) in cash and cash equivalents', netCashFlow),
    _line('Cash and cash equivalents at end of period', endingCash),
  ]);
}

FinancialReportStatement _statement(
  FinancialReportStatementKind kind,
  List<FinancialReportLine> lines,
) {
  return FinancialReportStatement(
    kind: kind,
    title: kind.label,
    subtitle: '',
    lines: lines,
  );
}

FinancialReportLine _line(String label, double amount) {
  return FinancialReportLine(
    label: label,
    amount: amount,
    comparativeAmount: 0,
  );
}
