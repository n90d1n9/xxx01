import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_access_governance_models.dart';
import 'employee_access_governance_styles.dart';

class EmployeeAccessGovernanceSummaryStrip extends StatelessWidget {
  final EmployeeAccessGovernanceProfile profile;

  const EmployeeAccessGovernanceSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Due', value: '${profile.dueReviewCount}'),
        HrisMetricStripItem(
          label: 'Revoke',
          value: '${profile.revokeRequestedCount}',
        ),
        HrisMetricStripItem(
          label: 'Privileged',
          value: '${profile.privilegedCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
      ],
    );
  }
}

class EmployeeAccessGovernanceReviewTile extends StatelessWidget {
  final EmployeeAccessGovernanceReview review;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onRequestRevoke;
  final VoidCallback onCompleteRevoke;
  final VoidCallback onMarkException;

  const EmployeeAccessGovernanceReviewTile({
    super.key,
    required this.review,
    required this.asOfDate,
    required this.onApprove,
    required this.onRequestRevoke,
    required this.onCompleteRevoke,
    required this.onMarkException,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = review.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeAccessGovernanceStatusColor(review.status);
    final riskColor = employeeAccessGovernanceRiskColor(review.risk);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeAccessGovernanceScopeIcon(review.scope),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.systemName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${review.roleName} - ${review.owner}',
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
                label: overdue ? 'Overdue' : review.status.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.businessJustification,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.person_search_outlined,
                label: review.reviewer,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(review.dueDate)}',
                color: overdue ? color : null,
              ),
              _MetaChip(
                icon: Icons.warning_amber_outlined,
                label: review.risk.label,
                color: riskColor,
              ),
              if (review.reviewedAt != null)
                _MetaChip(
                  icon: Icons.verified_outlined,
                  label:
                      'Reviewed ${DateFormat('MMM d').format(review.reviewedAt!)}',
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
          if (review.canApprove ||
              review.canRequestRevoke ||
              review.canCompleteRevoke ||
              review.canMarkException) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (review.canMarkException)
                  OutlinedButton.icon(
                    onPressed: onMarkException,
                    icon: const Icon(Icons.report_outlined),
                    label: const Text('Exception'),
                  ),
                if (review.canRequestRevoke)
                  OutlinedButton.icon(
                    onPressed: onRequestRevoke,
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Request revoke'),
                  ),
                if (review.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve'),
                  ),
                if (review.canCompleteRevoke)
                  FilledButton.icon(
                    onPressed: onCompleteRevoke,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Complete revoke'),
                  ),
              ],
            ),
          ],
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
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
