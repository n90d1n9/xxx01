import '../utils/domain_pack_contract.dart';

/// Filter state for focusing billing domain-pack contract coverage.
enum DomainPackContractCoverageFilter { all, blocked, hardening, complete }

/// Count summary used by contract coverage filter controls.
class DomainPackContractCoverageFilterSummary {
  final List<DomainPackContractReport> reports;

  DomainPackContractCoverageFilterSummary({
    required Iterable<DomainPackContractReport> reports,
  }) : reports = List.unmodifiable(reports);

  factory DomainPackContractCoverageFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport report,
  ) {
    return DomainPackContractCoverageFilterSummary(reports: report.packReports);
  }

  bool get isEmpty => reports.isEmpty;

  int get totalCount => reports.length;

  int get blockedCount {
    return reports.where((report) => !report.isReleaseReady).length;
  }

  int get hardeningCount {
    return reports.where((report) {
      return report.warningRequirements.isNotEmpty;
    }).length;
  }

  int get completeCount {
    return reports.where((report) => report.isFullySpecified).length;
  }

  int countFor(DomainPackContractCoverageFilter filter) {
    return reportsFor(filter).length;
  }

  List<DomainPackContractReport> reportsFor(
    DomainPackContractCoverageFilter filter,
  ) {
    return List.unmodifiable(reports.where(filter.matches));
  }
}

/// Maps contract coverage filters to predicates and operator-facing labels.
extension DomainPackContractCoverageFilterMapping
    on DomainPackContractCoverageFilter {
  bool matches(DomainPackContractReport report) {
    return switch (this) {
      DomainPackContractCoverageFilter.all => true,
      DomainPackContractCoverageFilter.blocked => !report.isReleaseReady,
      DomainPackContractCoverageFilter.hardening =>
        report.warningRequirements.isNotEmpty,
      DomainPackContractCoverageFilter.complete => report.isFullySpecified,
    };
  }

  bool isAvailableFor(
    DomainPackContractCoverageFilterSummary summary, {
    bool showZeroFilters = false,
  }) {
    if (this == DomainPackContractCoverageFilter.all) return true;

    return showZeroFilters || summary.countFor(this) > 0;
  }

  DomainPackContractCoverageFilter resolveFor(
    DomainPackContractCoverageFilterSummary summary, {
    bool showZeroFilters = false,
  }) {
    if (isAvailableFor(summary, showZeroFilters: showZeroFilters)) {
      return this;
    }

    return DomainPackContractCoverageFilter.all;
  }

  String labelFor(DomainPackContractCoverageFilterSummary summary) {
    return switch (this) {
      DomainPackContractCoverageFilter.all => 'All ${summary.totalCount}',
      DomainPackContractCoverageFilter.blocked =>
        'Blocked ${summary.blockedCount}',
      DomainPackContractCoverageFilter.hardening =>
        'Hardening ${summary.hardeningCount}',
      DomainPackContractCoverageFilter.complete =>
        'Complete ${summary.completeCount}',
    };
  }

  String tooltipFor(DomainPackContractCoverageFilterSummary summary) {
    return switch (this) {
      DomainPackContractCoverageFilter.all =>
        'Show all ${summary.totalCount} domain-pack contracts',
      DomainPackContractCoverageFilter.blocked =>
        'Show ${summary.blockedCount} blocked domain-pack contracts',
      DomainPackContractCoverageFilter.hardening =>
        'Show ${summary.hardeningCount} domain-pack contracts with hardening '
            'requirements',
      DomainPackContractCoverageFilter.complete =>
        'Show ${summary.completeCount} fully specified domain-pack contracts',
    };
  }

  String get emptyLabel {
    return switch (this) {
      DomainPackContractCoverageFilter.all =>
        'No domain-pack contracts are registered yet.',
      DomainPackContractCoverageFilter.blocked =>
        'No blocked domain-pack contracts.',
      DomainPackContractCoverageFilter.hardening =>
        'No hardening requirements for domain-pack contracts.',
      DomainPackContractCoverageFilter.complete =>
        'No fully specified domain-pack contracts yet.',
    };
  }
}

const domainPackContractCoverageFilters = [
  DomainPackContractCoverageFilter.all,
  DomainPackContractCoverageFilter.blocked,
  DomainPackContractCoverageFilter.hardening,
  DomainPackContractCoverageFilter.complete,
];

/// Returns available filters for a billing domain-pack contract summary.
List<DomainPackContractCoverageFilter> domainPackContractCoverageFilterOptions(
  DomainPackContractCoverageFilterSummary summary, {
  bool showZeroFilters = false,
}) {
  return [
    for (final filter in domainPackContractCoverageFilters)
      if (filter.isAvailableFor(summary, showZeroFilters: showZeroFilters))
        filter,
  ];
}
