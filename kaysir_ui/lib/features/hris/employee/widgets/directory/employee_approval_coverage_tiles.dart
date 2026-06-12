import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_approval_coverage_models.dart';
import 'employee_approval_coverage_styles.dart';

class EmployeeApprovalCoverageSummaryStrip extends StatelessWidget {
  final EmployeeApprovalCoverageProfile profile;

  const EmployeeApprovalCoverageSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Active', value: '${profile.activeCount}'),
        HrisMetricStripItem(label: 'Pending', value: '${profile.pendingCount}'),
        HrisMetricStripItem(label: 'Blocked', value: '${profile.blockedCount}'),
        HrisMetricStripItem(
          label: 'Expiring',
          value: '${profile.expiringSoonCount}',
        ),
      ],
    );
  }
}

class EmployeeApprovalCoverageStatusCard extends StatelessWidget {
  final EmployeeApprovalCoverageProfile profile;

  const EmployeeApprovalCoverageStatusCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final progressColor =
        profile.blockedCount > 0 || profile.expiredCount > 0
            ? const Color(0xFFB91C1C)
            : profile.attentionCount > 0
            ? const Color(0xFFB45309)
            : const Color(0xFF15803D);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Primary approver ${profile.manager}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label:
                    profile.attentionCount == 0
                        ? 'Covered'
                        : '${profile.attentionCount} action',
                color: progressColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.coverageRatio,
            color: progressColor,
            label:
                '${(profile.coverageRatio * 100).round()}% approval coverage active',
          ),
        ],
      ),
    );
  }
}

class EmployeeApprovalDelegationTile extends StatelessWidget {
  final EmployeeApprovalDelegation delegation;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onBlock;
  final VoidCallback onExpire;
  final VoidCallback onRemove;

  const EmployeeApprovalDelegationTile({
    super.key,
    required this.delegation,
    required this.asOfDate,
    required this.onActivate,
    required this.onBlock,
    required this.onExpire,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeApprovalCoverageStatusColor(delegation.status);
    final riskColor = employeeApprovalCoverageRiskColor(delegation.risk);
    final areaIcon = employeeApprovalCoverageAreaIcon(delegation.area);
    final expiringSoon = delegation.expiresWithin(asOfDate, 14);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeApprovalCoverageStatusIcon(delegation.status),
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delegation.area.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${delegation.primaryApprover} to ${delegation.delegateApprover}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: delegation.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            delegation.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: areaIcon, label: delegation.area.label),
              _MetaChip(
                icon: Icons.date_range_outlined,
                label:
                    '${DateFormat('MMM d').format(delegation.startDate)} - ${DateFormat('MMM d').format(delegation.endDate)}',
                color: expiringSoon ? const Color(0xFFB45309) : null,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: delegation.risk.label,
                color: riskColor,
              ),
              if (expiringSoon)
                _MetaChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Expiring soon',
                  color: const Color(0xFFB45309),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!delegation.isActive)
                TextButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Activate'),
                ),
              if (!delegation.isBlocked)
                TextButton.icon(
                  onPressed: onBlock,
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('Block'),
                ),
              TextButton.icon(
                onPressed: onExpire,
                icon: const Icon(Icons.event_busy_outlined),
                label: const Text('Expire'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove delegation',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
