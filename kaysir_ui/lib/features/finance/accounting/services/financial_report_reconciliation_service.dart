import '../models/financial_report_pack.dart';

class FinancialReportReconciliationCheck {
  final String id;
  final String title;
  final String description;
  final String standardReference;
  final double variance;
  final double? comparativeVariance;

  const FinancialReportReconciliationCheck({
    required this.id,
    required this.title,
    required this.description,
    required this.standardReference,
    required this.variance,
    this.comparativeVariance,
  });

  bool isSatisfied({
    double tolerance = FinancialReportReconciliationService.eps,
  }) {
    final comparativeVariance = this.comparativeVariance;
    return variance.abs() < tolerance &&
        (comparativeVariance == null || comparativeVariance.abs() < tolerance);
  }
}

class FinancialReportReconciliationService {
  static const eps = 0.01;

  const FinancialReportReconciliationService();

  List<FinancialReportReconciliationCheck> buildChecks({
    required FinancialReportStatement position,
    required FinancialReportStatement profitOrLoss,
    required FinancialReportStatement changesInEquity,
    required FinancialReportStatement cashFlows,
  }) {
    return [
      FinancialReportReconciliationCheck(
        id: 'position-equation',
        title: 'Financial position reconciles',
        description: 'Total assets equal total liabilities plus equity.',
        standardReference: 'PSAK 201',
        variance:
            _amountFor(position, 'Total assets') -
            _amountFor(position, 'Total liabilities and equity'),
        comparativeVariance:
            _comparativeAmountFor(position, 'Total assets') -
            _comparativeAmountFor(position, 'Total liabilities and equity'),
      ),
      FinancialReportReconciliationCheck(
        id: 'cash-reconciliation',
        title: 'Cash flow reconciles to ending cash',
        description:
            'Beginning cash plus net cash flow equals ending cash and cash equivalents.',
        standardReference: 'PSAK 207',
        variance:
            _amountFor(
              cashFlows,
              'Cash and cash equivalents at beginning of period',
            ) +
            _amountFor(
              cashFlows,
              'Net increase (decrease) in cash and cash equivalents',
            ) -
            _amountFor(cashFlows, 'Cash and cash equivalents at end of period'),
        comparativeVariance:
            _comparativeAmountFor(
              cashFlows,
              'Cash and cash equivalents at beginning of period',
            ) +
            _comparativeAmountFor(
              cashFlows,
              'Net increase (decrease) in cash and cash equivalents',
            ) -
            _comparativeAmountFor(
              cashFlows,
              'Cash and cash equivalents at end of period',
            ),
      ),
      FinancialReportReconciliationCheck(
        id: 'equity-roll-forward',
        title: 'Equity roll-forward reconciles',
        description:
            'Opening equity plus current-period equity movements equals ending equity.',
        standardReference: 'PSAK 201',
        variance: _equityRollForwardVariance(
          changesInEquity,
          comparative: false,
        ),
        comparativeVariance: _equityRollForwardVariance(
          changesInEquity,
          comparative: true,
        ),
      ),
      FinancialReportReconciliationCheck(
        id: 'comprehensive-income-tie-out',
        title: 'Profit and OCI tie to equity',
        description:
            'Profit or loss and OCI in the equity statement agree to the profit or loss and OCI statement.',
        standardReference: 'PSAK 201',
        variance:
            _amountFor(changesInEquity, 'Profit (loss) for the period') -
            _amountFor(profitOrLoss, 'Profit (loss) for the period') +
            _amountFor(changesInEquity, 'Other comprehensive income') -
            _amountFor(profitOrLoss, 'Other comprehensive income'),
        comparativeVariance:
            _comparativeAmountFor(
              changesInEquity,
              'Profit (loss) for the period',
            ) -
            _comparativeAmountFor(
              profitOrLoss,
              'Profit (loss) for the period',
            ) +
            _comparativeAmountFor(
              changesInEquity,
              'Other comprehensive income',
            ) -
            _comparativeAmountFor(profitOrLoss, 'Other comprehensive income'),
      ),
    ];
  }

  double _equityRollForwardVariance(
    FinancialReportStatement statement, {
    required bool comparative,
  }) {
    double amount(String label) {
      return comparative
          ? _comparativeAmountFor(statement, label)
          : _amountFor(statement, label);
    }

    final movements = [
      'Owner contributions',
      'Owner distributions',
      'Profit (loss) for the period',
      'Other comprehensive income',
      'Retained earnings closing transfers',
      'Other equity reserve movements',
      'Other equity movements / closing entries',
    ].fold(0.0, (sum, label) => sum + amount(label));
    return amount('Opening equity') + movements - amount('Ending equity');
  }

  double _amountFor(FinancialReportStatement statement, String label) {
    return _lineFor(statement, label)?.amount ?? 0;
  }

  double _comparativeAmountFor(
    FinancialReportStatement statement,
    String label,
  ) {
    return _lineFor(statement, label)?.comparativeAmount ?? 0;
  }

  FinancialReportLine? _lineFor(
    FinancialReportStatement statement,
    String label,
  ) {
    for (final line in statement.lines) {
      if (line.label == label) {
        return line;
      }
    }
    return null;
  }
}
