import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_follow_up_cadence.dart';
import '../models/company_governance_follow_up_policy.dart';
import '../models/company_governance_follow_up_policy_approval.dart';
import '../models/company_governance_follow_up_policy_impact.dart';

/// Shows proposed governance follow-up SLA changes awaiting review.
class CompanyGovernanceFollowUpPolicyApprovalPanel extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyApprovalQueue queue;
  final CompanyGovernanceFollowUpPolicy currentPolicy;
  final ValueChanged<CompanyGovernanceFollowUpPolicyApprovalRequest>? onApprove;
  final ValueChanged<CompanyGovernanceFollowUpPolicyApprovalRequest>? onReject;
  final ValueChanged<String>? onAuditEventSelected;

  const CompanyGovernanceFollowUpPolicyApprovalPanel({
    super.key,
    required this.queue,
    required this.currentPolicy,
    this.onApprove,
    this.onReject,
    this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Governance SLA Approvals',
      subtitle:
          queue.isEmpty
              ? 'No SLA approval requests'
              : '${queue.pendingCount} pending, ${queue.approvedCount} approved, ${queue.rejectedCount} rejected',
      emptyMessage: 'No governance SLA approval requests',
      children:
          queue.isEmpty
              ? const []
              : [
                _ApprovalSummaryStrip(
                  queue: queue,
                  currentPolicy: currentPolicy,
                ),
                for (final request in queue.records)
                  _ApprovalRequestTile(
                    request: request,
                    currentPolicy: currentPolicy,
                    onApprove:
                        onApprove == null ||
                                !request.isPending ||
                                request.isStaleAgainst(currentPolicy)
                            ? null
                            : () => onApprove!(request),
                    onReject:
                        onReject == null || !request.isPending
                            ? null
                            : () => onReject!(request),
                    onAuditEventSelected:
                        onAuditEventSelected == null || !request.hasAuditEvent
                            ? null
                            : () => onAuditEventSelected!(request.auditEventId),
                  ),
              ],
    );
  }
}

/// Summary strip for SLA approval request counts.
class _ApprovalSummaryStrip extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyApprovalQueue queue;
  final CompanyGovernanceFollowUpPolicy currentPolicy;

  const _ApprovalSummaryStrip({
    required this.queue,
    required this.currentPolicy,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Pending', value: '${queue.pendingCount}'),
        HrisMetricStripItem(label: 'Approved', value: '${queue.approvedCount}'),
        HrisMetricStripItem(label: 'Rejected', value: '${queue.rejectedCount}'),
        HrisMetricStripItem(label: 'Active', value: currentPolicy.compactLabel),
      ],
    );
  }
}

/// One proposed governance follow-up SLA change.
class _ApprovalRequestTile extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyApprovalRequest request;
  final CompanyGovernanceFollowUpPolicy currentPolicy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onAuditEventSelected;

  const _ApprovalRequestTile({
    required this.request,
    required this.currentPolicy,
    required this.onApprove,
    required this.onReject,
    required this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final isStale = request.isStaleAgainst(currentPolicy);

    return HrisListSurface(
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
                      request.requestedDateLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.requestedBy} - ${request.entityName}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: request.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.policyChangeLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Changed',
                value: '${request.impact.changedLaneCount}',
              ),
              HrisMetricStripItem(
                label: 'Due now',
                value: '${request.impact.dueNowCount}',
              ),
              HrisMetricStripItem(
                label: 'No handoff',
                value: '${request.impact.needsHandoffCount}',
              ),
              HrisMetricStripItem(
                label: 'Scheduled',
                value: '${request.impact.scheduledCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ApprovalImpactBanner(request: request, isStale: isStale),
          if (onApprove != null ||
              onReject != null ||
              onAuditEventSelected != null) ...[
            const SizedBox(height: 12),
            _ApprovalActions(
              requestId: request.id,
              onApprove: onApprove,
              onReject: onReject,
              onAuditEventSelected: onAuditEventSelected,
            ),
          ],
        ],
      ),
    );
  }
}

