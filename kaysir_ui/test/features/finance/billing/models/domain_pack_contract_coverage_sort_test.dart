import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_sort.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';

void main() {
  test('sortDomainPackContractCoverageReports preserves registry order', () {
    final reports = _reorderedReports();

    expect(
      sortDomainPackContractCoverageReports(
        reports,
      ).map((report) => report.domainKey),
      ['digital', 'commerce', 'construction'],
    );
  });

  test('sortDomainPackContractCoverageReports sorts by domain label', () {
    final reports = _reorderedReports();

    expect(
      sortDomainPackContractCoverageReports(
        reports,
        sort: DomainPackContractCoverageSort.domain,
      ).map((report) => report.domainKey),
      ['commerce', 'construction', 'digital'],
    );
  });

  test('sortDomainPackContractCoverageReports prioritizes attention', () {
    final readyReport = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    );
    final blockedReport = DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
      hasTenant: false,
    );
    final reports = [
      readyReport.requireReportForDomain('construction'),
      blockedReport.requireReportForDomain('commerce'),
    ];

    expect(
      sortDomainPackContractCoverageReports(
        reports,
        sort: DomainPackContractCoverageSort.attention,
      ).map((report) => report.domainKey),
      ['commerce', 'construction'],
    );
  });
}

List<DomainPackContractReport> _reorderedReports() {
  final report = DomainPackContractRegistryReport.forRegistry(
    standardBillingDomainPackRegistry(),
  );

  return [
    report.requireReportForDomain('digital'),
    report.requireReportForDomain('commerce'),
    report.requireReportForDomain('construction'),
  ];
}
