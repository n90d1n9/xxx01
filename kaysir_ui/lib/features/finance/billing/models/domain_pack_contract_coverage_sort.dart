import '../utils/domain_pack_contract.dart';

/// Sort options for billing domain-pack contract coverage lists.
enum DomainPackContractCoverageSort { registry, attention, domain }

/// Labels and descriptions for domain-pack contract coverage sort options.
extension DomainPackContractCoverageSortLabels
    on DomainPackContractCoverageSort {
  String get label {
    return switch (this) {
      DomainPackContractCoverageSort.registry => 'Registry order',
      DomainPackContractCoverageSort.attention => 'Needs attention',
      DomainPackContractCoverageSort.domain => 'Domain name',
    };
  }

  String get tooltip {
    return switch (this) {
      DomainPackContractCoverageSort.registry =>
        'Show domain-pack contracts in registry order',
      DomainPackContractCoverageSort.attention =>
        'Show blocked and hardening contracts first',
      DomainPackContractCoverageSort.domain =>
        'Show domain-pack contracts by business-domain name',
    };
  }
}

/// Sorts billing domain-pack contract reports for diagnostics presentation.
List<DomainPackContractReport> sortDomainPackContractCoverageReports(
  Iterable<DomainPackContractReport> reports, {
  DomainPackContractCoverageSort sort = DomainPackContractCoverageSort.registry,
}) {
  final sortedEntries = reports.indexed.toList(growable: false);
  sortedEntries.sort((left, right) {
    final comparison = switch (sort) {
      DomainPackContractCoverageSort.registry => left.$1.compareTo(right.$1),
      DomainPackContractCoverageSort.attention => _compareAttention(
        left.$2,
        right.$2,
      ),
      DomainPackContractCoverageSort.domain => _compareDomain(
        left.$2,
        right.$2,
      ),
    };

    if (comparison != 0) return comparison;
    return left.$1.compareTo(right.$1);
  });

  return List.unmodifiable(sortedEntries.map((entry) => entry.$2));
}

int _compareAttention(
  DomainPackContractReport first,
  DomainPackContractReport second,
) {
  final severityComparison = _attentionRank(
    first,
  ).compareTo(_attentionRank(second));
  if (severityComparison != 0) return severityComparison;

  final openRequirementComparison = second.openRequirementCount.compareTo(
    first.openRequirementCount,
  );
  if (openRequirementComparison != 0) return openRequirementComparison;

  return _compareDomain(first, second);
}

int _attentionRank(DomainPackContractReport report) {
  if (!report.isReleaseReady) return 0;
  if (!report.isFullySpecified) return 1;

  return 2;
}

int _compareDomain(
  DomainPackContractReport first,
  DomainPackContractReport second,
) {
  final labelComparison = first.domainLabel.compareTo(second.domainLabel);
  if (labelComparison != 0) return labelComparison;

  return first.domainKey.compareTo(second.domainKey);
}
