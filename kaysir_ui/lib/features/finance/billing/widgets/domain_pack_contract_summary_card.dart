import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Compact diagnostics summary for billing domain-pack contract coverage.
class DomainPackContractSummaryCard extends StatelessWidget {
  final String summaryLabel;
  final int contractCount;
  final int openRequirementCount;
  final int blockedRequirementCount;
  final int warningRequirementCount;

  const DomainPackContractSummaryCard({
    super.key,
    required this.summaryLabel,
    required this.contractCount,
    required this.openRequirementCount,
    required this.blockedRequirementCount,
    required this.warningRequirementCount,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _ContractSummaryVisuals.fromCounts(
      blockedRequirementCount: blockedRequirementCount,
      warningRequirementCount: warningRequirementCount,
      openRequirementCount: openRequirementCount,
    );

    return Container(
      key: const ValueKey('domain-pack-contract-summary-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(visuals.icon, color: visuals.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryLabel,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ContractSummaryChip(
                      label: 'Contracts',
                      value: '$contractCount',
                      color: const Color(0xFF2563EB),
                    ),
                    _ContractSummaryChip(
                      label: 'Open',
                      value: '$openRequirementCount',
                      color: const Color(0xFF7C3AED),
                    ),
                    _ContractSummaryChip(
                      label: 'Blocked',
                      value: '$blockedRequirementCount',
                      color: const Color(0xFFDC2626),
                    ),
                    _ContractSummaryChip(
                      label: 'Hardening',
                      value: '$warningRequirementCount',
                      color: const Color(0xFFD97706),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Domain pack contract summary card')
Widget domainPackContractSummaryCardPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 560,
          child: DomainPackContractSummaryCard(
            summaryLabel:
                '3 billing domain-pack contracts are release-ready with 4 hardening requirements.',
            contractCount: 3,
            openRequirementCount: 4,
            blockedRequirementCount: 0,
            warningRequirementCount: 4,
          ),
        ),
      ),
    ),
  );
}

class _ContractSummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ContractSummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractSummaryVisuals {
  final IconData icon;
  final Color color;

  const _ContractSummaryVisuals({required this.icon, required this.color});

  factory _ContractSummaryVisuals.fromCounts({
    required int blockedRequirementCount,
    required int warningRequirementCount,
    required int openRequirementCount,
  }) {
    if (blockedRequirementCount > 0) {
      return const _ContractSummaryVisuals(
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFDC2626),
      );
    }

    if (warningRequirementCount > 0 || openRequirementCount > 0) {
      return const _ContractSummaryVisuals(
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFD97706),
      );
    }

    return const _ContractSummaryVisuals(
      icon: Icons.verified_outlined,
      color: Color(0xFF047857),
    );
  }
}
