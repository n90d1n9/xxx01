import 'package:flutter/material.dart';

import '../models/billing_business_domain_profile.dart';
import 'release_profile_contract.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_contract_detail_card.dart';

/// Renders a prioritized, bounded list of release workspace profile contracts
/// for diagnostics and rollout-review panels.
class BillingReleaseWorkspaceProfileContractList extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractCoverage coverage;
  final String? focusedBusinessDomain;
  final int maxVisibleProfiles;
  final bool expandFocusedProfile;
  final Set<BillingReleaseWorkspaceProfileContractStatus>? includedStatuses;
  final String? filteredBusinessDomain;
  final String emptyLabel;

  const BillingReleaseWorkspaceProfileContractList({
    super.key,
    required this.coverage,
    this.focusedBusinessDomain,
    this.maxVisibleProfiles = 3,
    this.expandFocusedProfile = false,
    this.includedStatuses,
    this.filteredBusinessDomain,
    this.emptyLabel = 'No release workspace profiles match this view.',
  });

  @override
  Widget build(BuildContext context) {
    final prioritizedContracts = coverage.prioritizedContracts(
      focusedBusinessDomain: focusedBusinessDomain,
      includedStatuses: includedStatuses,
      scopedBusinessDomain: filteredBusinessDomain,
    );
    if (prioritizedContracts.isEmpty || maxVisibleProfiles <= 0) {
      return _ContractListEmptyState(label: emptyLabel);
    }

    final visibleContracts = prioritizedContracts
        .take(maxVisibleProfiles)
        .toList(growable: false);
    final hiddenProfileCount =
        prioritizedContracts.length - visibleContracts.length;
    final focusedDomainKey = billingBusinessDomainKey(
      focusedBusinessDomain ?? '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final contract in visibleContracts)
          BillingReleaseWorkspaceProfileContractDetailCard(
            contract: contract,
            initiallyExpanded: _shouldExpandContract(
              contract,
              focusedDomainKey,
            ),
          ),
        if (hiddenProfileCount > 0) ...[
          const SizedBox(height: 4),
          Text(
            _hiddenProfileLabel(hiddenProfileCount),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldExpandContract(
    BillingReleaseWorkspaceProfileContract contract,
    String focusedDomainKey,
  ) {
    return expandFocusedProfile &&
        focusedDomainKey.isNotEmpty &&
        contract.businessDomains.contains(focusedDomainKey);
  }
}

/// Empty state for filtered release workspace profile contract lists.
class _ContractListEmptyState extends StatelessWidget {
  final String label;

  const _ContractListEmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 16,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _hiddenProfileLabel(int count) {
  final suffix = count == 1 ? 'profile' : 'profiles';
  return '+$count more release $suffix';
}
