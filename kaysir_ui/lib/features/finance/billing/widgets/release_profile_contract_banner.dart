import 'package:flutter/material.dart';

import 'release_profile_contract.dart';
import 'release_profile_contract_status_visuals.dart';

/// Compact banner for the active release workspace profile contract in the
/// diagnostics release workspace.
class BillingReleaseWorkspaceProfileContractBanner extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContract contract;

  const BillingReleaseWorkspaceProfileContractBanner({
    super.key,
    required this.contract,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          final title = _ContractTitle(contract: contract);
          final metrics = _ContractMetrics(contract: contract);

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 12), metrics],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              Flexible(child: metrics),
            ],
          );
        },
      ),
    );
  }
}

/// Shows the profile contract title and high-level profile identifier.
class _ContractTitle extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContract contract;

  const _ContractTitle({required this.contract});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.dashboard_customize_outlined,
            color: Color(0xFF0F766E),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Release workspace profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                contract.summaryLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Renders compact profile contract metrics that stay readable in narrow
/// diagnostics panels.
class _ContractMetrics extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContract contract;

  const _ContractMetrics({required this.contract});

  @override
  Widget build(BuildContext context) {
    final visuals =
        BillingReleaseWorkspaceProfileContractStatusVisuals.fromStatus(
          contract.status,
        );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _ContractPill(
          label: _countLabel(contract.businessDomains.length, 'domain'),
          icon: Icons.domain_outlined,
          color: const Color(0xFF2563EB),
        ),
        _ContractPill(
          label: contract.compositionLabel,
          icon: visuals.icon,
          color: visuals.color,
        ),
      ],
    );
  }
}

/// Pill-shaped contract metric for profile banner facts.
class _ContractPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ContractPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
