import 'package:flutter/material.dart';

import 'release_profile_contract.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_contract_status_visuals.dart';

/// Compact status summary for release workspace profile contracts.
class BillingReleaseWorkspaceProfileContractStatusStrip
    extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractStatusSummary summary;
  final bool showZeroStatuses;

  const BillingReleaseWorkspaceProfileContractStatusStrip({
    super.key,
    required this.summary,
    this.showZeroStatuses = false,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final statuses =
        showZeroStatuses
            ? BillingReleaseWorkspaceProfileContractStatus.values
            : summary.activeStatuses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile status',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              statuses
                  .map(
                    (status) => _ContractStatusCountChip(
                      status: status,
                      count: summary.countFor(status),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

/// Count chip for one release workspace profile contract status.
class _ContractStatusCountChip extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractStatus status;
  final int count;

  const _ContractStatusCountChip({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final visuals =
        BillingReleaseWorkspaceProfileContractStatusVisuals.fromStatus(status);

    return Tooltip(
      message: '${status.label} release workspace profiles: $count',
      child: Container(
        height: 32,
        constraints: const BoxConstraints(minWidth: 106, maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: visuals.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: visuals.color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visuals.icon, size: 15, color: visuals.color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$count ${status.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: visuals.color,
                  fontSize: 12,
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
