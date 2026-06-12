import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_tax_profile.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_tax_benchmark_service.dart';

void main() {
  group('FinancialReportTaxBenchmarkService', () {
    const service = FinancialReportTaxBenchmarkService();

    test('calculates a flat corporate tax benchmark', () {
      final result = service.calculate(
        profile: FinancialReportTaxProfiles.standardCorporate,
        profitBeforeTax: 1000000000,
        grossTurnover: 10000000000,
      );

      expect(result.expectedTax, 220000000);
      expect(result.benchmarkRate, 0.22);
      expect(result.rateLabel, '22.0%');
      expect(result.facilityApplied, isFalse);
      expect(result.expectedTaxLineLabel, 'Expected tax expense at 22%');
    });

    test('calculates Article 31E proportionally from turnover', () {
      final result = service.calculate(
        profile: FinancialReportTaxProfiles.smallBusinessFacility,
        profitBeforeTax: 1000000000,
        grossTurnover: 10000000000,
      );

      expect(result.facilityApplied, isTrue);
      expect(result.eligibleTurnover, 4800000000);
      expect(result.eligibleTaxableIncome, 480000000);
      expect(result.standardTaxableIncome, 520000000);
      expect(result.discountedTax, 52800000);
      expect(result.standardTax, 114400000);
      expect(result.expectedTax, 167200000);
      expect(result.rateLabel, '16.7%');
      expect(
        result.expectedTaxLineLabel,
        'Expected tax expense at 16.7% blended',
      );
    });

    test('falls back to the standard rate above the Article 31E limit', () {
      final result = service.calculate(
        profile: FinancialReportTaxProfiles.smallBusinessFacility,
        profitBeforeTax: 1000000000,
        grossTurnover: 51000000000,
      );

      expect(result.facilityApplied, isFalse);
      expect(result.eligibleTaxableIncome, 0);
      expect(result.expectedTax, 220000000);
      expect(result.rateLabel, '22.0%');
      expect(result.methodLabel, 'Article 31E facility unavailable');
    });
  });
}
