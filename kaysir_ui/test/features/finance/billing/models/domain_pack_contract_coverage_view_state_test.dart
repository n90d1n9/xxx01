import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_filter.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_sort.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_coverage_view_state.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_domain_filter.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/domain_pack_contract.dart';

void main() {
  test('DomainPackContractCoverageViewState resolves default scope', () {
    final viewState = _standardViewState();

    expect(viewState.hasActiveFilters, isFalse);
    expect(viewState.hasActiveControls, isFalse);
    expect(viewState.sort, DomainPackContractCoverageSort.registry);
    expect(viewState.resultCount, 3);
    expect(
      viewState.scopeSummaryLabel,
      'All domains · All contracts · 3 contracts',
    );
    expect(viewState.visibleReports(2).map((report) => report.domainKey), [
      'commerce',
      'construction',
    ]);
    expect(viewState.hiddenCountAfter(2), 1);
  });

  test(
    'DomainPackContractCoverageViewState resolves domain and status scope',
    () {
      final viewState = _standardViewState(
        domainSelection: DomainPackContractDomainFilterSelection.domain(
          'construction',
        ),
        filter: DomainPackContractCoverageFilter.hardening,
      );

      expect(viewState.hasActiveFilters, isTrue);
      expect(viewState.hasActiveControls, isTrue);
      expect(viewState.domainLabel, 'Construction');
      expect(viewState.filterLabel, 'Hardening');
      expect(viewState.resultCount, 1);
      expect(
        viewState.scopeSummaryLabel,
        'Construction · Hardening · 1 contract',
      );
      expect(viewState.filteredReports.single.domainKey, 'construction');
    },
  );

  test(
    'DomainPackContractCoverageViewState preserves zero filters on request',
    () {
      final viewState = _standardViewState(
        filter: DomainPackContractCoverageFilter.complete,
        showZeroFilters: true,
      );

      expect(viewState.filter, DomainPackContractCoverageFilter.complete);
      expect(viewState.resultCount, 0);
      expect(
        viewState.scopeSummaryLabel,
        'All domains · Complete · 0 contracts',
      );
      expect(
        viewState.emptyLabel,
        'No fully specified domain-pack contracts yet.',
      );
    },
  );

  test('DomainPackContractCoverageViewState resolves sort scope', () {
    final viewState = _standardViewState(
      sort: DomainPackContractCoverageSort.domain,
    );

    expect(viewState.hasActiveFilters, isFalse);
    expect(viewState.hasActiveControls, isTrue);
    expect(viewState.sortLabel, 'Domain name');
    expect(
      viewState.scopeSummaryLabel,
      'All domains · All contracts · Domain name · 3 contracts',
    );
    expect(viewState.visibleReports(3).map((report) => report.domainKey), [
      'commerce',
      'construction',
      'digital',
    ]);
  });
}

DomainPackContractCoverageViewState _standardViewState({
  DomainPackContractDomainFilterSelection domainSelection =
      const DomainPackContractDomainFilterSelection.all(),
  DomainPackContractCoverageFilter filter =
      DomainPackContractCoverageFilter.all,
  DomainPackContractCoverageSort sort = DomainPackContractCoverageSort.registry,
  bool showZeroFilters = false,
}) {
  return DomainPackContractCoverageViewState.resolve(
    report: DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
    domainSelection: domainSelection,
    filter: filter,
    sort: sort,
    showZeroFilters: showZeroFilters,
  );
}
