import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_business_domain_profile.dart';
import 'release_profile_contract_coverage.dart';
import 'standard_release_workspace_profiles.dart';

const _allDomainMenuValue = '__all_release_profile_domains__';

/// Domain selection value for release profile filtering.
class BillingReleaseProfileDomainFilterSelection {
  final String? domainKey;

  factory BillingReleaseProfileDomainFilterSelection.domain(String domain) {
    final key = billingBusinessDomainKey(domain);
    if (key.isEmpty) {
      return const BillingReleaseProfileDomainFilterSelection.all();
    }

    return BillingReleaseProfileDomainFilterSelection._(key);
  }

  const BillingReleaseProfileDomainFilterSelection.all() : domainKey = null;

  const BillingReleaseProfileDomainFilterSelection._(this.domainKey);

  bool get isAll => domainKey == null;

  BillingReleaseProfileDomainFilterSelection resolveFor(
    BillingReleaseWorkspaceProfileContractCoverage coverage,
  ) {
    final key = domainKey;
    if (key == null) return this;

    for (final option in billingReleaseProfileDomainFilterOptions(coverage)) {
      if (option.domainKey == key) return this;
    }

    return const BillingReleaseProfileDomainFilterSelection.all();
  }

  @override
  bool operator ==(Object other) {
    return other is BillingReleaseProfileDomainFilterSelection &&
        other.domainKey == domainKey;
  }

  @override
  int get hashCode => domainKey.hashCode;
}

/// Menu option for one release profile business-domain scope.
class BillingReleaseProfileDomainFilterOption {
  final String? domainKey;
  final String label;
  final int profileCount;

  const BillingReleaseProfileDomainFilterOption({
    required this.domainKey,
    required this.label,
    required this.profileCount,
  });

  bool get isAll => domainKey == null;

  String get menuValue => domainKey ?? _allDomainMenuValue;

  String get menuLabel {
    return '$label · ${_countLabel(profileCount, 'profile')}';
  }

  BillingReleaseProfileDomainFilterSelection get selection {
    final key = domainKey;
    if (key == null) {
      return const BillingReleaseProfileDomainFilterSelection.all();
    }

    return BillingReleaseProfileDomainFilterSelection.domain(key);
  }
}

/// Popup filter for scoping release workspace profile contracts by business
/// domain while preserving responsive diagnostics layouts.
class BillingReleaseProfileDomainFilter extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractCoverage coverage;
  final BillingReleaseProfileDomainFilterSelection selectedSelection;
  final ValueChanged<BillingReleaseProfileDomainFilterSelection>
  onSelectionSelected;

  const BillingReleaseProfileDomainFilter({
    super.key,
    required this.coverage,
    required this.selectedSelection,
    required this.onSelectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (coverage.isEmpty) return const SizedBox.shrink();

    final options = billingReleaseProfileDomainFilterOptions(coverage);
    final selected = selectedSelection.resolveFor(coverage);
    final selectedOption = _optionForSelection(options, selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business domain',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          tooltip: 'Filter release profiles by business domain',
          initialValue: selectedOption.menuValue,
          onSelected: (value) {
            onSelectionSelected(_selectionForMenuValue(value));
          },
          itemBuilder:
              (context) => [
                for (final option in options)
                  PopupMenuItem(
                    value: option.menuValue,
                    child: Text(
                      option.menuLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
          child: Container(
            height: 40,
            constraints: const BoxConstraints(minWidth: 188, maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.domain_outlined,
                  size: 17,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    selectedOption.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedOption.profileCount}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Release profile domain filter')
Widget releaseProfileDomainFilterPreview() {
  final coverage = BillingReleaseWorkspaceProfileContractCoverage(
    contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BillingReleaseProfileDomainFilter(
          coverage: coverage,
          selectedSelection: BillingReleaseProfileDomainFilterSelection.domain(
            'retail',
          ),
          onSelectionSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Returns domain filter options derived from release profile contracts.
List<BillingReleaseProfileDomainFilterOption>
billingReleaseProfileDomainFilterOptions(
  BillingReleaseWorkspaceProfileContractCoverage coverage,
) {
  final domainCounts = <String, int>{};
  for (final contract in coverage.contracts) {
    for (final domain in contract.businessDomains) {
      domainCounts[domain] = (domainCounts[domain] ?? 0) + 1;
    }
  }

  final domainOptions =
      domainCounts.entries
          .map(
            (entry) => BillingReleaseProfileDomainFilterOption(
              domainKey: entry.key,
              label: _domainLabel(entry.key),
              profileCount: entry.value,
            ),
          )
          .toList()
        ..sort((left, right) => left.label.compareTo(right.label));

  return [
    BillingReleaseProfileDomainFilterOption(
      domainKey: null,
      label: 'All domains',
      profileCount: coverage.profileCount,
    ),
    ...domainOptions,
  ];
}

BillingReleaseProfileDomainFilterOption _optionForSelection(
  List<BillingReleaseProfileDomainFilterOption> options,
  BillingReleaseProfileDomainFilterSelection selection,
) {
  for (final option in options) {
    if (option.domainKey == selection.domainKey) return option;
  }

  return options.first;
}

BillingReleaseProfileDomainFilterSelection _selectionForMenuValue(
  String value,
) {
  if (value == _allDomainMenuValue) {
    return const BillingReleaseProfileDomainFilterSelection.all();
  }

  return BillingReleaseProfileDomainFilterSelection.domain(value);
}

String _domainLabel(String domain) {
  return domain
      .split(RegExp(r'[-_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
