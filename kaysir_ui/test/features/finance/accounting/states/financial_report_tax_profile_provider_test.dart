import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_tax_profile.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_pack_provider.dart';

void main() {
  group('Financial report tax profile provider', () {
    test('feeds the selected profile into the report pack service', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(financialReportPackServiceProvider).taxProfile,
        FinancialReportTaxProfiles.standardCorporate,
      );

      container.read(selectedFinancialReportTaxProfileProvider.notifier).state =
          FinancialReportTaxProfiles.smallBusinessFacility;

      expect(
        container.read(financialReportPackServiceProvider).taxProfile,
        FinancialReportTaxProfiles.smallBusinessFacility,
      );
    });
  });
}
