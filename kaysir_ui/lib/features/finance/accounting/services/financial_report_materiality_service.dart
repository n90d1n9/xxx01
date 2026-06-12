import '../models/financial_report_pack.dart';

class FinancialReportMaterialityAssessment {
  final double threshold;
  final String basis;
  final double benchmarkAmount;
  final double rate;

  const FinancialReportMaterialityAssessment({
    required this.threshold,
    required this.basis,
    required this.benchmarkAmount,
    required this.rate,
  });

  bool isMaterialAmount(double? amount) {
    if (amount == null || threshold <= 0) {
      return false;
    }
    return amount.abs() > threshold;
  }

  bool isMaterialVariance({double? variance, double? comparativeVariance}) {
    return isMaterialAmount(variance) || isMaterialAmount(comparativeVariance);
  }
}

class FinancialReportMaterialityService {
  static const _eps = 0.01;

  final double totalAssetsRate;
  final double totalRevenueRate;
  final double profitBeforeTaxRate;
  final double minimumThreshold;

  const FinancialReportMaterialityService({
    this.totalAssetsRate = 0.01,
    this.totalRevenueRate = 0.01,
    this.profitBeforeTaxRate = 0.05,
    this.minimumThreshold = 1,
  });

  FinancialReportMaterialityAssessment assess({
    required FinancialReportStatement position,
    required FinancialReportStatement profitOrLoss,
  }) {
    final candidates =
        [
            _candidate(
              basis: '${_rateLabel(totalAssetsRate)} of total assets',
              benchmarkAmount: _amountFor(position, 'Total assets'),
              rate: totalAssetsRate,
            ),
            _candidate(
              basis: '${_rateLabel(totalRevenueRate)} of total revenue',
              benchmarkAmount: _amountFor(profitOrLoss, 'Total revenue'),
              rate: totalRevenueRate,
            ),
            _candidate(
              basis:
                  '${_rateLabel(profitBeforeTaxRate)} of profit (loss) before tax',
              benchmarkAmount: _amountFor(
                profitOrLoss,
                'Profit (loss) before tax',
              ),
              rate: profitBeforeTaxRate,
            ),
          ].whereType<FinancialReportMaterialityAssessment>().toList()
          ..sort((a, b) => a.threshold.compareTo(b.threshold));

    if (candidates.isEmpty) {
      return FinancialReportMaterialityAssessment(
        threshold: minimumThreshold,
        basis: 'Minimum review threshold',
        benchmarkAmount: minimumThreshold,
        rate: 1,
      );
    }

    return candidates.first;
  }

  FinancialReportMaterialityAssessment? _candidate({
    required String basis,
    required double benchmarkAmount,
    required double rate,
  }) {
    if (benchmarkAmount.abs() < _eps || rate <= 0) {
      return null;
    }
    final calculatedThreshold = benchmarkAmount.abs() * rate;
    return FinancialReportMaterialityAssessment(
      threshold:
          calculatedThreshold < minimumThreshold
              ? minimumThreshold
              : calculatedThreshold,
      basis: basis,
      benchmarkAmount: benchmarkAmount,
      rate: rate,
    );
  }

  double _amountFor(FinancialReportStatement statement, String label) {
    for (final line in statement.lines) {
      if (line.label == label) {
        return line.amount ?? 0;
      }
    }
    return 0;
  }

  String _rateLabel(double rate) {
    final percent = rate * 100;
    if ((percent - percent.round()).abs() < 0.001) {
      return '${percent.round()}%';
    }
    return '${percent.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}%';
  }
}
