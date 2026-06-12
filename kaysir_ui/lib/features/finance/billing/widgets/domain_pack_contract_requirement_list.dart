import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/domain_pack_contract.dart';
import 'billing_empty_state.dart';

/// Reusable checklist for billing domain-pack contract requirements.
class DomainPackContractRequirementList extends StatelessWidget {
  final List<DomainPackContractRequirement> requirements;
  final int maxVisibleRequirements;

  const DomainPackContractRequirementList({
    super.key,
    required this.requirements,
    this.maxVisibleRequirements = 5,
  }) : assert(maxVisibleRequirements > 0);

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) {
      return const BillingEmptyState(
        message: 'No domain-pack contract requirements are available.',
        padding: EdgeInsets.all(14),
      );
    }

    final visibleRequirements =
        requirements.take(maxVisibleRequirements).toList();
    final hiddenCount = requirements.length - visibleRequirements.length;

    return Column(
      key: const ValueKey('domain-pack-contract-requirement-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final requirement in visibleRequirements)
          DomainPackContractRequirementTile(requirement: requirement),
        if (hiddenCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$hiddenCount more ${_plural(hiddenCount, 'requirement')} hidden',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact visual row for one billing domain-pack contract requirement.
class DomainPackContractRequirementTile extends StatelessWidget {
  final DomainPackContractRequirement requirement;

  const DomainPackContractRequirementTile({
    super.key,
    required this.requirement,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _RequirementVisuals.fromStatus(requirement.status);
    final detail = _requirementDetail(requirement);

    return Padding(
      key: ValueKey('domain-pack-contract-requirement-${requirement.id}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: visuals.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(visuals.icon, size: 17, color: visuals.foreground),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        requirement.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RequirementStatusBadge(
                      label: requirement.statusLabel,
                      foreground: visuals.foreground,
                      background: visuals.badgeBackground,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  requirement.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Domain pack contract requirement list')
Widget domainPackContractRequirementListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 520,
          child: DomainPackContractRequirementList(
            requirements: [
              DomainPackContractRequirement(
                id: domainPackContractModuleReadinessId,
                label: 'Module contract',
                status: DomainPackContractStatus.satisfied,
                message: 'Commerce billing module is launch-ready.',
              ),
              DomainPackContractRequirement(
                id: domainPackContractDiagnosticsProfileId,
                label: 'Diagnostics contract',
                status: DomainPackContractStatus.warning,
                message:
                    'Commerce uses standard diagnostics without a domain-specific pack profile.',
              ),
              DomainPackContractRequirement(
                id: domainPackContractReleaseGateTargetsId,
                label: 'Release gate targets',
                status: DomainPackContractStatus.blocked,
                message:
                    'Service operations has release gate lanes without diagnostics navigation targets.',
                details: const ['service-handoff'],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RequirementStatusBadge extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _RequirementStatusBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 22, minWidth: 56),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _RequirementVisuals {
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color badgeBackground;

  const _RequirementVisuals({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.badgeBackground,
  });

  factory _RequirementVisuals.fromStatus(DomainPackContractStatus status) {
    return switch (status) {
      DomainPackContractStatus.satisfied => const _RequirementVisuals(
        icon: Icons.check_circle_outline,
        foreground: Color(0xFF047857),
        background: Color(0xFFD1FAE5),
        badgeBackground: Color(0xFFECFDF5),
      ),
      DomainPackContractStatus.warning => const _RequirementVisuals(
        icon: Icons.info_outline_rounded,
        foreground: Color(0xFFB45309),
        background: Color(0xFFFEF3C7),
        badgeBackground: Color(0xFFFFFBEB),
      ),
      DomainPackContractStatus.blocked => const _RequirementVisuals(
        icon: Icons.error_outline,
        foreground: Color(0xFFB91C1C),
        background: Color(0xFFFEE2E2),
        badgeBackground: Color(0xFFFEF2F2),
      ),
    };
  }
}

String? _requirementDetail(DomainPackContractRequirement requirement) {
  if (requirement.details.isEmpty) return null;

  final visibleDetails = requirement.details.take(3).join(', ');
  final hiddenCount = requirement.details.length - 3;
  if (hiddenCount <= 0) return visibleDetails;

  return '$visibleDetails and $hiddenCount more';
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
