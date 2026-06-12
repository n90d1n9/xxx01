import '../models/financial_report_tax_profile.dart';

class FinancialReportTaxBenchmarkResult {
  final FinancialReportTaxProfile profile;
  final double profitBeforeTax;
  final double grossTurnover;
  final double expectedTax;
  final double benchmarkRate;
  final bool facilityApplied;
  final double eligibleTurnover;
  final double eligibleTaxableIncome;
  final double standardTaxableIncome;
  final double discountedTax;
  final double standardTax;
  final String methodLabel;

  const FinancialReportTaxBenchmarkResult({
    required this.profile,
    required this.profitBeforeTax,
    required this.grossTurnover,
    required this.expectedTax,
    required this.benchmarkRate,
    required this.facilityApplied,
    required this.eligibleTurnover,
    required this.eligibleTaxableIncome,
    required this.standardTaxableIncome,
    required this.discountedTax,
    required this.standardTax,
    required this.methodLabel,
  });

  bool get hasArticle31eEvidence {
    return profile.benchmarkMethod ==
        FinancialReportTaxBenchmarkMethod.article31eFacility;
  }

  String get rateLabel => _rateLabel(benchmarkRate);

  String get expectedTaxLineLabel {
    if (!hasArticle31eEvidence) {
      return 'Expected tax expense at ${profile.compactRateLabel}';
    }
    if (facilityApplied) {
      return 'Expected tax expense at $rateLabel blended';
    }
    return 'Expected tax expense at ${profile.compactRateLabel} profile';
  }

  static String _rateLabel(double rate) {
    return '${(rate * 100).toStringAsFixed(1)}%';
  }
}

class FinancialReportTaxBenchmarkService {
  const FinancialReportTaxBenchmarkService();

  FinancialReportTaxBenchmarkResult calculate({
    required FinancialReportTaxProfile profile,
    required double profitBeforeTax,
    required double grossTurnover,
  }) {
    switch (profile.benchmarkMethod) {
      case FinancialReportTaxBenchmarkMethod.flatRate:
        return _flatRate(
          profile: profile,
          profitBeforeTax: profitBeforeTax,
          grossTurnover: grossTurnover,
        );
      case FinancialReportTaxBenchmarkMethod.article31eFacility:
        return _article31eFacility(
          profile: profile,
          profitBeforeTax: profitBeforeTax,
          grossTurnover: grossTurnover,
        );
    }
  }

  FinancialReportTaxBenchmarkResult _flatRate({
    required FinancialReportTaxProfile profile,
    required double profitBeforeTax,
    required double grossTurnover,
  }) {
    return FinancialReportTaxBenchmarkResult(
      profile: profile,
      profitBeforeTax: profitBeforeTax,
      grossTurnover: grossTurnover,
      expectedTax: profitBeforeTax * profile.rate,
      benchmarkRate: profile.rate,
      facilityApplied: false,
      eligibleTurnover: 0,
      eligibleTaxableIncome: 0,
      standardTaxableIncome: profitBeforeTax,
      discountedTax: 0,
      standardTax: profitBeforeTax * profile.rate,
      methodLabel: 'Flat corporate income tax benchmark',
    );
  }

  FinancialReportTaxBenchmarkResult _article31eFacility({
    required FinancialReportTaxProfile profile,
    required double profitBeforeTax,
    required double grossTurnover,
  }) {
    final turnover = grossTurnover.abs();
    final taxableIncome = profitBeforeTax <= 0 ? 0.0 : profitBeforeTax;
    final isEligible =
        taxableIncome > 0 &&
        turnover > 0 &&
        turnover <= FinancialReportTaxProfiles.article31eTurnoverLimit;

    if (!isEligible) {
      final expectedTax =
          profitBeforeTax <= 0
              ? 0.0
              : profitBeforeTax *
                  FinancialReportTaxProfiles.standardCorporateRate;
      return FinancialReportTaxBenchmarkResult(
        profile: profile,
        profitBeforeTax: profitBeforeTax,
        grossTurnover: grossTurnover,
        expectedTax: expectedTax,
        benchmarkRate:
            profitBeforeTax.abs() < 0.01
                ? 0
                : expectedTax / profitBeforeTax.abs(),
        facilityApplied: false,
        eligibleTurnover: 0,
        eligibleTaxableIncome: 0,
        standardTaxableIncome: taxableIncome,
        discountedTax: 0,
        standardTax: expectedTax,
        methodLabel: 'Article 31E facility unavailable',
      );
    }

    final eligibleTurnover =
        turnover < FinancialReportTaxProfiles.article31eEligibleTurnoverCap
            ? turnover
            : FinancialReportTaxProfiles.article31eEligibleTurnoverCap;
    final eligibleRatio = eligibleTurnover / turnover;
    final eligibleTaxableIncome = taxableIncome * eligibleRatio;
    final standardTaxableIncome = taxableIncome - eligibleTaxableIncome;
    final discountedTax =
        eligibleTaxableIncome *
        FinancialReportTaxProfiles.standardCorporateRate *
        FinancialReportTaxProfiles.article31eDiscountMultiplier;
    final standardTax =
        standardTaxableIncome *
        FinancialReportTaxProfiles.standardCorporateRate;
    final expectedTax = discountedTax + standardTax;

    return FinancialReportTaxBenchmarkResult(
      profile: profile,
      profitBeforeTax: profitBeforeTax,
      grossTurnover: grossTurnover,
      expectedTax: expectedTax,
      benchmarkRate:
          taxableIncome.abs() < 0.01 ? 0 : expectedTax / taxableIncome,
      facilityApplied: true,
      eligibleTurnover: eligibleTurnover,
      eligibleTaxableIncome: eligibleTaxableIncome,
      standardTaxableIncome: standardTaxableIncome,
      discountedTax: discountedTax,
      standardTax: standardTax,
      methodLabel: 'Article 31E proportional facility benchmark',
    );
  }
}
