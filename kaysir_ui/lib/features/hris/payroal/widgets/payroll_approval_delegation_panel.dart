import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollApprovalDelegationPanel extends StatelessWidget {
  final PayrollApprovalDelegationSummary summary;

  const PayrollApprovalDelegationPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.supervisor_account_outlined,
      title: 'Approval delegation',
      subtitle:
          '${summary.coveredCount}/${summary.lines.length} stages covered',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Covered',
              value: summary.coveredCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Delegated',
              value: summary.delegatedCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Approved',
              value: summary.approvedCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: summary.blockedCount.toString(),
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.nextAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final line in summary.lines) _DelegationLineTile(line: line),
      ],
    );
  }
}

class _DelegationLineTile extends StatelessWidget {
  final PayrollApprovalDelegationLine line;

  const _DelegationLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(line.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(line.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.stage.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Active: ${line.activeOwner}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.person_outline,
                      label: line.policy.primaryOwner,
                    ),
                    _MetricChip(
                      icon: Icons.swap_horiz_outlined,
                      label: line.policy.delegateOwner,
                    ),
                    _MetricChip(
                      icon: Icons.support_agent_outlined,
                      label: line.policy.backupOwner,
                    ),
                    _MetricChip(
                      icon: Icons.priority_high_outlined,
                      label: line.policy.escalationOwner,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.nextAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        line.status == PayrollApprovalDelegationStatus.blocked
                            ? color
                            : HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollApprovalDelegationStatus status) {
  return switch (status) {
    PayrollApprovalDelegationStatus.blocked => const Color(0xFFB91C1C),
    PayrollApprovalDelegationStatus.ready => const Color(0xFF2563EB),
    PayrollApprovalDelegationStatus.delegated => const Color(0xFF7C3AED),
    PayrollApprovalDelegationStatus.approved => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollApprovalDelegationStatus status) {
  return switch (status) {
    PayrollApprovalDelegationStatus.blocked => Icons.lock_outlined,
    PayrollApprovalDelegationStatus.ready => Icons.pending_actions_outlined,
    PayrollApprovalDelegationStatus.delegated =>
      Icons.supervisor_account_outlined,
    PayrollApprovalDelegationStatus.approved => Icons.verified_outlined,
  };
}
