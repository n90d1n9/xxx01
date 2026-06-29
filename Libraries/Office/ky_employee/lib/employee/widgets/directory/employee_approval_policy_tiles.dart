import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_approval_policy_models.dart';
import 'employee_approval_policy_styles.dart';

class EmployeeApprovalPolicySummaryStrip extends StatelessWidget {
  final EmployeeApprovalPolicyProfile profile;

  const EmployeeApprovalPolicySummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Active', value: '${profile.activeCount}'),
        HrisMetricStripItem(
          label: 'Review',
          value: '${profile.reviewRequiredCount}',
        ),
        HrisMetricStripItem(
          label: 'Suspended',
          value: '${profile.suspendedCount}',
        ),
        HrisMetricStripItem(
          label: 'Expiring',
          value: '${profile.expiringSoonCount}',
        ),
      ],
    );
  }
}

class EmployeeApprovalPolicyStatusCard extends StatelessWidget {
  final EmployeeApprovalPolicyProfile profile;

  const EmployeeApprovalPolicyStatusCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final progressColor =
        profile.suspendedCount > 0 || profile.expiredCount > 0
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rule_folder_outlined,
                  color: progressColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.department} approval rules',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Manager ${profile.manager}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label:
                    profile.attentionCount == 0
                        ? 'Healthy'
                        : '${profile.attentionCount} open',
                color: progressColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.activeRatio,
            color: progressColor,
            label:
                '${(profile.activeRatio * 100).round()}% active, ${profile.highRiskActiveCount} high-risk active',
          ),
        ],
      ),
    );
  }
}

class EmployeeApprovalPolicyRuleTile extends StatelessWidget {
  final EmployeeApprovalPolicyRule rule;
  final DateTime asOfDate;
  final VoidCallback onActivate;
  final VoidCallback onReview;
  final VoidCallback onSuspend;
  final VoidCallback onRenew;
  final VoidCallback onRemove;

  const EmployeeApprovalPolicyRuleTile({
    super.key,
    required this.rule,
    required this.asOfDate,
    required this.onActivate,
    required this.onReview,
    required this.onSuspend,
    required this.onRenew,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeApprovalPolicyStatusColor(rule.status);
    final riskColor = employeeApprovalPolicyRiskColor(rule.risk);
    final expired = rule.isExpired(asOfDate);
    final expiringSoon = rule.expiresWithin(asOfDate, 14);

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
                  employeeApprovalPolicyStatusIcon(rule.status),
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
                      rule.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rule.primaryRoute.label} -> ${rule.fallbackRoute.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: rule.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeeApprovalPolicyAreaIcon(rule.area),
                label: rule.area.label,
              ),
              _MetaChip(
                icon: Icons.person_outline,
                label: rule.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: employeeApprovalRouteIcon(rule.primaryRoute),
                label: rule.primaryRoute.label,
              ),
              _MetaChip(
                icon: employeeApprovalEscalationIcon(rule.escalationMode),
                label: '${rule.escalationMode.label} ${rule.escalationHours}h',
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Expires ${DateFormat('MMM d').format(rule.expiresOn)}',
                color:
                    expired
                        ? const Color(0xFFB91C1C)
                        : expiringSoon
                        ? const Color(0xFFB45309)
                        : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: rule.risk.label,
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rule.thresholdLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rule.notes,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!rule.isActive)
                FilledButton.tonalIcon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Activate'),
                ),
              TextButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Review'),
              ),
              if (!rule.isSuspended)
                TextButton.icon(
                  onPressed: onSuspend,
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('Suspend'),
                ),
              TextButton.icon(
                onPressed: onRenew,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Renew'),
              ),
              IconButton(
                tooltip: 'Remove approval policy rule',
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
