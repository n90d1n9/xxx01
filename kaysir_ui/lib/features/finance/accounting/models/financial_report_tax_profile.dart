enum FinancialReportTaxBenchmarkMethod { flatRate, article31eFacility }

class FinancialReportTaxProfile {
  final String id;
  final String label;
  final String shortLabel;
  final double rate;
  final String description;
  final String standardReference;
  final String taxReference;
  final FinancialReportTaxBenchmarkMethod benchmarkMethod;

  const FinancialReportTaxProfile({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.rate,
    required this.description,
    required this.standardReference,
    required this.taxReference,
    this.benchmarkMethod = FinancialReportTaxBenchmarkMethod.flatRate,
  });

  String get rateLabel => '${(rate * 100).toStringAsFixed(1)}%';

  String get compactRateLabel {
    final percentage = rate * 100;
    if ((percentage - percentage.roundToDouble()).abs() < 0.01) {
      return '${percentage.toStringAsFixed(0)}%';
    }
    return rateLabel;
  }
}

abstract final class FinancialReportTaxProfiles {
  static const standardCorporateRate = 0.22;
  static const article31eTurnoverLimit = 50000000000.0;
  static const article31eEligibleTurnoverCap = 4800000000.0;
  static const article31eDiscountMultiplier = 0.5;

  static const standardCorporate = FinancialReportTaxProfile(
    id: 'standard-pph-badan',
    label: 'Standard PPh Badan',
    shortLabel: 'PPh Badan 22%',
    rate: standardCorporateRate,
    description: 'Default Indonesian corporate income tax benchmark.',
    standardReference: 'PSAK 212',
    taxReference: 'Standard corporate income tax benchmark',
  );

  static const publicCompanyReduced = FinancialReportTaxProfile(
    id: 'public-company-reduced',
    label: 'Public-company reduced benchmark',
    shortLabel: 'Listed 19%',
    rate: 0.19,
    description:
        'Benchmark for public companies that meet the listed-company rate reduction conditions.',
    standardReference: 'PSAK 212',
    taxReference: 'Listed-company corporate income tax discount benchmark',
  );

  static const smallBusinessFacility = FinancialReportTaxProfile(
    id: 'small-business-facility',
    label: 'SME eligible-portion benchmark',
    shortLabel: 'Eligible 11%',
    rate: 0.11,
    description:
        'Benchmark for the eligible income portion receiving a 50% rate reduction, not a blanket entity rate.',
    standardReference: 'PSAK 212',
    taxReference: 'Article 31E eligible-portion facility benchmark',
    benchmarkMethod: FinancialReportTaxBenchmarkMethod.article31eFacility,
  );

  static const values = [
    standardCorporate,
    publicCompanyReduced,
    smallBusinessFacility,
  ];

  static FinancialReportTaxProfile byId(String id) {
    for (final profile in values) {
      if (profile.id == id) {
        return profile;
      }
    }
    return standardCorporate;
  }
}
