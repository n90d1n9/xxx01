import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_domain_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';

void main() {
  test('DomainPackContractDomainFilterSummary builds domain options', () {
    final summary = _standardSummary();
    final options = domainPackContractDomainFilterOptions(summary);

    expect(summary.contractCount, 3);
    expect(options.map((option) => option.menuLabel), [
      'All domains · 3 contracts',
      'Commerce · 1 contract',
      'Construction · 1 contract',
      'Digital subscriptions · 1 contract',
    ]);
  });

  test('DomainPackContractDomainFilterSummary filters reports by domain', () {
    final summary = _standardSummary();
    final reports = summary.reportsFor(
      DomainPackContractDomainFilterSelection.domain('construction'),
    );

    expect(reports.map((report) => report.domainKey), ['construction']);
    expect(reports.single.domainLabel, 'Construction');
  });

  test('DomainPackContractDomainFilterSelection resolves stale domains', () {
    final summary = _standardSummary();

    expect(
      DomainPackContractDomainFilterSelection.domain(
        'unknown',
      ).resolveFor(summary),
      const DomainPackContractDomainFilterSelection.all(),
    );
  });
}

DomainPackContractDomainFilterSummary _standardSummary() {
  return DomainPackContractDomainFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
  );
}