/// Explains the main impact or stale state for one approval request.
class _ApprovalImpactBanner extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyApprovalRequest request;
  final bool isStale;

  const _ApprovalImpactBanner({required this.request, required this.isStale});

  @override
  Widget build(BuildContext context) {
    final color = isStale ? Colors.orange : Colors.indigo;
    final text =
        isStale
            ? 'Current SLA changed after this request was opened. Reject and resubmit.'
            : request.topChangeLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isStale ? Icons.warning_amber_outlined : Icons.route_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action row for approving, rejecting, or inspecting an SLA request.
class _ApprovalActions extends StatelessWidget {
  final String requestId;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onAuditEventSelected;

  const _ApprovalActions({
    required this.requestId,
    required this.onApprove,
    required this.onReject,
    required this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          if (onAuditEventSelected != null)
            OutlinedButton.icon(
              key: Key('company-governance-sla-approval-audit-$requestId'),
              onPressed: onAuditEventSelected,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('View audit'),
            ),
          if (onReject != null)
            OutlinedButton.icon(
              key: Key('company-governance-sla-approval-reject-$requestId'),
              onPressed: onReject,
              icon: const Icon(Icons.close_outlined),
              label: const Text('Reject'),
            ),
          if (onApprove != null)
            FilledButton.icon(
              key: Key('company-governance-sla-approval-approve-$requestId'),
              onPressed: onApprove,
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Approve'),
            ),
        ],
      ),
    );
  }
}

Color _statusColor(CompanyGovernanceFollowUpPolicyApprovalStatus status) {
  switch (status) {
    case CompanyGovernanceFollowUpPolicyApprovalStatus.pending:
      return Colors.orange;
    case CompanyGovernanceFollowUpPolicyApprovalStatus.approved:
      return Colors.green;
    case CompanyGovernanceFollowUpPolicyApprovalStatus.rejected:
      return Colors.blueGrey;
  }
}

@Preview(name: 'Company governance follow-up SLA approval panel')
Widget companyGovernanceFollowUpPolicyApprovalPanelPreview() {
  const currentPolicy = CompanyGovernanceFollowUpPolicy(
    criticalCadenceDays: 1,
    highCadenceDays: 2,
    steadyCadenceDays: 3,
  );
  const requestedPolicy = CompanyGovernanceFollowUpPolicy(
    criticalCadenceDays: 3,
    highCadenceDays: 5,
    steadyCadenceDays: 7,
  );
  final request = CompanyGovernanceFollowUpPolicyApprovalRequest.create(
    id: 'governance-sla-approval-001',
    previousPolicy: currentPolicy,
    requestedPolicy: requestedPolicy,
    impact: const CompanyGovernanceFollowUpPolicyImpact(
      isValid: true,
      laneCount: 3,
      needsHandoffCount: 1,
      overdueCount: 0,
      dueTodayCount: 1,
      scheduledCount: 1,
      changedLaneCount: 1,
      newlyDueCount: 1,
      changedLanes: [
        CompanyGovernanceFollowUpPolicyImpactLane(
          ownerName: 'People Operations',
          currentTouchLabel: 'Due tomorrow',
          previewTouchLabel: 'Due today',
          previewState: CompanyGovernanceFollowUpState.dueToday,
          becomesDueNow: true,
        ),
      ],
    ),
    entityName: 'Company Governance',
    requestedBy: 'People Operations',
    requestedAt: DateTime(2026, 6, 12),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceFollowUpPolicyApprovalPanel(
          currentPolicy: currentPolicy,
          queue: CompanyGovernanceFollowUpPolicyApprovalQueue(
            records: [request],
          ),
          onApprove: _previewApprove,
          onReject: _previewReject,
        ),
      ),
    ),
  );
}

void _previewApprove(CompanyGovernanceFollowUpPolicyApprovalRequest request) {}

void _previewReject(CompanyGovernanceFollowUpPolicyApprovalRequest request) {}
