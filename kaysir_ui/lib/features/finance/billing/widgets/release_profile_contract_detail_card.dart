import 'package:flutter/material.dart';

import 'release_profile_contract.dart';
import 'release_profile_contract_status_visuals.dart';

/// Presents a release workspace profile contract with expandable registration
/// details for diagnostics and rollout-review surfaces.
class BillingReleaseWorkspaceProfileContractDetailCard extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContract contract;
  final bool initiallyExpanded;

  const BillingReleaseWorkspaceProfileContractDetailCard({
    super.key,
    required this.contract,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey(
              'billing-release-profile-contract-${contract.profileId}',
            ),
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            leading: const Icon(
              Icons.account_tree_outlined,
              color: Color(0xFF2563EB),
              size: 18,
            ),
            title: Text(
              contract.summaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.compositionLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ContractStatusPill(contract: contract),
                ],
              ),
            ),
            children: [
              _ContractDetailSection(
                title: 'Business domains',
                icon: Icons.domain_outlined,
                color: const Color(0xFF0F766E),
                values: contract.businessDomains,
              ),
              _ContractDetailSection(
                title: 'Deck IDs',
                icon: Icons.view_agenda_outlined,
                color: const Color(0xFF7C3AED),
                values: contract.deckIds,
              ),
              _ContractDetailSection(
                title: 'Saved views',
                icon: Icons.bookmarks_outlined,
                color: const Color(0xFFD97706),
                values: contract.savedViewIds,
              ),
              if (contract.extensionDeckIds.isNotEmpty)
                _ContractDetailSection(
                  title: 'Domain deck IDs',
                  icon: Icons.extension_outlined,
                  color: const Color(0xFF2563EB),
                  values: contract.extensionDeckIds,
                ),
              if (contract.extensionSavedViewIds.isNotEmpty)
                _ContractDetailSection(
                  title: 'Domain saved view IDs',
                  icon: Icons.bookmark_add_outlined,
                  color: const Color(0xFF0891B2),
                  values: contract.extensionSavedViewIds,
                ),
              if (contract.hiddenDeckIds.isNotEmpty)
                _ContractDetailSection(
                  title: 'Hidden standard deck IDs',
                  icon: Icons.visibility_off_outlined,
                  color: const Color(0xFFB45309),
                  values: contract.hiddenDeckIds,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status badge that explains whether a profile is standard, extended,
/// constrained, or tailored.
class _ContractStatusPill extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContract contract;

  const _ContractStatusPill({required this.contract});

  @override
  Widget build(BuildContext context) {
    final visuals =
        BillingReleaseWorkspaceProfileContractStatusVisuals.fromStatus(
          contract.status,
        );

    return Tooltip(
      message: contract.statusDetail,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: visuals.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: visuals.color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visuals.icon, size: 14, color: visuals.color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                contract.statusLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: visuals.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Groups one contract detail category, such as deck IDs or saved view IDs,
/// into a titled chip list.
class _ContractDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Iterable<String> values;

  const _ContractDetailSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final visibleValues = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (visibleValues.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                visibleValues
                    .map((value) => _ContractDetailChip(value: value))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

/// Displays a single compact contract identifier without letting long IDs
/// disturb the surrounding diagnostics layout.
class _ContractDetailChip extends StatelessWidget {
  final String value;

  const _ContractDetailChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
