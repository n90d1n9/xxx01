import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';

void main() {
  test('DomainPackContractCoverageFilterSummary counts standard contracts', () {
    final summary = _standardSummary();

    expect(summary.totalCount, 3);
    expect(summary.blockedCount, 0);
    expect(summary.hardeningCount, 3);
    expect(summary.completeCount, 0);
    expect(summary.reportsFor(DomainPackContractCoverageFilter.all).length, 3);
    expect(
      summary.reportsFor(DomainPackContractCoverageFilter.hardening).length,
      3,
    );
    expect(
      summary.reportsFor(DomainPackContractCoverageFilter.complete),
      isEmpty,
    );
  });

  test('DomainPackContractCoverageFilter resolves unavailable filters', () {
    final summary = _standardSummary();

    expect(
      DomainPackContractCoverageFilter.complete.resolveFor(summary),
      DomainPackContractCoverageFilter.all,
    );
    expect(
      DomainPackContractCoverageFilter.complete.resolveFor(
        summary,
        showZeroFilters: true,
      ),
      DomainPackContractCoverageFilter.complete,
    );
  });

  test(
    'domainPackContractCoverageFilterOptions hides zero filters by default',
    () {
      final summary = _standardSummary();

      expect(domainPackContractCoverageFilterOptions(summary), [
        DomainPackContractCoverageFilter.all,
        DomainPackContractCoverageFilter.hardening,
      ]);
      expect(
        domainPackContractCoverageFilterOptions(summary, showZeroFilters: true),
        DomainPackContractCoverageFilter.values,
      );
    },
  );
}

DomainPackContractCoverageFilterSummary _standardSummary() {
  return DomainPackContractCoverageFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
  );
}
