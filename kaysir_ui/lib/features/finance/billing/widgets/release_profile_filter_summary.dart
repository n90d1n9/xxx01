import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/billing_business_domain_profile.dart';
import 'release_profile_contract.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_status_filter.dart';
import 'standard_release_workspace_profiles.dart';

/// Summarizes the active release profile status filter and visible profile
/// count for diagnostics and review panels.
class BillingReleaseProfileFilterSummary extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractCoverage coverage;
  final BillingReleaseProfileStatusFilterOption selectedOption;
  final String? focusedBusinessDomain;
  final String? filteredBusinessDomain;
  final VoidCallback? onClearFilter;

  const BillingReleaseProfileFilterSummary({
    super.key,
    required this.coverage,
    required this.selectedOption,
    this.focusedBusinessDomain,
    this.filteredBusinessDomain,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (coverage.isEmpty) return const SizedBox.shrink();

    final summary = BillingReleaseProfileFilterSummaryModel.fromCoverage(
      coverage: coverage,
      selectedOption: selectedOption,
      focusedBusinessDomain: focusedBusinessDomain,
      filteredBusinessDomain: filteredBusinessDomain,
    );
    final showClear = summary.isFiltered && onClearFilter != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(summary.icon, size: 17, color: summary.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (showClear) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(Icons.close_rounded, size: 15),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Release profile filter summary')
Widget releaseProfileFilterSummaryPreview() {
  final coverage = BillingReleaseWorkspaceProfileContractCoverage(
    contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BillingReleaseProfileFilterSummary(
          coverage: coverage,
          selectedOption: BillingReleaseProfileStatusFilterOption.extended,
          focusedBusinessDomain: 'construction',
          onClearFilter: () {},
        ),
      ),
    ),
  );
}

/// Immutable view model for the release profile filter summary banner.
class BillingReleaseProfileFilterSummaryModel {
  final int visibleProfileCount;
  final int totalProfileCount;
  final BillingReleaseProfileStatusFilterOption selectedOption;
  final String? filteredDomainLabel;
  final String? focusedDomainLabel;

  const BillingReleaseProfileFilterSummaryModel({
    required this.visibleProfileCount,
    required this.totalProfileCount,
    required this.selectedOption,
    this.filteredDomainLabel,
    this.focusedDomainLabel,
  });

  factory BillingReleaseProfileFilterSummaryModel.fromCoverage({
    required BillingReleaseWorkspaceProfileContractCoverage coverage,
    required BillingReleaseProfileStatusFilterOption selectedOption,
    String? focusedBusinessDomain,
    String? filteredBusinessDomain,
  }) {
    final visibleProfileCount =
        coverage
            .prioritizedContracts(
              focusedBusinessDomain: focusedBusinessDomain,
              includedStatuses: selectedOption.includedStatuses,
              scopedBusinessDomain: filteredBusinessDomain,
            )
            .length;

    return BillingReleaseProfileFilterSummaryModel(
      visibleProfileCount: visibleProfileCount,
      totalProfileCount: coverage.profileCount,
      selectedOption: selectedOption,
      filteredDomainLabel: _domainLabel(filteredBusinessDomain),
      focusedDomainLabel: _domainLabel(focusedBusinessDomain),
    );
  }

  bool get isFiltered {
    return selectedOption != BillingReleaseProfileStatusFilterOption.all ||
        filteredDomainLabel != null;
  }

  IconData get icon {
    return isFiltered ? Icons.filter_alt_outlined : Icons.filter_list_outlined;
  }

  Color get color {
    return isFiltered ? const Color(0xFF2563EB) : const Color(0xFF64748B);
  }

  String get label {
    final parts = <String>[];

    if (isFiltered) {
      parts.add(
        'Showing ${_countLabel(visibleProfileCount, selectedOption.statusNoun)}',
      );
    } else {
      parts.add('Showing ${_countLabel(totalProfileCount, 'release profile')}');
    }

    final focus = focusedDomainLabel;
    final filteredDomain = filteredDomainLabel;
    if (filteredDomain != null) {
      parts.add('Scoped to $filteredDomain');
    } else if (focus != null) {
      parts.add('$focus prioritized first');
    }

    return parts.join(' · ');
  }
}

extension on BillingReleaseProfileStatusFilterOption {
  String get statusNoun {
    final status = contractStatus;
    if (status == null) return 'release profile';

    return '${status.label.toLowerCase()} release profile';
  }
}

String? _domainLabel(String? businessDomain) {
  final key = billingBusinessDomainKey(businessDomain ?? '');
  if (key.isEmpty) return null;

  return key
      .split(RegExp(r'[-_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
