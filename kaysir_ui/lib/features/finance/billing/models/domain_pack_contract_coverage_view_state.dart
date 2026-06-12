import '../utils/domain_pack_contract.dart';
import 'domain_pack_contract_coverage_filter.dart';
import 'domain_pack_contract_coverage_sort.dart';
import 'domain_pack_contract_domain_filter.dart';

/// Resolved view state for billing domain-pack contract coverage.
class DomainPackContractCoverageViewState {
  final DomainPackContractRegistryReport report;
  final DomainPackContractDomainFilterSummary domainSummary;
  final DomainPackContractDomainFilterSelection domainSelection;
  final DomainPackContractCoverageFilterSummary filterSummary;
  final DomainPackContractCoverageFilter filter;
  final DomainPackContractCoverageSort sort;
  final List<DomainPackContractReport> filteredReports;

  DomainPackContractCoverageViewState({
    required this.report,
    required this.domainSummary,
    required this.domainSelection,
    required this.filterSummary,
    required this.filter,
    required this.sort,
    required Iterable<DomainPackContractReport> filteredReports,
  }) : filteredReports = List.unmodifiable(filteredReports);

  factory DomainPackContractCoverageViewState.resolve({
    required DomainPackContractRegistryReport report,
    DomainPackContractDomainFilterSelection domainSelection =
        const DomainPackContractDomainFilterSelection.all(),
    DomainPackContractCoverageFilter filter =
        DomainPackContractCoverageFilter.all,
    DomainPackContractCoverageSort sort =
        DomainPackContractCoverageSort.registry,
    bool showZeroFilters = false,
  }) {
    final domainSummary =
        DomainPackContractDomainFilterSummary.fromRegistryReport(report);
    final resolvedDomainSelection = domainSelection.resolveFor(domainSummary);
    final domainReports = domainSummary.reportsFor(resolvedDomainSelection);
    final filterSummary = DomainPackContractCoverageFilterSummary(
      reports: domainReports,
    );
    final resolvedFilter = filter.resolveFor(
      filterSummary,
      showZeroFilters: showZeroFilters,
    );

    return DomainPackContractCoverageViewState(
      report: report,
      domainSummary: domainSummary,
      domainSelection: resolvedDomainSelection,
      filterSummary: filterSummary,
      filter: resolvedFilter,
      sort: sort,
      filteredReports: sortDomainPackContractCoverageReports(
        filterSummary.reportsFor(resolvedFilter),
        sort: sort,
      ),
    );
  }

  bool get hasActiveFilters {
    return !domainSelection.isAll ||
        filter != DomainPackContractCoverageFilter.all;
  }

  bool get hasActiveControls {
    return hasActiveFilters || sort != DomainPackContractCoverageSort.registry;
  }

  int get resultCount => filteredReports.length;

  String get scopeSummaryLabel {
    if (sort == DomainPackContractCoverageSort.registry) {
      return '$domainLabel · $filterLabel · ${_countLabel(resultCount, 'contract')}';
    }

    return '$domainLabel · $filterLabel · $sortLabel · '
        '${_countLabel(resultCount, 'contract')}';
  }

  String get emptyLabel => filter.emptyLabel;

  List<DomainPackContractReport> visibleReports(int maxVisibleReports) {
    return filteredReports.take(maxVisibleReports).toList();
  }

  int hiddenCountAfter(int visibleCount) {
    final hiddenCount = filteredReports.length - visibleCount;
    return hiddenCount < 0 ? 0 : hiddenCount;
  }

  String get domainLabel {
    final options = domainPackContractDomainFilterOptions(domainSummary);
    for (final option in options) {
      if (option.domainKey == domainSelection.domainKey) return option.label;
    }

    return 'All domains';
  }

  String get filterLabel {
    return switch (filter) {
      DomainPackContractCoverageFilter.all => 'All contracts',
      DomainPackContractCoverageFilter.blocked => 'Blocked',
      DomainPackContractCoverageFilter.hardening => 'Hardening',
      DomainPackContractCoverageFilter.complete => 'Complete',
    };
  }

  String get sortLabel => sort.label;
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
