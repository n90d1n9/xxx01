import 'billing_business_domain_profile.dart';
import '../utils/domain_pack_contract.dart';

const domainPackContractAllDomainFilterValue =
    '__all_domain_pack_contract_domains__';

/// Domain scope selection for billing domain-pack contract coverage.
class DomainPackContractDomainFilterSelection {
  final String? domainKey;

  factory DomainPackContractDomainFilterSelection.domain(String domain) {
    final key = billingBusinessDomainKey(domain);
    if (key.isEmpty) return const DomainPackContractDomainFilterSelection.all();

    return DomainPackContractDomainFilterSelection._(key);
  }

  const DomainPackContractDomainFilterSelection.all() : domainKey = null;

  const DomainPackContractDomainFilterSelection._(this.domainKey);

  bool get isAll => domainKey == null;

  DomainPackContractDomainFilterSelection resolveFor(
    DomainPackContractDomainFilterSummary summary,
  ) {
    final key = domainKey;
    if (key == null) return this;

    for (final option in domainPackContractDomainFilterOptions(summary)) {
      if (option.domainKey == key) return this;
    }

    return const DomainPackContractDomainFilterSelection.all();
  }

  @override
  bool operator ==(Object other) {
    return other is DomainPackContractDomainFilterSelection &&
        other.domainKey == domainKey;
  }

  @override
  int get hashCode => domainKey.hashCode;
}

/// Menu option for one domain-pack contract domain scope.
class DomainPackContractDomainFilterOption {
  final String? domainKey;
  final String label;
  final int contractCount;

  const DomainPackContractDomainFilterOption({
    required this.domainKey,
    required this.label,
    required this.contractCount,
  });

  bool get isAll => domainKey == null;

  String get menuValue => domainKey ?? domainPackContractAllDomainFilterValue;

  String get menuLabel {
    return '$label · ${_countLabel(contractCount, 'contract')}';
  }

  DomainPackContractDomainFilterSelection get selection {
    final key = domainKey;
    if (key == null) {
      return const DomainPackContractDomainFilterSelection.all();
    }

    return DomainPackContractDomainFilterSelection.domain(key);
  }
}

/// Count summary used by domain-pack contract domain filters.
class DomainPackContractDomainFilterSummary {
  final List<DomainPackContractReport> reports;

  DomainPackContractDomainFilterSummary({
    required Iterable<DomainPackContractReport> reports,
  }) : reports = List.unmodifiable(reports);

  factory DomainPackContractDomainFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport report,
  ) {
    return DomainPackContractDomainFilterSummary(reports: report.packReports);
  }

  bool get isEmpty => reports.isEmpty;

  int get contractCount => reports.length;

  List<DomainPackContractReport> reportsFor(
    DomainPackContractDomainFilterSelection selection,
  ) {
    final resolvedSelection = selection.resolveFor(this);
    final key = resolvedSelection.domainKey;
    if (key == null) return reports;

    return List.unmodifiable(
      reports.where((report) => report.domainKey == key),
    );
  }
}

/// Returns domain options derived from billing domain-pack contract reports.
List<DomainPackContractDomainFilterOption>
domainPackContractDomainFilterOptions(
  DomainPackContractDomainFilterSummary summary,
) {
  final builders = <String, _DomainOptionBuilder>{};
  for (final report in summary.reports) {
    final builder = builders.putIfAbsent(
      report.domainKey,
      () => _DomainOptionBuilder(
        domainKey: report.domainKey,
        label: report.domainLabel,
      ),
    );
    builder.contractCount += 1;
  }

  final domainOptions =
      builders.values.map((builder) => builder.build()).toList()
        ..sort((left, right) => left.label.compareTo(right.label));

  return [
    DomainPackContractDomainFilterOption(
      domainKey: null,
      label: 'All domains',
      contractCount: summary.contractCount,
    ),
    ...domainOptions,
  ];
}

/// Resolves popup-menu values back into domain filter selections.
DomainPackContractDomainFilterSelection
domainPackContractDomainFilterSelectionForMenuValue(String value) {
  if (value == domainPackContractAllDomainFilterValue) {
    return const DomainPackContractDomainFilterSelection.all();
  }

  return DomainPackContractDomainFilterSelection.domain(value);
}

class _DomainOptionBuilder {
  final String domainKey;
  final String label;
  int contractCount = 0;

  _DomainOptionBuilder({required this.domainKey, required this.label});

  DomainPackContractDomainFilterOption build() {
    return DomainPackContractDomainFilterOption(
      domainKey: domainKey,
      label: label,
      contractCount: contractCount,
    );
  }
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
